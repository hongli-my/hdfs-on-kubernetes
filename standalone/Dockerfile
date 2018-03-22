FROM 10.2.1.227:5000/google_containers/ubuntu-slim:0.5

ADD hadoop-2.6.5.tar.gz /opt

COPY check_format.sh /check_format.sh

RUN export DEBIAN_FRONTEND=noninteractive &&\
    apt-get update && apt-get install -y --no-install-recommends \
    openjdk-8-jdk \
    tzdata \
    bash && \
    apt-get clean && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
    rm -rf /var/lib/apt/lists/* &&\
    chmod +x /check_format.sh

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
