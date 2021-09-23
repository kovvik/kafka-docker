#!/bin/bash

# Required environment variables:
#
# KAFKA_BROKER_ID
# KAFKA_ZK_CONNECT
#
# Optional environment variables:
#
# KAFKA_NUM_NETWORK_THREADS
# KAFKA_IO_THREADS
# KAFKA_SOCKET_SEND_BUFFER_BYTES
# KAFKA_SOCKET_RECEIVE_BUFFER_BYTES
# KAFKA_SOCKET_REQUEST_MAX_BYTES
# KAFKA_NUM_PARTITIONS
# KAFKA_DEFAULT_REPLICATION_FACTOR
# KAFKA_NUM_RECOVERY_THREADS_PER_DATA_DIR
# KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR
# KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR
# KAFKA_TRANSACTION_STATE_LOG_MIN_ISR
# KAFKA_LOG_RETENTION_HOURS
# KAFKA_LOG_SEGMENT_BYTES
# KAFKA_LOG_RETENTION_CHECK_INTERVAL_MS
# KAFKA_ZK_CONNECTION_TIMEOUT_MS
# KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS

# Check required variables
if [ -z "${KAFKA_BROKER_ID:+SET}" ]
then 
        echo "KAFKA_BROKER_ID is not set"
        exit 1
fi

if [ -z "${KAFKA_ZK_CONNECT:+SET}" ]
then
        echo "KAFKA_ZK_CONNECT is not set"
        exit 1
fi

# Set config
cat << EOF > /etc/server.properties
broker.id=${KAFKA_BROKER_ID}
num.network.threads=${KAFKA_NUM_NETWORK_THREADS:-3}
num.io.threads=${KAFKA_IO_THREADS:-8}
socket.send.buffer.bytes=${KAFKA_SOCKET_SEND_BUFFER_BYTES:-102400}
socket.receive.buffer.bytes=${KAFKA_SOCKET_RECEIVE_BUFFER_BYTES:-102400}
socket.request.max.bytes=${KAFKA_SOCKET_REQUEST_MAX_BYTES:=104857600}
log.dirs=/var/lib/kafka/kafka-logs
num.partitions=${KAFKA_NUM_PRTITIONS:-1}
default.replication.factor=${KAFKA_DEFAULT_REPLICATION_FACTOR:-3}
num.recovery.threads.per.data.dir=${KAFKA_NUM_RECOVERY_THREADS_PER_DATA_DIR:-1}
offsets.topic.replication.factor=${KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR:-1}
transaction.state.log.replication.factor=${KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR:-1}
transaction.state.log.min.isr=${KAFKA_TRANSACTION_STATE_LOG_MIN_ISR:-1}
log.retention.hours=${KAFKA_LOG_RETENTION_HOURS:-120}
log.segment.bytes=${KAFKA_LOG_SEGMENT_BYTES:-1048576}
log.retention.check.interval.ms=${KAFKA_LOG_RETENTION_CHECK_INTERVAL_MS:-300000}
zookeeper.connect=${KAFKA_ZK_CONNECT}
zookeeper.connection.timeout.ms=${KAFKA_ZK_CONNECTION_TIMEOUT_MS:-6000}
group.initial.rebalance.delay.ms=${KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS:-0}
listeners=${KAFKA_LISTENERS:-INTERNAL://0.0.0.0:9092}
advertised.listeners=${KAFKA_ADVERTISED_LISTENERS:-INTERNAL://0.0.0.0:9092}
listener.security.protocol.map=${KAFKA_LISTENER_SECURITY_PROTOCOL_MAP:-INTERNAL:PLAINTEXT}
inter.broker.listener.name=${KAFKA_INTER_BROKER_LISTENER_NAME:-INTERNAL}
EOF

# Log config
cat /etc/server.properties

# Start kafka
/usr/local/kafka/bin/kafka-server-start.sh /etc/server.properties
