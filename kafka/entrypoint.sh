#!/bin/bash


cat << EOF > /etc/server.properties
broker.id=${KAFKA_BROKER_ID}
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/var/lib/kafka/kafka-logs
num.partitions=1
default.replication.factor=3
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=120
log.segment.bytes=1048576
log.retention.check.interval.ms=300000
zookeeper.connect=${KAFKA_ZK_CONNECT}
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0
EOF

/usr/local/kafka/kafka_2.12-2.2.0/bin/kafka-server-start.sh /etc/server.properties
