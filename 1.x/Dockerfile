FROM java:openjdk-7-jdk-alpine


ADD hadoop-1.2.1.tar.gz /opt

COPY run.sh /run.sh

RUN mkdir /opt/hdfs_name &&\
    mkdir /opt/hdfs_data &&\
    chmod +x /run.sh &&\
    apk add -U bash

CMD ["/run.sh"]
