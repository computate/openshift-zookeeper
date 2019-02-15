FROM openshift/base-centos7:latest

ENV ZK_USER=zookeeper \
    ZK_DATA_DIR=/var/lib/zookeeper/data \
    ZK_DATA_LOG_DIR=/var/lib/zookeeper/log \
    ZK_LOG_DIR=/var/log/zookeeper \
    JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk \
    ZK_VERSION=3.5.3 \
    ZK_DIST=zookeeper-$ZK_VERSION \
    INSTALL_PKGS="gettext tar zip unzip hostname nmap-ncat java-1.8.0-openjdk ivy lsof maven ant autoreconf automake cppunit-devel libtool"

COPY fix-permissions /usr/local/bin

RUN yum install -y $INSTALL_PKGS
RUN yum clean all
RUN mkdir /usr/local/src/zookeeper
RUN git clone https://github.com/apache/zookeeper.git /usr/local/src/zookeeper
WORKDIR /usr/local/src/zookeeper
RUN cd /usr/local/src/zookeeper && git checkout release-$ZK_VERSION
RUN ant package
RUN cp -r /usr/local/src/zookeeper/build/zookeeper-$ZK_VERSION-beta /opt/zookeeper
RUN /usr/local/bin/fix-permissions /opt/zookeeper
RUN rm -rf /opt/zookeeper/CHANGES.txt \
        /opt/zookeeper/README.txt \
        /opt/zookeeper/NOTICE.txt \
        /opt/zookeeper/CHANGES.txt \
        /opt/zookeeper/README_packaging.txt \
        /opt/zookeeper/build.xml \
        /opt/zookeeper/config \
        /opt/zookeeper/contrib \
        /opt/zookeeper/dist-maven \
        /opt/zookeeper/docs \
        /opt/zookeeper/ivy.xml \
        /opt/zookeeper/ivysettings.xml \
        /opt/zookeeper/recipes \
        /opt/zookeeper/src \
        /opt/zookeeper/$ZK_DIST.jar.asc \
        /opt/zookeeper/$ZK_DIST.jar.md5 \
        /opt/zookeeper/$ZK_DIST.jar.sha1

COPY zkGenConfig.sh zkOk.sh zkMetrics.sh /opt/zookeeper/bin/

RUN useradd -u 1002 -r -c "Zookeeper User" $ZK_USER && \
    mkdir -p $ZK_DATA_DIR $ZK_DATA_LOG_DIR $ZK_LOG_DIR /usr/share/zookeeper /tmp/zookeeper && \
    chown -R 1002:0 $ZK_DATA_DIR $ZK_DATA_LOG_DIR $ZK_LOG_DIR /tmp/zookeeper && \
    /usr/local/bin/fix-permissions $ZK_DATA_DIR && \
    /usr/local/bin/fix-permissions $ZK_DATA_LOG_DIR && \
    /usr/local/bin/fix-permissions $ZK_LOG_DIR && \
    /usr/local/bin/fix-permissions /tmp/zookeeper

WORKDIR "/opt/zookeeper"

USER 1002
