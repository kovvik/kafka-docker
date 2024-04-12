FROM ubuntu:22.04

ARG KAFKA_VERSION
ENV KAFKA_VERSION=${KAFKA_VERSION:-3.7.0}

ARG SCALA_VERSION
ENV SCALA_VERSION=${SCALA_VERSION:-2.13}

RUN apt-get update && \
    apt-get install -y openjdk-17-jre-headless wget &&\
    apt-get clean

RUN wget https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
        -O /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    mkdir -p /usr/local/kafka && \
    mkdir -p /usr/lib/kafka && \
    cd /usr/local/kafka && \
    tar --strip-components=1 -xzvf /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
