architecture=$(uname -m)
if [ $# != 3 ] ; then
    echo "USAGE: $0 CI_COMMIT_TAG DISTCC_HOSTS DISTCC_THREADS"
    echo " e.g.: $0 5.2.0 \"100.71.8.129/32 localhost/30\" 180"
    exit 1
else
    VERSION=$1
    DISTCC_HOSTS=$2
    echo "build rpm package using distcc hosts: ${DISTCC_HOSTS}"
fi

if [ -z "$3" ] ; then
    DISTCC_THREADS=32
else
    DISTCC_THREADS=$3
fi
echo "build dev using distcc threads: ${DISTCC_THREADS}"

YUM_REPO_HOST="100.71.8.120"
MODULE_REPO_PATH="/var/www/html/eos-indexer"
SUBMODULE=${VERSION%%-*}
SCYLLA_BUILD=${VERSION##*-}

curl -O http://${YUM_REPO_HOST}:877/deps/indexer/git-module/scylla/${SUBMODULE}-submodule.tar.gz
tar xfz ${SUBMODULE}-submodule.tar.gz
tar_result=$?
if [ "$tar_result" -ne 0 ]; then
    echo "解压失败，请核实submodule是否正确。"
    exit 1
fi


if [ ! -f "./SCYLLA-VERSION-GEN" ]; then
    echo "缺少 SCYLLA-VERSION-GEN 文件"
    exit 1
else
    sed -i "s/SCYLLA_BUILD=0/SCYLLA_BUILD=$SCYLLA_BUILD/g" SCYLLA-VERSION-GEN
    sed_result=$?
    if [ "$sed_result" -ne 0 ]; then
        echo "SCYLLA_BUILD 替换失败，清检查 SCYLLA-VERSION-GEN 文件。"
        exit 1
    fi
fi

image=$(cat tools/toolchain/image)

if [[ "$architecture" == "aarch64" ]]; then
    image=${image}-arm    
fi

./tools/toolchain/dbuild --image $image --entrypoint "python3" --user $(id -u) -- ./configure.py --mode=release

build_s1_result=$?
if [ "$build_s1_result" -ne 0 ]; then
    echo "编译失败，请检查"
    exit 1
fi

./tools/toolchain/dbuild --image $image --privileged --entrypoint "bash" \
     --user $(id -u) \
    -e CCACHE_PREFIX="distcc" \
    -e DISTCC_IO_TIMEOUT=7200 \
    -e DISTCC_VERBOSE=1 \
    -e DISTCC_HOSTS="$DISTCC_HOSTS" \
    -e PATH=/usr/lib64/ccache:/usr/bin:/usr/local/bin \
    -- -c "ninja dist-rpm -j$DISTCC_THREADS"

build_s2_result=$?
if [ "$build_s2_result" -ne 0 ]; then
    echo "编译dist失败，请检查"
    exit 1
fi

echo "编译成功"

echo "上传至yum repo"
ssh ${YUM_REPO_HOST} mkdir -p ${MODULE_REPO_PATH}/$VERSION/$architecture
mkdir_s1_result=$?
ssh ${YUM_REPO_HOST} mkdir -p ${MODULE_REPO_PATH}/$VERSION/noarch
mkdir_s2_result=$?
if [ "$mkdir_s1_result" -ne 0 ] && [ "$mkdir_s2_result" -ne 0 ]; then
    echo "创建远程目录失败，请检查"
    exit 1
fi
echo "创建远程目录 ${YUM_REPO_HOST}:${MODULE_REPO_PATH}/$VERSION 成功"

scp -r ./build/dist/release/redhat/RPMS/$architecture/* root@${YUM_REPO_HOST}:${MODULE_REPO_PATH}/$VERSION/$architecture/
scp_s1_result=$?
scp -r ./tools/python3/build/redhat/RPMS/$architecture/* root@${YUM_REPO_HOST}:${MODULE_REPO_PATH}/$VERSION/$architecture/
scp_s2_result=$?
scp -r ./tools/jmx/build/redhat/RPMS/noarch/* root@${YUM_REPO_HOST}:${MODULE_REPO_PATH}/$VERSION/noarch/
scp_s3_result=$?
scp -r ./tools/java/build/redhat/RPMS/noarch/* root@${YUM_REPO_HOST}:${MODULE_REPO_PATH}/$VERSION/noarch/
scp_s4_result=$?

if [ "$scp_s1_result" -ne 0 ] && [ "$scp_s2_result" -ne 0 ] && [ "$scp_s3_result" -ne 0 ] && [ "$scp_s4_result" -ne 0 ]; then
    echo "复制编译rpm包失败，请检查"
    exit 1
fi

echo "复制编译rpm包成功,清理 build 以及 submodel 的tar包和目录。"
rm -rf ${SUBMODULE}-submodule.tar.gz ./build/ ./seastar/*  ./tools/python3/* ./tools/jmx/*  ./tools/java/* ./abseil/* ./swagger-ui/*
rm_dir_result=$?
if [ "$rm_dir_result" -ne 0 ]; then
    echo "清理build目录失败，请检查"
    exit 1
fi


# rpm包所在目录需要other的r和x权限
ssh ${YUM_REPO_HOST}  chmod o+x ${MODULE_REPO_PATH}/$VERSION/*
# rpm包需要other的r权限
ssh ${YUM_REPO_HOST}  chmod -R o+r ${MODULE_REPO_PATH}/$VERSION/*
chmod_result=$?
if [ "$chmod_result" -ne 0 ]; then
    echo "rpm仓库权限修改失败，请检查"
    exit 1
fi
echo "rpm仓库权限修改成功"

ssh ${YUM_REPO_HOST} createrepo ${MODULE_REPO_PATH}/$VERSION
createrepo_result=$?
if [ "$createrepo_result" -ne 0 ]; then
    echo "创建rpm仓库失败，请检查"
    exit 1
fi
echo "创建rpm仓库成功"
