ARG BASE_IMAGE=centos:7
FROM ${BASE_IMAGE}

MAINTAINER Felix <zhouxiang@cmss.chinamobile.com>

ENV container docker

# yum repo location
ARG YUM_REPO_HOST=100.73.8.120
ARG YUM_REPO_PORT=877
ARG MODULE_REPO_PATH=/var/www/html/eos-indexer
ARG CI_COMMIT_TAG

# The SCYLLA_REPO_URL argument specifies the URL to the RPM repository this Docker image uses to install Scylla. The default value is the Scylla's unstable RPM repository, which contains the daily build.
#ARG SCYLLA_REPO_URL=downloads.scylladb.com/unstable/scylla/branch-4.5/rpm/centos/latest/
ARG VERSION
#ARG SCYLLA_REPO_URL=http://downloads.scylladb.com/rpm/unstable/centos/branch-4.4/latest/scylla.repo
RUN rm -rf /etc/yum.repos.d/*
ADD dist/docker/redhat/scylla.repo /etc/yum.repos.d/
ADD dist/docker/redhat/centos7.repo /etc/yum.repos.d/
RUN if [ "$(uname -m)" = "aarch64" ]; then \
        rm -f /etc/yum.repos.d/centos7.repo; \
    fi && \
    sed -i "s|baseurl=.*|baseurl=http://${YUM_REPO_HOST}:${YUM_REPO_PORT}/eos-indexer/${CI_COMMIT_TAG}/|g" /etc/yum.repos.d/scylla.repo

RUN yum clean all && yum makecache

ADD dist/docker/redhat/scylla_bashrc /scylla_bashrc


# Docker image startup scripts:
# Install Scylla:
RUN if [ "$(uname -m)" = "aarch64" ]; then \
        yum -y install http://${YUM_REPO_HOST}:${YUM_REPO_PORT}/deps/indexer/rpm/centos7/aarch64/python-meld3-0.6.10-1.el7.aarch64.rpm && \
        yum -y install http://${YUM_REPO_HOST}:${YUM_REPO_PORT}/deps/indexer/rpm/centos7/noarch/supervisor-3.4.0-1.el7.noarch.rpm && \
        yum -y install scylla-tools-${VERSION}* scylla-tools-core-${VERSION}* scylla-conf-${VERSION}*; \
    else \
        yum -y clean expire-cache && \
        yum -y update && \
        yum -y install http://${YUM_REPO_HOST}:${YUM_REPO_PORT}/deps/indexer/rpm/centos7/x86_64/python-meld3-0.6.10-1.el7.x86_64.rpm && \
        yum -y install http://${YUM_REPO_HOST}:${YUM_REPO_PORT}/deps/indexer/rpm/centos7/noarch/supervisor-3.4.0-1.el7.noarch.rpm && \
        yum -y install scylla-tools-${VERSION}* scylla-tools-core-${VERSION}* scylla-conf-${VERSION}* hostname openssh-server openssh-clients rsyslog; \
    fi && \
    yum clean all && \
    cat /scylla_bashrc >> /etc/bashrc

ENV PATH /opt/scylladb/python3/bin:$PATH
