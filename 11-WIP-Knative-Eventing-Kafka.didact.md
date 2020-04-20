# Apache Kafka Events with Knative Eventing

At the end of this chapter you will be able to:

- Using KafkaSource with Knative Eventing

- Source Kafka Events to Sink

- Autocaling Knative Services with Apache Kafka Events

## 1. Prerequisite

- Make sure you completed all the steps in the Prerequistes lab

- Make sure the Kafka cluster is setup on OpenShift

- Make sure to be on knativetutorial OpenShift project

- - oc project -q

- If you are not on knativetutorial project, then run following command to change to knativetutorial project:

- - oc project knativetutorial

## 2. Deploy Knative Eventing KafkaSource

Knative Eventing KafkaSource need to be used to have the Kafka messages to flow through the Knative Eventing Channels. You can deploy Knative KafkaSource by running the command:


Use the OperatorHub in OpenShift web console to install Knative Eventing Kafka operator that will install the KafkaSource.

More instructions at [Installing Knative Apache Kafka Operator in OpenShift](https://openshift-knative.github.io/docs/docs/proc_apache-kafka.html "To install Knative Apache Kafka Operator on OpenShift")

The previous step deploys Knative KafkaSource in the knative-eventing namespace as well as a CRD, ServiceAccount, ClusterRole, etc. Verify that knative-eventing namespace includes the `kafka-controller-manager-0` pod:

```
watch kubectl get pods -n knative-eventing
```

The command above should show the following output:
```
NAME                         READY   STATUS    AGE
kafka-controller-manager-0   1/1     Running   1m17s
```

You should also deploy the Knative Kafka Channel that can be used to connect the Knative Eventing Channel with a Apache Kafka cluster backend, to deploy a Knative Kafka Channel run:


Knative Eventing Kafka operator that was done in earlier, will install Knative KafkaChannel as well.

Look for 3 new pods in namespace knative-eventing with the prefix "kafka":

```
watch oc get pods -n knative-eventing
```

The command will shown an output like:
```
NAME                                   READY   STATUS    AGE
eventing-controller-666b79d867-kq8cc   1/1     Running   64m
eventing-webhook-5867c98d9b-hzctw      1/1     Running   64m
imc-controller-7c4f9945d7-s59xd        1/1     Running   64m
imc-dispatcher-7b55b86649-nsjm2        1/1     Running   64m
kafka-ch-controller-7c596b6b55-fzxcx   1/1     Running   33s
kafka-ch-dispatcher-577958f994-4f2qs   1/1     Running   33s
kafka-webhook-74bbd99f5c-c84ls         1/1     Running   33s
sources-controller-694f8df9c4-pss2w    1/1     Running   64m
```

And you should also find some new api-resources as shown:

kubectl

oc

oc api-resources --api-group='sources.eventing.knative.dev'

The command should show the following APIs in sources.eventing.knative.dev :

NAME               APIGROUP                       NAMESPACED  KIND
apiserversources   sources.eventing.knative.dev   true        ApiServerSource
containersources   sources.eventing.knative.dev   true        ContainerSource
cronjobsources     sources.eventing.knative.dev   true        CronJobSource
kafkasources       sources.eventing.knative.dev   true        KafkaSource
sinkbindings       sources.eventing.knative.dev   true        SinkBinding
kubectl

oc

oc api-resources --api-group='messaging.knative.dev'

The command should show the following APIs in messaging.knative.dev :

NAME               SHORTNAMES   APIGROUP                NAMESPACED   KIND
channels           ch           messaging.knative.dev   true         Channel
inmemorychannels   imc          messaging.knative.dev   true         InMemoryChannel
kafkachannels      kc           messaging.knative.dev   true         KafkaChannel
parallels                       messaging.knative.dev   true         Parallel
sequences                       messaging.knative.dev   true         Sequence
subscriptions      sub          messaging.knative.dev   true         Subscription
Using Kafka Channel as Default Knative Channel
Persistence and Durability are two very important features of any messaging based architectures. The Knative Channel has built-in support for durability. Durability of messages becomes ineffective, if the Knative Eventing Channel does not support persistence. As without persistence it will not be able to deliver the messages to subscribers which might be offline at the time of message delivery.

By default all Knative Channels created by the Knative Eventing API use InMemoryChannel(imc), which does not have capability to persist messages. To enable persistence we need to use one of the supported channels such as GCP PubSub, Kafka or Natss as the default Knative Channel backend.

We installed Apache Kafka, earlier in this tutorial, let us now configure it to be the default Knative Channel backend:

Knative Default Channel ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: default-ch-webhook
  namespace: knative-eventing
data:
  default-ch-config: |
    clusterDefault: #<1>
      apiVersion: messaging.knative.dev/v1alpha1
      kind: InMemoryChannel
    namespaceDefaults: #<2>
      knativetutorial:
        apiVersion: messaging.knative.dev/v1alpha1
        kind: KafkaChannel
        spec:
          numPartitions: 1
          replicationFactor: 1
For the cluster we will still use the default InMemoryChannel
For the namespace knativetutorial, all Knative Eventing Channels will use KafkaChannel as default
Run the following command apply the Knative Eventing Channel configuration:

kubectl apply -f default-kafka-channel.yaml

Since you have now made all Knative Eventing Channels of knativetutorial to be KafkaChannel, creating a Knative Eventing Channel in namespace knativetutorial will result in a corresponding Kafka Topic created. Let us now verify it by creating a sample Channel as show in listing,

Create a example Channel
cat <<EOF | kubectl apply -f -
apiVersion: messaging.knative.dev/v1alpha1
kind: Channel
metadata:
  name: my-events-ch
  namespace: knativetutorial
spec: {}
EOF
When you now list the topics that are available in Kafka using the script $TUTORIAL_HOME/bin/kafka-list-topics.sh, you should see a topic corresponding to your Channel my-events-ch:

$TUTORIAL_HOME/bin/kafka-list-topics.sh

The command should return an output like knative-messaging-kafka.knativetutorial.my-events-ch.

For each Knative Eventing Channel that you will create, there will be a Kafka Topic created, the topic’s name will follow a convention like knative-messaging-kafka.<your-channel-namespace>.<your-channel-name>.

We can delete the example my-events-ch channel using the command:

kubectl

oc

kubectl -n knativetutorial delete -f channels.messaging.knative.dev my-events-ch

Connecting Kafka Source to Sink
Now, all of your infrastructure is configured, you can deploy the Knative Serving Service(sink) by running the command:

kubectl

oc

oc apply -n knativetutorial -f eventing-hello-sink.yaml

Check the Knative Service that was created by the command above:

oc get ksvc

The command should show an output like:

NAME            URL                                      READY
eventinghello   http://eventinghello.kafka.example.com   True
Make sure to follow the logs using stern:

stern eventinghello -c user-container

The initial deployment of eventinghello will cause it to scale up to 1 pod. It will be around until it hits its scale-down time limit. Allow it to scale down to zero pods before continuing.

Create a KafkaSource for my-topic by connecting your Kafka topic my-topic to eventinghello:

apiVersion: sources.eventing.knative.dev/v1alpha1
kind: KafkaSource
metadata:
  name: mykafka-source
spec:
  consumerGroup: knative-group
  bootstrapServers: my-cluster-kafka-bootstrap.kafka:9092 
  topics: my-topic 
  sink: 
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: eventinghello
"my-cluster-kafka-bootstrap:9092" can be found via kubectl get -n kafka services or oc get -n kafka services
my-topic was created earlier section when deploying Apache Kafka
This is another example of a direct Source to Sink
The deployment of KafkaSource will result in a new pod prefixed with "mykafka-source".

kubectl

oc

oc -n knativetutorial apply -f mykafka-source.yaml

watch oc get pods

When the KafkaSource is ready it will show the following output:

NAME                                          READY  STATUS   RESTARTS  AGE
mykafka-source-vxs2k-56548756cc-j7m7v         1/1    Running  0         11s
Since we had test messages of "one", "two" and "three" from earlier you might see the eventinghello service awaken to process those messages.

Wait for eventinghello to scale down to zero pods before moving on then push more Kafka messages into my-topic.

$TUTORIAL_HOME/bin/kafka-producer.sh

And then enter the following JSON-formatted messages:

{"hello":"world"}

{"hola":"mundo"}

{"bonjour":"le monde"}

{"hey": "duniya"}
Knative Eventing events through the Kafka Source must be JSON formatted

While making sure to monitor the logs of the eventinghello pod:

stern eventinghello -c user-container

ce-id=partition:1/offset:1
ce-source=/apis/v1/namespaces/kafka/kafkasources/mykafka-source#my-topic
ce-specversion=1.0
ce-time=2020-01-01T01:16:12.886Z
ce-type=dev.knative.kafka.event
content-type=application/json
content-length=17
POST:{"hey": "duniya"}
The sample output has been modified for readability and formatting reasons. You can see the logging output of all your JSON-based event input in the terminal where you are watching the eventinghello logs.

Cleanup
kubectl

oc

oc delete -n knativetutorial  -f mykafka-source.yaml
oc delete -n knativetutorial  -f eventing-hello-sink.yaml
oc delete -n kafka -f kafka-topic-my-topic.yaml


Knative Tutorial
Applying Content Based Routing EIP
At the end of this chapter you will be able to:

How to run integrate Apache Kafka and Camel-K

Apply Content Based Routing (CBR) Enterprise Integration Pattern(EIP)

Apache Camel supports numerous Enterprise Integration Patterns (EIPs) out-of-the-box, you can find the complete list of patterns on the Apache Camel website.

Content Based Router
The Content Based Router examines the message content and routes the message to a different channel based on the data contained in the message. The routing can be based on a number of criteria such as existence of fields, specific field values etc. When implementing a Content Based Router, special caution should be taken to make the routing function easy to maintain as the router can become a point of frequent maintenance. In more sophisticated integration scenarios, the Content Based Router can take on the form of a configurable rules engine that computes the destination channel based on a set of configurable rules. [1]

Application Overview
We will deploy a simple data streaming application that will use Camel-K and Knative to process the incoming data where that processed data is pushed out to to a reactive web application via Server-Sent Events (SSE) as shown below:

cbr app overview
Figure 1. Application Overview
The application has following components,

Data Producer: The Camel-K integration application, that will produce data simulating the streaming data by sending the data to Apache Kafka

Data Processor: The Camel-K integration application, that will process the streaming data from Kafka and send the default Knative Eventing Broker

Event Subscriber(Fruits UI): The Quarkus Java application, that will display the processed data from the Data Processor

Event Trigger: This is Knative Event Trigger that apply a filter on the processed data, to send to the Event Subscriber

The upcoming recipes will deploy these individual components and finally we test the integration by wiring them all together.

Prerequisite
The following checks ensure that each chapter exercises are done with the right environment settings.

Minikube

Minishift

Set your local docker to use minishift docker daemon

eval $(minishift docker-env)

OpenShift CLI should be v3.11.0+

eval $(minishift oc-env)
oc version

Make sure to be on knativetutorial OpenShift project

oc project -q

If you are not on knativetutorial project, then run following command to change to knativetutorial project:

oc project knativetutorial

Just make sure:

Review Knative Eventing module to refresh the concepts

Apache Kafka my-cluster is running

Finally navigate to the tutorial chapter’s folder advanced/camel-k:

cd $TUTORIAL_HOME/advanced/camel-k

Label Namespace
The knativetutorial namespace is labeled to inject Knative Eventing’s default Broker filter and ingress deployment.

kubectl

oc

oc label namespace knativetutorial knative-eventing-injection=enabled

If the label is set correctly on the knativetutorial namespace then you should see the following pods corresponding to Knative Eventing’s default broker’s filter and ingress:

kubectl

oc

watch oc get pods -n knativetutorial

NAME                                       READY   STATUS      AGE
camel-k-operator-5d74595cdf-4v9qz          1/1     Running     3h59m
default-broker-filter-c6654bccf-zkw7s      1/1     Running     59s
default-broker-ingress-857698bc5b-r4zmf    1/1     Running     59s
Deploy Data Producer
Knative Camel-K integration called fruits-producer which will use a public fruits API to retrieve the information about fruits and stream the data to Apache Kafka. The fruits-producer service retrieves the data from the fruits API, splits it using the Split EIP and then sends the data to a Kafka topic called fruits.

Fruits producer
- from:
    uri: "knative:endpoint/fruits-producer"
    steps:
      - set-header:
          name: CamelHttpMethod
          constant: GET
      - to: "http:fruityvice.com/api/fruit/all?bridgeEndpoint=true" 
      - split:
          jsonpath: "$.[*]" 
      - marshal:
          json: {}
      - log:
          message: "${body}"
      - to: "kafka:fruits?brokers=my-cluster-kafka-bootstrap.kafka:9092" 
Call the external REST API http://fruityvice.com to get the list of fruits to simulate the data streaming
Apply the Camel Split EIP to split the JSON array to individual records
Send the processed data i.e. the individual fruit record as JSON to Apache Kafka Topic
Run the following command to deploy the fruit-producer integration:

kamel -n knativetutorial run \
 --wait \
 --dependency camel:log \
 --dependency camel:jackson \
 --dependency camel:jsonpath \
 eip/fruits-producer.yaml

The service deployment may take several minutes to become available, to monitor the status:

watch kubectl get pods or watch oc get pods

watch kamel get

watch kubectl get ksvc or watch oc get ksvc

kubectl

oc

watch oc -n knativetutorial get pods

A successful deploy will show the following pods:

fruits-producer service pods
NAME                                                READY   STATUS    AGE
camel-k-operator-5d74595cdf-4v9qz                   1/1     Running   4h4m
default-broker-filter-c6654bccf-zkw7s               1/1     Running   5m
default-broker-ingress-857698bc5b-r4zmf             1/1     Running   5m
fruits-producer-nfngm-deployment-759c797c44-d6r52   2/2     Running   70s
kubectl

oc

oc -n knativetutorial get ksvc

fruit-producer Knative services
NAME              URL                                            READY
event-display     http://event-display.knativetutorial.example.com     True
fruits-producer   http://fruits-producer.knativetutorial.example.com   True
Verify Fruit Producer
Run the $TUTORIAL_HOME/bin/call.sh with the parameter fruits-producer.

$TUTORIAL_HOME/bin/call.sh fruits-producer ''

Open a new terminal and run the start Kafka consumer using the script $TUTORIAL_HOME/bin/kafka-consumer.sh with parameter fruits:

$TUTORIAL_HOME/bin/kafka-consumer.sh fruits

If the fruit-producer executed well then you should the Kafka Consumer terminal show something like:

{"genus":"Citrullus","name":"Watermelon","id":25,"family":"Cucurbitaceae","order":"Cucurbitales","nutritions":{"carbohydrates":8,"protein":0.6,"fat":0.2,"calories":30,"sugar":6}}
Since the fruits API returns a static set of fruit data consistently, you can call it as needed to simulate data streaming and it will always be the same data.

Deploy Data Processor
Let us now deploy a CamelSource called fruits-processor, that can handle and process the streaming data from the Kafka topic fruits. The fruits-processor CamelSource applies the Content Based Router EIP to process the data. The following listing describes the fruits-processor CamelSource:

CamelSource fruits-processor
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: CamelSource
metadata:
  name: fruits-processor
spec:
  source:
    integration:
      dependencies:
        - camel:log
        - camel:kafka
        - camel:jackson
        - camel:bean
    flow:
      from:
        uri: "kafka:fruits?brokers=my-cluster-kafka-bootstrap.kafka:9092" 
        steps:
          - log:
              message: "Received Body ${body}"
          - unmarshal:
              json: {} 
          - choice: 
              when:
                - simple: "${body[nutritions][sugar]} <= 5"
                  steps:
                    - remove-headers: "*"
                    - marshal:
                        json: {}
                    - set-header: 
                        name: ce-type
                        constant: low-sugar
                    - set-header:
                        name: fruit-sugar-level
                        constant: low
                    - to: "log:low?showAll=true&multiline=true"
                - simple: "${body[nutritions][sugar]} > 5 || ${body[nutritions][sugar]} <= 10"
                  steps:
                    - remove-headers: "*"
                    - marshal:
                        json: {}
                    - set-header:
                        name: ce-type
                        constant: medium-sugar
                    - set-header:
                        name: fruit-sugar-level
                        constant: medium
                    - to: "log:medium?showAll=true&multiline=true"
              otherwise:
                steps:
                  - remove-headers: "*"
                  - marshal:
                      json: {}
                  - set-header:
                      name: ce-type
                      constant: high-sugar
                  - set-header:
                      name: fruit-sugar-level
                      constant: high
                  - to: "log:high?showAll=true&multiline=true"
  sink: 
    ref:
      apiVersion: eventing.knative.dev/v1alpha1
      kind: Broker
      name: default
The Camel route connects to Apache Kakfa broker and the topic fruits.
Once the data is received it is transformed into a JSON payload.
The Content Based Router pattern using the Choice EIP. In the data processing you classify the fruits as low (sugar <= 5), medium(sugar between 5 to 10) and high(sugar > 10) based on the sugar level present in their nutritions data.
Based on the data classification you will be setting the CloudEvents type header to be low-high, medium-sugar and high-sugar. This header is used as one of the filter attributes in the Knative Eventing Trigger.
The last step is to send the processed data to the Knative Eventing Broker named default.
kubectl

oc

oc apply -n knativetutorial -f eip/fruits-processor.yaml

As the Camel-K controller takes few minutes to deploy the CamelSource, you can watch the pods of the knativetutorial namespace for its status:

kubectl

oc

watch oc -n knativetutorial get pods

fruit-processor Knative service pods
NAME                                      READY   STATUS    AGE
camel-k-operator-5d74595cdf-4v9qz         1/1     Running   4h17m
default-broker-filter-c6654bccf-zkw7s     1/1     Running   18m
default-broker-ingress-857698bc5b-r4zmf   1/1     Running   18m
fruits-processor-h45f7-6fdfd74cf9-nmfkn   1/1     Running   29s
A successful fruit-processor is deploy will show the following pods in knativetutorial

Wondering why fruit-producer is not listed ?

fruit-producer is a Knative service, hence it wil be scaled down to zero in 60-90 seconds.

kubectl

oc

watch oc get  -n knativetutorial camelsources

When the CamelSource deployment is successful you will see it in READY state as shown:

NAME               READY   REASON   AGE
fruits-processor   True             2m22s
Deploy Event Subscriber
Let us now deploy a Reactive Web application called fruit-events-display`. It is a Quarkus Java application, that will update UI(reactively) as and when it receives the processed data from the Knative Eventing backend.

You can deploy the fruit-events-display application using the command:

kubectl

oc

oc apply -n knativetutorial \
  -f $TUTORIAL_HOME/install/utils/fruit-events-display.yaml

Verify if the fruit-events-display application is up and running:

kubectl

oc

watch oc -n knativetutorial get pods

Once the fruit-events-display is running you will see the following pods in the knativetutorial:

Pods list
NAME                                       READY   STATUS    AGE
camel-k-operator-5d74595cdf-4v9qz          1/1     Running   4h21m
default-broker-filter-c6654bccf-zkw7s      1/1     Running   22m
default-broker-ingress-857698bc5b-r4zmf    1/1     Running   22m
fruit-events-display-8d47bc98f-6r7zt       1/1     Running   15s
fruits-processor-h45f7-6fdfd74cf9-nmfkn    1/1     Running   4m12s
The web fruit-events-display application will refresh its UI as and when it receives the processed data, you need you open the web application in your browser.

Minikube

OpenShift

oc expose -n knativetutorial service fruit-events-display

Once you have exposed the service, you can open the OpenShift route in the web browser:

oc get -n knativetutorial route fruit-events-display

The fruit-events-display UI will be empty as shown below:

cbr app ui empty
Figure 2. Fruit events Display Web Application
Apply Knative Filter
As a last step let us now deploy a Knative Event Trigger called fruits-trigger. The trigger consumes the events from the Knative Event Broker named default, when the fruit event is received it will dispatch the events to the subscriber — that is fruit-events-display service --.

apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: sugary-fruits
spec:
  broker: default 
  filter: 
    attributes:
      type: low-sugar
  subscriber: 
    ref:
      apiVersion: v1
      kind: Service
      name: fruit-events-display
The Knative Event Broker that this Trigger listens to for Knative events. Events originate from the CamelSource called fruits-processor and are sent to the Knative Eventing Broker named default.
The filter attribute restricts the events that fruit-events-display will receive. In this example, it is configured to filter the events for the type low-sugar. You could also use the other classifications of fruits such as medium-sugar or high-sugar.
Set the subscriber as the fruit-events-display Kubernetes service to receive the filtered event data.
You can deploy the Knative Event Trigger using the following command:

kubectl

oc

oc apply -n knativetutorial -f eip/sugary-fruits.yaml

Let us check the status of the Trigger using the command kubectl -n knativetutorial get triggers which should return one trigger called sugary-fruits with ready state as shown below.

kubectl

oc

oc -n knativetutorial get triggers

As the trigger will dispatch its filtered event to fruit-events-display , the subscriber URI of the Trigger will be that of fruit-events-display service.

NAME           READY BROKER    SUBSCRIBER_URI
sugary-fruits  True  default   http://fruits-events-display.knativetutorial.svc.cluster.local/
Verify end to end
Now that we have all the components for the Application Overview, let us verify the end to end flow:

To verify the data flow and processing call the fruits-producer service using the script $TUTORIAL_HOME/bin/call.sh with parameters fruits-producer and ''.

$TUTORIAL_HOME/bin/call.sh fruits-producer ''

Assuming everything worked well, you should see the low-sugar fruits listed in the fruits-event-display as shown below:

cbr app ui with data
Figure 3. Fruit events
Cleanup
kubectl

oc

kamel delete  -n knativetutorial fruit-producer
oc delete  -n knativetutorial -f -f eip/fruits-processor.yaml
oc delete -n knativetutorial -f $TUTORIAL_HOME/install/utils/fruit-events-display.yaml
