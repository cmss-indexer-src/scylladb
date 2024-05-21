#!/bin/bash

# Exit if any one of the commands below fails
set -e

if [ -z "$DTEST_THREADS" ] ; then
    DISTCC_THREADS=32
else
    DISTCC_THREADS=$DTEST_THREADS
fi
echo "build dev using distcc threads: ${DISTCC_THREADS}"


VERSION=$(grep "^VERSION=" SCYLLA-VERSION-GEN | awk -F= '{print $2}')
echo "version of scylla: ${VERSION}"


curl -L http://100.71.8.120:877/deps/java/antlr-3.5.2-complete.jar --output /usr/share/java/antlr-3.5.2-complete.jar
curl -O http://100.71.8.120:877/deps/indexer/git-module/scylla/$VERSION-submodule.tar.gz
tar xfz $VERSION-submodule.tar.gz

echo "build dev using distcc hosts: ${DISTCC_HOSTS}"

export CLASSPATH=".:/usr/share/java/antlr-3.5.2-complete.jar:$CLASSPATH"
time ./configure.py --mode=dev
time ninja build/dev/scylla -j$DISTCC_THREADS