from kafka import KafkaProducer, KafkaAdminClient, KafkaConsumer
from kafka.errors import KafkaError
import logging

logger = logging.getLogger(__name__)

def producer():
    try:
        producer = KafkaProducer(bootstrap_servers="localhost:9093")
    except KafkaError as e:
        logger.error(e)
        exit(1)
    for a in range(100):
        print(a)
        try:
            future = producer.send('foobar', value=b'some bytes')
            result = future.get(timeout=5)
        except KafkaError as e:
            logger.error(e)
            pass

#admin_client = KafkaAdminClient(bootstrap_servers="localhost:9093")
#consumer = KafkaConsumer(group_id="admin", bootstrap_servers="localhost:9093")
#print(consumer.topics())
producer()
