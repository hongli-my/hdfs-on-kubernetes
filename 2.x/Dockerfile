FROM 10.2.1.227:5000/google_containers/ubuntu-slim:0.5


ADD hadoop-2.6.5.tar.gz /opt

COPY run.sh /run.sh
COPY check_path /check_path

RUN export DEBIAN_FRONTEND=noninteractive &&\
    apt-get update && apt-get install -y --no-install-recommends \
    openjdk-8-jdk \
    tzdata \
    openssh-server \
    bash && \
    apt-get clean && \
    ssh-keygen -f /root/.ssh/id_rsa -P '' &&\
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys &&\
    /usr/bin/ssh-keygen -A &&\
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
    rm -rf /var/lib/apt/lists/* &&\
    chmod +x /run.sh &&\
    chmod +x /check_path

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
CMD ["/run.sh"]
