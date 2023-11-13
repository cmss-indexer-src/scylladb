import boto3,logging
from boto3.session import Session
import os,time
import argparse

parser = argparse.ArgumentParser(description='Sync data between GSI and base table.')

parser.add_argument('--dynamodbtable', type=str, help='The table to be synchronized.', required=True)
parser.add_argument('--endpoint', type=str, help='The endpoint to connect, eg. "http://10.167.139.15:8000"', required=True)
parser.add_argument('--thread', type=int, default=10, help='The num of threads.')
parser.add_argument('--shard', type=int, default=10, help='The num of shard of the obj_meta table.')
parser.add_argument('--bucket-id', type=str, help='The bucket id of the bucket that specifies the obj_meta table.', required=True)
parser.add_argument('--log-level', type=str, default='INFO', help='The log level of boto3.')

args = parser.parse_args()
table_name = args.dynamodbtable
table_index_name = table_name + '_index'
thd = args.thread
shd = args.shard
bid = args.bucket_id
log_level = args.log_level.upper()

logging.basicConfig(filename='boto3.log', level=log_level)

config = boto3.session.Config(connect_timeout=1000, read_timeout=34000, retries={'max_attempts': 0}, signature_version="s3v4")
session = Session("fake", "fake")
dynamodb_client = session.client('dynamodb', endpoint_url=args.endpoint, config=config, region_name="us-west-2")

from concurrent.futures import ThreadPoolExecutor


def task(shard):
    try:
        start_time = time.time()
        last_evaluated_key = None
        while True:
            # Query GSI, get the full amount of data
            query_params = {
                'TableName':table_name,
                'IndexName':table_index_name,
                'Limit':1000,
                'ConsistentRead':False,
                'ScanIndexForward':True,
                'ProjectionExpression':'obj,bi',
                'FilterExpression':'attribute_not_exists(ns)',
                'KeyConditionExpression':'bi = :part_key',
                'ExpressionAttributeValues':{
                    ':part_key': {
                        'S': bid + '.%s' % (shard)
                    }
                }
            }
            if last_evaluated_key:
                #print("====Got last_evaluated_key, let's put it into the query req as ExclusiveStartKey!====")
                query_params['ExclusiveStartKey'] = last_evaluated_key
            query_response = dynamodb_client.query(**query_params)

            items = query_response['Items']
            for item in items:
                # Check if the data exists in the base table
                obj = item.get('obj').get('S')
                bi = item.get('bi').get('S')
                getitem_res = dynamodb_client.get_item(
                    TableName=table_name,
                    Key = {
                        'obj':{
                            'S': obj
                        },
                        'bi':{
                            'S': bi
                        }
                    },
                    ConsistentRead=True,
                    ProjectionExpression='obj',
                )
                if getitem_res.get('ResponseMetadata').get('HTTPStatusCode') == 200 and 'Item' not in getitem_res:
                    print(item)
                    # If it does not exist in the base table, it means that the item has been deleted from the base table and remains in the GSI.
                    # Set remaining items in GSI as tombstones by first writing and then deleting.
                    putitem_res = dynamodb_client.put_item(
                        TableName=table_name,
                        Item=item,
                        ReturnValues='ALL_OLD',
                        ConditionExpression='attribute_not_exists(obj)'
                    )
                    #print(putitem_res)
                    time.sleep(0.02)
                    #deleteitem
                    if putitem_res.get('ResponseMetadata').get('HTTPStatusCode') == 200:
                        deleteitem_res = dynamodb_client.delete_item(
                            TableName = table_name,
                            Key = {
                                'obj':{
                                    'S': obj
                                },
                                'bi':{
                                    'S': bi
                                }
                            },
                            ReturnValues='ALL_OLD',
                        )
                        if deleteitem_res.get('ResponseMetadata').get('HTTPStatusCode') != 200:
                            # Be careful, if we get here, it means we have created dirty data, the program must exit immediately, and then manually clean up the dirty data.
                            print("Dirty data alarm!")
                            print(item)
                            msg = "ERROR: failed handle bi=%s obj=%s cost=%s seconds" % (bi, obj, (time.time() - start_time))
                            break

            last_evaluated_key = query_response.get('LastEvaluatedKey')
            if not last_evaluated_key:
                msg = "INFO: succ handle shard=%s cost=%s seconds" % (shard, (time.time() - start_time))
                break
        return msg
    except Exception as e:
        msg = "ERROR: shard=%s cost=%s seconds err=%s" % (shard, (time.time() - start_time), e.message)
        return msg

executor = ThreadPoolExecutor(thd)

tasks = []
for shard in range(0, shd):
    future = executor.submit(task, str(shard))
    tasks.append(future)

for f in tasks:
    print(f.result())
