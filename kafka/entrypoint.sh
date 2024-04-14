#!/bin/bash

# Required environment variables:
#
# KAFKA_BROKER_ID
# KAFKA_CLUSTER_ID
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
# KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS

# Check required variables
if [ -z "${KAFKA_BROKER_ID:+SET}" ]
then 
        echo "KAFKA_BROKER_ID is not set"
        exit 1
fi

if [ -z "${KAFKA_CLUSTER_ID:+SET}" ]
then
        echo "KAFKA_CLUSTER_ID is not set"
        exit 1
fi

# Set config
truncate -s0 /usr/local/kafka/config/server.properties
cat << EOF > /usr/local/kafka/config/server.properties
broker.id=${KAFKA_BROKER_ID}
process.roles=broker,controller
controller.quorum.voters=${KAFKA_CONTROLLER_QUORUM_VOTERS:-1@localhost:9093}
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
group.initial.rebalance.delay.ms=${KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS:-0}
listeners=${KAFKA_LISTENERS:-INTERNAL://:9092,CONTROLLER://:9093}
controller.listener.names=CONTROLLER
advertised.listeners=${KAFKA_ADVERTISED_LISTENERS:-INTERNAL://:9092}
listener.security.protocol.map=${KAFKA_LISTENER_SECURITY_PROTOCOL_MAP:-INTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT}
inter.broker.listener.name=${KAFKA_INTER_BROKER_LISTENER_NAME:-INTERNAL}
ssl.keystore.password=${KAFKA_SSL_KEYSTORE_PASSWORD}
ssl.keystore.location=${KAFKA_SSL_KEYSTORE_LOCATION}
ssl.client.auth=${KAFKA_SSL_CLIENT_AUTH:-none}
ssl.truststore.password=${KAFKA_SSL_TRUSTSTORE_PASSWORD}
ssl.truststore.location=${KAFKA_SSL_TRUSTSTORE_LOCATION}
ssl.truststore.type=PKCS12
ssl.keystore.type=PKCS12
listener.name.internal.ssl.endpoint.identification.algorithm=
ssl.endpoint.identification.algorithm=
EOF

# Log config
cat /usr/local/kafka/config/server.properties

if [ ! $(cat /var/lib/kafka/kafka-logs/meta.properties 2>/dev/null | grep ${KAFKA_CLUSTER_ID}) ]
then
    echo "Formatting storage..."
    /usr/local/kafka/bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c /usr/local/kafka/config/server.properties
fi

# Start kafka
/usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties
