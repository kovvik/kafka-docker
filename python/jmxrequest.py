#!/usr/bin/env python3

'''Kafka JXM query test'''

import json
from jmxquery import JMXQuery
from jmxquery import JMXConnection

jmxConnection = JMXConnection("service:jmx:rmi:///jndi/rmi://localhost:29999/jmxrmi")
jmxQuery =[JMXQuery("*:*")]
#jmxQuery = [JMXQuery("kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec,topic=test_with_underscore")]
metrics = jmxConnection.query(jmxQuery)
for metric in metrics:
    print(f"{metric.to_query_string()} ({metric.value_type}) = {metric.value}")

