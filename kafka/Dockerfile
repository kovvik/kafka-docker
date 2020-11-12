FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y openjdk-8-jre-headless wget &&\
    apt-get clean

RUN wget https://archive.apache.org/dist/kafka/2.2.0/kafka_2.12-2.2.0.tgz -O /tmp/kafka_2.12-2.2.0.tgz && \
    mkdir -p /usr/local/kafka && \
    mkdir -p /usr/lib/kafka && \
    cd /usr/local/kafka && \
    tar xzvf /tmp/kafka_2.12-2.2.0.tgz && \
    rm /tmp/kafka_2.12-2.2.0.tgz

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
