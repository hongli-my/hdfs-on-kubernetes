FROM java:openjdk-7-jdk-alpine


ADD hadoop-2.6.5.tar.gz /opt

COPY run.sh /run.sh
COPY check_path /check_path

RUN chmod +x /run.sh &&\
    chmod +x /check_path &&\
    apk add -U bash openssh &&\
    ssh-keygen -f /root/.ssh/id_rsa -P '' &&\
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys &&\
    /usr/bin/ssh-keygen -A

CMD ["/run.sh"]
