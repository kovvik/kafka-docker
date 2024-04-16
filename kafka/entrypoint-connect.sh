#!/bin/bash

# Required environment variables:
#
# KAFKA_BOOSTRAP_SERVERS
#
# Optional environment variables:
#
# KAFKA_GROUP_ID
# KAFKA_KEY_CONVERTER
# KAFKA_VALUE_CONVERTER
# KAFKA_KEY_CONVERTER_SCHEMAS_ENABLE
# KAFKA_VALUE_CONVERTER_SCHEMAS_ENABLE
# KAFKA_REPLICATION_FACTOR
# KAFKA_OFFSET_FLUSH_INTERVAL_MS
# KAKFA_REST_PORT
# KAFKA_SSL_KEYSTORE_PASSWORD
# KAFKA_SSL_KEYSTORE_LOCATION
# KAFKA_SSL_CLIENT_AUTH
# KAFKA_SSL_TRUSTSTORE_PASSWORD
# KAFKA_SSL_TRUSTSTORE_LOCATION

# Check required variables
if [ -z "${KAFKA_BOOTSTRAP_SERVERS:+SET}" ]
then 
        echo "KAFKA_BOOTSTRAP_SERVERS is not set"
        exit 1
fi

# Set config
truncate -s0 /usr/local/kafka/config/connect-distributed.properties
cat << EOF > /usr/local/kafka/config/connect-distributed.properties
bootstrap.servers=${KAFKA_BOOTSTRAP_SERVERS}
group.id=${KAFKA_GROUP_ID:-connect}
key.converter=${KAFKA_KEY_CONVERTER:-org.apache.kafka.connect.storage.StringConverter}
value.converter=${KAFKA_VALUE_CONVERTER:-org.apache.kafka.connect.storage.StringConverter}
key.converter.schemas.enable=${KAFKA_KEY_CONVERTER_SCHEMAS_ENABLE:-true}
value.converter.schemas.enable=${KAFKA_VALUE_CONVERTER_SCHEMAS_ENABLE:-true}
offset.storage.topic=${KAFKA_GROUP_ID}-offsets
offset.storage.replication.factor=${KAFKA_REPLICATION_FACTOR:-1}
config.storage.topic=${KAFKA_GROUP_ID}-configs
config.storage.replication.factor=${KAFKA_REPLICATION_FACTOR:-1}
status.storage.topic=${KAFKA_GROUP_ID}-status
status.storage.replication.factor=${KAFKA_REPLICATION_FACTOR:-1}
offset.flush.interval.ms=${KAFKA_OFFSET_FLUSH_INTERVAL_MS:-10000}
rest.port=${KAFKA_REST_PORT:-8083}
plugin.path=/usr/local/kafka-connect
ssl.keystore.password=${KAFKA_SSL_KEYSTORE_PASSWORD}
ssl.keystore.location=${KAFKA_SSL_KEYSTORE_LOCATION}
ssl.client.auth=${KAFKA_SSL_CLIENT_AUTH:-none}
ssl.truststore.password=${KAFKA_SSL_TRUSTSTORE_PASSWORD}
ssl.truststore.location=${KAFKA_SSL_TRUSTSTORE_LOCATION}
ssl.truststore.type=PKCS12
ssl.keystore.type=PKCS12
EOF

# Log config
cat /usr/local/kafka/config/connect-distributed.properties

# Start kafka
/usr/local/kafka/bin/connect-distributed.sh /usr/local/kafka/config/connect-distributed.properties

#CONNECT
