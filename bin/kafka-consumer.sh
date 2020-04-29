#!/bin/bash
set -e 

trap '{ echo "" ; exit 1; }' INT

KAFKA_TOPIC=${1:-'names'}
KAFKA_CLUSTER_NS=${2:-'knativetutorial'}
KAFKA_CLUSTER_NAME=${3:-'names-cluster'}

kubectl -n $KAFKA_CLUSTER_NS run kafka-consumer -ti \
  --image=strimzi/kafka:0.15.0-kafka-2.3.1 \
  --rm=true --restart=Never \
  -- bin/kafka-console-consumer.sh \
  --bootstrap-server $KAFKA_CLUSTER_NAME-kafka-bootstrap.$KAFKA_CLUSTER_NS:9092 \
  --topic $KAFKA_TOPIC --from-beginning
