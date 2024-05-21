ARG BASE_IMAGE=centos:7
FROM ${BASE_IMAGE}

MAINTAINER Avi Kivity <avi@cloudius-systems.com>

ENV container docker

# yum repo location
ARG YUM_REPO_HOST=100.73.8.120
ARG YUM_REPO_PORT=877
ARG MODULE_REPO_PATH=/var/www/html/eos-indexer
ARG CI_COMMIT_TAG

# The SCYLLA_REPO_URL argument specifies the URL to the RPM repository this Docker image uses to install Scylla. The default value is the Scylla's unstable RPM repository, which contains the daily build.
ARG VERSION
RUN rm -rf /etc/yum.repos.d/*
ADD dist/docker/redhat/centos7.repo /etc/yum.repos.d/
ADD dist/docker/redhat/scylla.repo /etc/yum.repos.d/
RUN if [ "$(uname -m)" = "aarch64" ]; then \
        rm -f /etc/yum.repos.d/centos7.repo; \
    fi && \
    sed -i "s|baseurl=.*|baseurl=http://${YUM_REPO_HOST}:${YUM_REPO_PORT}/eos-indexer/${CI_COMMIT_TAG}/|g" /etc/yum.repos.d/scylla.repo

RUN yum clean all && yum makecache

ADD dist/docker/redhat/ready-probe.sh /opt/ready-probe.sh
ADD dist/docker/redhat/scylla_bashrc /scylla_bashrc

# Scylla configuration:
ADD dist/docker/redhat/etc/sysconfig/scylla-server /etc/sysconfig/scylla-server

# Supervisord configuration:
ADD dist/docker/redhat/etc/supervisord.conf /etc/supervisord.conf
ADD dist/docker/redhat/etc/supervisord.conf.d/scylla-server.conf /etc/supervisord.conf.d/scylla-server.conf
ADD dist/docker/redhat/etc/supervisord.conf.d/scylla-jmx.conf /etc/supervisord.conf.d/scylla-jmx.conf
ADD dist/docker/redhat/etc/supervisord.conf.d/rsyslog.conf /etc/supervisord.conf.d/rsyslog.conf
ADD dist/docker/redhat/etc/rsyslog.conf /etc/rsyslog.conf
ADD dist/docker/redhat/scylla-service.sh /scylla-service.sh
ADD dist/docker/redhat/scylla-jmx-service.sh /scylla-jmx-service.sh
ADD dist/docker/redhat/probe.sh /opt/probe.sh

# Docker image startup scripts:
ADD dist/docker/redhat/scyllasetup.py /scyllasetup.py
ADD dist/docker/redhat/commandlineparser.py /commandlineparser.py
ADD dist/docker/redhat/docker-entrypoint.py /docker-entrypoint.py

# Install Scylla:
RUN if [ "$(uname -m)" = "aarch64" ]; then \
        yum -y install http://${YUM_REPO_HOST}:${YUM_REPO_PORT}/deps/indexer/rpm/centos7/aarch64/python-meld3-0.6.10-1.el7.aarch64.rpm && \
        yum -y install http://${YUM_REPO_HOST}:${YUM_REPO_PORT}/deps/indexer/rpm/centos7/noarch/supervisor-3.4.0-1.el7.noarch.rpm && \
        yum -y install scylla-$VERSION && \
        baseurl="http://100.71.8.120:877/deps/indexer/rpm/centos7/aarch64/perf/" && \
        rpms=$(curl -s $baseurl | grep -Eo 'href="[^"]+\.rpm"' | sed 's/href="//' | sed 's/"//') && \
        for rpm in $rpms; do curl -O $baseurl$rpm; done; \
    else \
        yum -y clean expire-cache && \
        yum -y update && \
        yum -y install http://${YUM_REPO_HOST}:${YUM_REPO_PORT}/deps/indexer/rpm/centos7/x86_64/python-meld3-0.6.10-1.el7.x86_64.rpm && \
        yum -y install http://${YUM_REPO_HOST}:${YUM_REPO_PORT}/deps/indexer/rpm/centos7/noarch/supervisor-3.4.0-1.el7.noarch.rpm && \
        yum -y install scylla-$VERSION hostname openssh-server openssh-clients rsyslog && \
        yum -y install mdadm xfsprogs&& \
        baseurl="http://100.73.8.120:877/deps/indexer/rpm/centos7/x86_64/perf/" && \
        rpms=$(curl -s $baseurl | grep -Eo 'href="[^"]+\.rpm"' | sed 's/href="//' | sed 's/"//') && \
        for rpm in $rpms; do curl -O $baseurl$rpm; done; \
    fi && \
    rpm -ivh *.rpm && \
    rm -f *.rpm && \
    yum clean all && \
    cat /scylla_bashrc >> /etc/bashrc && \
    mkdir -p /etc/supervisor.conf.d && \
    mkdir -p /var/log/scylla && \
    chown -R scylla:scylla /var/lib/scylla

ENV PATH /opt/scylladb/python3/bin:$PATH
ENTRYPOINT ["/docker-entrypoint.py"]

EXPOSE 10000 9042 9160 9180 7000 7001 22
VOLUME [ "/var/lib/scylla" ]
