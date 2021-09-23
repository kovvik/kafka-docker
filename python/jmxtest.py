#!/usr/bin/env python3

'''Kafka JXM query test'''

import json
from jmxquery import JMXQuery
from jmxquery import JMXConnection

JMX_URI = 'service:jmx:rmi:///jndi/rmi://localhost:29999/jmxrmi'

def read_jmx_metrics(jmx_uri):
    '''Read JMX metrics from jmx_uri.'''
    jmx_connection = JMXConnection(jmx_uri)
    jmx_query = [JMXQuery(
        'kafka.server:type=BrokerTopicMetrics,name=*,topic=*',
        metric_name='{topic}_{type}_{name}',
        metric_labels={'topic': '{topic}', 'name': '{name}'}
    )]
    return jmx_connection.query(jmx_query)

def parse_metrics(jmx_metrics):
    '''Parse JMX metrics to dict'''
    metrics_obj = {}
    for metric in jmx_metrics:
        topic = metric.metric_labels['topic']
        metric_name = metric.metric_labels['name']
        #print(json.dumps(metric.metric_labels['name']))
        if topic not in metrics_obj:
            metrics_obj[topic] = {}
        if metric_name not in metrics_obj[topic]:
            metrics_obj[topic][metric_name] = {}
        if metric.value_type == 'Double':
            #print(f'{metric.metric_name}({metric.attribute}) == {metric.value:.2f}')
            metrics_obj[topic][metric_name][metric.attribute] = '%.2f' % metric.value
        else:
            #print(f'{metric.metric_name}({metric.attribute}) == {metric.value}')
            metrics_obj[topic][metric_name][metric.attribute] = metric.value
    return metrics_obj

def read_config(filename):
    '''Read json config from filename.'''
    with open(filename, 'r') as configfile:
            json.dump(data, outfile)

def main():
    '''Main function'''
    jmx_metrics = read_jmx_metrics(JMX_URI)
    metrics = parse_metrics(jmx_metrics)
    print(json.dumps(metrics))

if __name__ == '__main__':
    main()
