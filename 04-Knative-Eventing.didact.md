Knative Tutorial
Knative Eventing
CloudEvents
CloudEvents is a specification for describing event data in a common way. An event might be produced by any number of sources (e.g. Kafka, S3, GCP PubSub, MQTT) and as a software developer, you want a common abstraction for all event inputs.

Usage Patterns
There are three primary usage patterns with Knative Eventing:

Source to Sink
Source to Service provides the simplest getting started experience with Knative Eventing. It provides single Sink — that is, event receiving service --, with no queuing, backpressure, and filtering. The Source to Service does not support replies, which means the response from the Sink service is ignored. As shown in the Figure 4-1, the responsibility of the Event Source it just to deliver the message without waiting for the response from the Sink, hence I think it will be apt to compare Source to Sink to fire and forget messaging pattern.

Source to Sink
Figure 1. Source to Sink
Channel and Subscription
With the Channel and Subscription, the Knative Eventing system defines a Channel, which can connect to various backends such as In-Memory, Kafka and GCP PubSub for sourcing the events. Each Channel can have one more subscribers in the form of Sink services as shown in Figure 4-2, which can receive the event messages and process them as needed. Each message from the Channel is formatted as CloudEvent and sent further up in the chain to other Subscribers for further processing. The Channels and Subscription usage pattern does not have the ability to filter messages.

Channels and Subscriptions
Figure 2. Channels and Subscriptions
Broker and Trigger
The Broker and Trigger are similar to Channel and Subscription, except that they support filtering of events. Event filtering is a method that allows the subscribers to show an interest on certain set of messages that flows into the Broker. For each Broker, Knative Eventing will implicitly create a Knative Eventing Channel. As shown in Figure 4-3, the Trigger gets itself subscribed to the Broker and applies the filter on the messages on its subscribed broker. The filters are applied on the on the Cloud Event attributes of the messages, before delivering it to the interested Sink Services(subscribers).

Brokers and Triggers
Figure 3. Brokers and Triggers

Knative Tutorial
At the end of this chapter you will know and understand:

What is an event source?

What is a channel?

What is a subscriber?

What is a trigger?

What is a broker?

How to make a Knative serving service receive an event?

How to make a service a subscriber of an event?

Prerequisite
The following checks ensure that each chapter exercises are done with the right environment settings.

Kubernetes

OpenShift

OpenShift CLI should be v4.1+

oc version

The output should be like

oc version
Client Version: openshift-clients-4.3.0-201910250623-88-g6a937dfe
Kubernetes Version: v1.16.2
Make sure to be on knativetutorial OpenShift project

oc project -q

If you are not on knativetutorial project, then run following command to change to knativetutorial project:

oc project knativetutorial

Before beginning to run the exercises, navigate to the tutorial chapter’s eventing folder:

cd $TUTORIAL_HOME/eventing

Watching Logs
In the eventing related subsections of this tutorial, event sources are configured to emit events every minute with a CronJobSource or with a ContainerSource.

The logs could be watched using the command:

kubectl

oc

oc logs -n knativetutorial -f <pod-name> -c user-container
Using stern with the command stern -n knativetutorial event-greeter, to filter the logs further add -c user-container to the stern command.

stern -n knativetutorial -c user-container event-greeter

Eventing Source to Sink
Before beginning to run the exercises, navigate to the tutorial chapter’s eventing folder:

cd $TUTORIAL_HOME/eventing

Event Source
Knative Eventing Sources are software components that emit events. The job of a Source is to connect to, drain, capture and potentially buffer events; often from an external system and then relay those events to the Sink.

Knative Eventing Sources installs the following four sources out-of-the-box:

kubectl api-resources --api-group='sources.eventing.knative.dev'

NAME              APIGROUP                      NAMESPACED   KIND
apiserversources  sources.eventing.knative.dev  true         ApiServerSource
containersources  sources.eventing.knative.dev  true         ContainerSource
cronjobsources    sources.eventing.knative.dev  true         CronJobSource
sinkbindings      sources.eventing.knative.dev  true         SinkBinding
eventinghello-source.yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: CronJobSource 
metadata:
  name: eventinghello-cronjob-source
spec: 
  schedule: "*/2 * * * *"
  data: '{"key": "every 2 mins"}'
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: eventinghello
The type of event source, the eventing system deploys a bunch of sources out of the box and it also provides way to deploy custom resources
spec will be unique per source, per kind
Referencing the Event Sink
Knative Eventing Sink is how you specify the event receiver — that is the consumer of the event--. Sinks can be invoked directly in a point-to-point fashion by referencing them via the Event Source’s sink as shown below:

eventinghello-source.yaml
apiVersion: sources.eventing.knative.dev/v1
kind: CronJobSource
metadata:
  name: event-greeter-cronjob-source
spec:
  schedule: "*/2 * * * *"
  data: '{"message": "Thanks for doing Knative Tutorial"}'
  sink:  
    apiVersion: serving.knative.dev/v1 
    kind: Service
    name: eventinghello 
sink can target any Kubernetes Service or
a Knative Service
Deployed as "eventinghello"
Event Source can define the attributes that it wishes to receive via the spec. In the above example it defines schedule(the cron expression) and data that will be sent as part of the event.

When you watch logs, you will notice this data being delivered to the service.

Run the following commands to create the event source resources:

Create Event Source
kubectl

oc

oc apply -n knativetutorial -f eventinghello-source.yaml

Verification
kubectl

oc

oc -n knativetutorial get \
  cronjobsources.sources.eventing.knative.dev \
  event-greeter-cronjob-source

Running the above command should return the following result:

NAME                       AGE
event-greeter-cronjob-source  39s
The cronjob source also creates a service pod,

kubectl

oc

oc -n knativetutorial get pods

The above command will return an output like,

NAME                                                          READY     STATUS    RESTARTS   AGE
cronjob-event-greeter-cronjob-source-4v9vq-6bff96b58f-tgrhj   2/2       Running   0          6m
Create Sink Service
Run the following command to create the Knative service that will be used as the subscriber for the cron events:

eventing-hello-sink.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: eventinghello
spec:
  template:
    metadata:
      name: eventinghello-v1
      annotations:
        autoscaling.knative.dev/target: "1"
    spec:
      containers:
      - image: quay.io/burrsutter/eventinghello:0.0.1
Deploy Sink Service
Run the following commands to create the service:

kubectl

oc

oc apply -n knativetutorial -f eventing-hello-sink.yaml

You can watch logs to see the cron job source sending an event every 1 minute.

See what you have deployed
sources
kubectl

oc

oc --namespace knativetutorial get cronjobsources.sources.eventing.knative.dev event-greeter-cronjob-source

services
kubectl

oc

oc --namespace knativetutorial  get \
  services.serving.knative.dev eventinghello

Cleanup
kubectl

oc

oc -n knativetutorial delete -f eventinghello-source.yaml
oc -n knativetutorial delete -f eventing-hello-sink.yaml

Channel and Subscribers
Channels
Channels are an event forwarding and persistence layer where each channel is a separate Kubernetes Custom Resource. A Channel may be backed by Apache Kafka or InMemoryChannel. This recipe focuses on InMemoryChannel.

Subscriptions
Subscriptions are how you register your service to listen to a particular channel.

Channel(Sink)
The channel or sink is an interface between the event source and the subscriber. The channels are built in to store the incoming events and distribute the event data to the subscribers. When forwarding event to subscribers the channel transforms the event data as per CloudEvent specification.

Create Event Channel
channel.yaml
apiVersion: messaging.knative.dev/v1alpha1
kind: Channel
metadata:
  name: eventinghello-ch 
The name of the channel. Knative makes it addressable, i.e. resolveable to a target (a consumer service)
Run the following commands to create the channel:

kubectl

oc

oc apply -n knativetutorial -f channel.yaml

Verification
kubectl

oc

oc -n knativetutorial get channels.eventing.knative.dev

Running the above command should return the following result:

NAME             READY URL
eventinghello-ch True  http://eventinghello-ch-kn-channel.knativetutorial.svc.cluster.local
Event Source
The event source listens to external events e.g. a kafka topic or for a file on a FTP server. It is responsible to drain the received event(s) along with its data to a configured sink.

Create Event Source
event-source.yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: CronJobSource
metadata:
  name: my-cjs
spec:
  schedule: "*/2 * * * *"
  data: '{"message": "From CronJob Source"}'
  sink:
   ref:
    apiVersion: messaging.knative.dev/v1alpha1 
    kind: Channel 
    name: eventinghello-ch
The Channel API is in api-group messaging.eventing.knative.dev
Kind is Channel instead of direct to a specific service; default is InMemoryChannel implementation
Run the following commands to create the event source resources:

kubectl

oc

oc apply -n knativetutorial -f event-source.yaml

Verification
kubectl

oc

oc -n knativetutorial get cronjobsources.sources.eventing.knative.dev

Running the above command should return the following result:

NAME     READY   AGE
my-cjs   True    8s
The cronjob source also creates a service pod,

kubectl

oc

oc -n knativetutorial get pods

The above command will return an output like,

NAME                                                          READY     STATUS    RESTARTS   AGE
cronjob-event-greeter-cronjob-source-4v9vq-6bff96b58f-tgrhj   2/2       Running   0          6m
Event Subscriber
The event subscription is responsible of connecting the channel(sink) with the service. Once a service connected to a channel it starts receiving the events (cloud events).

Create Subscriber Services
channel-subscriber.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: eventinghelloa
spec:
  template:
    metadata:
      name: eventinghelloa-v1 
      annotations:
        autoscaling.knative.dev/target: "1"
    spec:
      containers:
      - image: quay.io/rhdevelopers/eventinghello:0.0.1
The string of eventinghelloa will help you identify this particular service.
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: eventinghellob
spec:
  template:
    metadata:
      name: eventinghellob-v1 
      annotations:
        autoscaling.knative.dev/target: "1"
    spec:
      containers:
      - image: quay.io/rhdevelopers/eventinghello:0.0.1
The string of eventinghellob will help you identify this particular service.
kubectl

oc

oc apply -n knativetutorial -f eventing-helloa-sink.yaml

kubectl

oc

oc apply -n knativetutorial -f eventing-hellob-sink.yaml

Create Channel Subscribers
Now create the appropriate Subscription for eventinghelloa to the Channel eventinghello-ch:

apiVersion: messaging.knative.dev/v1alpha1
kind: Subscription
metadata:
  name: eventinghelloa-sub
spec:
  channel:
    apiVersion: messaging.knative.dev/v1alpha1
    kind: Channel
    name: eventinghello-ch
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: eventinghelloa
And create the appropriate Subscription for eventinghellob to the Channel eventinghello-ch:

apiVersion: messaging.knative.dev/v1alpha1
kind: Subscription
metadata:
  name: eventinghellob-sub
spec:
  channel:
    apiVersion: messaging.knative.dev/v1alpha1
    kind: Channel
    name: eventinghello-ch
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: eventinghellob
kubectl

oc

oc apply -n knativetutorial -f eventing-helloa-sub.yaml

kubectl

oc

oc apply -n knativetutorial -f eventing-hellob-sub.yaml

Verification
kubectl

oc

oc -n knativetutorial get subscriptions.eventing.knative.dev

Running the above command should return the following result:

NAME                       AGE
event-greeter-subscriber  39s
If you wait approximately 2 minutes for the CronJobSource then you will see both eventinghelloa and eventinghellob begin to run in the knativetutorial.

Watch pods in the knativetutorial
NAME                                                      READY STATUS  AGE
cronjobsource-my-cjs-93544f14-2bf9-11ea-83c7-08002737670c 1/1   Running 2m15s
eventinghelloa-1-deployment-d86bf4847-hvbk6               2/2   Running 5s
eventinghellob-1-deployment-5c986c7586-4clpb              2/2   Running 5s
See what you have deployed
channel
kubectl

oc

oc --namespace knativetutorial get channels.eventing.knative.dev ch-event-greeter

sources
kubectl

oc

oc --namespace knativetutorial get cronjobsources.sources.eventing.knative.dev event-greeter-cronjob-source

subscription
kubectl

oc

oc --namespace knativetutorial get subscriptions.eventing.knative.dev event-greeter-subscriber

Add -oyaml to the above commands to get more details about each object that were queried for.
Cleanup
kubectl

oc

oc -n knativetutorial delete -f eventing-helloa-sink.yaml
oc -n knativetutorial delete -f eventing-helloa-sub.yaml
oc -n knativetutorial delete -f eventing-hellob-sink.yaml
oc -n knativetutorial delete -f eventing-hellob-sub.yaml
oc -n knativetutorial delete -f eventinghello-source-ch.yaml


Triggers and Brokers
Use the Knative Eventing Broker and Trigger Custom Resources to allow for CloudEvent attribute filtering.

Broker
By labeling knativetutorial namespace with knative-eventing-injection=enabled as shown below, will make Knative Eventing to deploy a default Knative Eventing Broker and its related Ingress :

kubectl label namespace knativetutorial knative-eventing-injection=enabled

Verify that the default broker is running:

kubectl

oc

watch oc --namespace knativetutorial get broker

Running command above should show an output like:

NAME     READY REASON URL                                                 AGE
default  True         http://default-broker.knativetutorial.svc.cluster.local   22s
This will also start two additional pods namely default-broker-filter and default-broker-ingress :

watch oc get pods

Running command above should show the following pods in knativetutorial:

NAME                                         READY STATUS      AGE
default-broker-filter-c6654bccf-qb272        1/1   Running     18s
default-broker-ingress-7479966dc7-99xvm      1/1   Running     18s
oc label namespace knativetutorial knative-eventing-injection=enabled

Service
Now, that you have the broker configured, you need to create the sinks eventingaloha and eventingbonjour, which will receive the filtered events.

eventing-aloha-sink.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: eventingaloha
spec:
  template:
    metadata:
      name: eventingaloha-v1
      annotations:
        autoscaling.knative.dev/target: "1"
    spec:
      containers:
      - image: quay.io/burrsutter/eventinghello:0.0.1
eventing-bonjour-sink.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: eventingbonjour
spec:
  template:
    metadata:
      name: eventingbonjour-v1
      annotations:
        autoscaling.knative.dev/target: "1"
    spec:
      containers:
      - image: quay.io/burrsutter/eventinghello:0.0.1
The image being used by both of these services is identical. However, the difference in name aloha vs bonjour will make obvious which one is receiving a particular event.

Deploy Service
Run the following commands to deploy the eventingaloha and eventingbonjour services:

kubectl

oc

oc apply -n knativetutorial -f eventing-aloha-sink.yaml

kubectl

oc

oc apply -n knativetutorial -f eventing-bonjour-sink.yaml

Wait approximately 60 seconds for eventingaloha and eventingbonjour to terminate, scale-down to zero before proceeding.

Trigger
Now create the the trigger for eventingaloha that will associate the filtered events to a service:

trigger-helloaloha.yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: helloaloha
spec:
  filter:
    attributes:
      type: greeting 
  subscriber:
    ref:
     apiVersion: serving.knative.dev/v1
     kind: Service
     name: eventingaloha
The type is the CloudEvent type that is mapped to the ce-type HTTP header. A Trigger can filter by CloudEvent attributes such as type, source or extension.
Run the following commands to create the trigger:

kubectl

oc

oc apply -n knativetutorial -f trigger-helloaloha.yaml

Now create the the trigger for eventingbonjour that will associate the filtered events to a service:

trigger-hellobonjour.yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: hellobonjour
spec:
  filter:
    attributes:
      type: greeting
  subscriber:
    ref:
     apiVersion: serving.knative.dev/v1
     kind: Service
     name: eventingbonjour
Run the following commands to create the trigger:

kubectl

oc

oc apply -n knativetutorial -f trigger-hellobonjour.yaml

Verify that your triggers are ready:

kubectl

oc

oc --namespace knativetutorial  get triggers.eventing.knative.dev helloaloha hellobonjour

The command should show the following output:

NAME         READY BROKER  SUBSCRIBER_URI                                      AGE
helloaloha   True  default http://eventingaloha.knativetutorial.svc.cluster.local   24s
hellobonjour True  default http://eventingbonjour.knativetutorial.svc.cluster.local 48s
See what you have deployed
sources
kubectl

oc

oc --namespace knativetutorial get containersources.sources.eventing.knative.dev heartbeat-event-source

services
kubectl

oc

oc --namespace knativetutorial  get \
  services.serving.knative.dev eventinghello

Verification
kubectl

oc

Pull out the subscriberURI for eventhingaloha:

oc get trigger helloaloha -o jsonpath='{.status.subscriberURI}'

The command should show the output as: http://eventingaloha.knativetutorial.svc.cluster.local

Pull out the subscriberURI for eventhingbonjour:

oc get trigger hellobonjour -o jsonpath='{.status.subscriberURI}'

The command should show the output as:

http://eventingbonjour.knativetutorial.svc.cluster.local

As well as broker’s subscriberURI:

oc get broker default -o jsonpath='{.status.address.url}'

The command should show the output as: http://default-broker.knativetutorial.svc.cluster.local

You should notice that the subscriberURIs are Kubernetes services with the suffix of knativetutorial.svc.cluster.local. This means they can be interacted with from another pod within the Kubernetes cluster.

Now that you have setup the Broker and Triggers you need to send in some test messages to see the behavior.

First start streaming the logs for the event consumers:

$ stern eventing -c user-container
Then create a pod for using the curl command:

apiVersion: v1
kind: Pod
metadata:
  labels:
    run: curler
  name: curler
spec:
  containers:
  - name: curler
    image: fedora:29 
    tty: true
You can use any image that includes a curl command.
Then exec into the curler pod:

kubectl

oc

Create the curler pod:

oc -n knativetutorial apply -f curler.yaml

Exec into the curler pod:

oc -n knativetutorial exec -it curler -- /bin/bash

Using the curler pod’s shell, curl the subcriberURI for eventingaloha:

$ curl -v "http://eventingaloha.knativetutorial.svc.cluster.local" \
-X POST \
-H "Ce-Id: say-hello" \
-H "Ce-Specversion: 1.0" \
-H "Ce-Type: aloha" \
-H "Ce-Source: mycurl" \
-H "Content-Type: application/json" \
-d '{"key":"from a curl"}'
You will then see eventingaloha will scale-up to respond to that event:

kubectl

oc

watch oc get pods

The command above should show the following output:

NAME                                        READY STATUS  AGE
curler                                      1/1   Running 59s
default-broker-filter-c6654bccf-vxm5m       1/1   Running 11m
default-broker-ingress-7479966dc7-pvtx6     1/1   Running 11m
eventingaloha-1-deployment-6cdc888d9d-9xnnn 2/2   Running 30s
Next, curl the subcriberURI for eventingbonjour:

$ curl -v "http://eventingbonjour.knativetutorial.svc.cluster.local" \
-X POST \
-H "Ce-Id: say-hello" \
-H "Ce-Specversion: 1.0" \
-H "Ce-Type: bonjour" \
-H "Ce-Source: mycurl" \
-H "Content-Type: application/json" \
-d '{"key":"from a curl"}'
And you will see the eventingbonjour pod scale up:

kubectl

oc

watch oc get pods

The command above should show the following output:

NAME                                         READY STATUS  AGE
curler                                       1/1   Running 82s
default-broker-filter-c6654bccf-vxm5m        1/1   Running 11m
default-broker-ingress-7479966dc7-pvtx6      1/1   Running 11m
eventingaloha-1-deployment-6cdc888d9d-9xnnn  2/2   Running 53s
eventingbonjour-1-deployment-fc7858b5b-s9prj 2/2   Running 5s
Now, trigger both eventingaloha and eventingbonjour by curling the subcriberURI for the broker:

curl -v "http://default-broker.knativetutorial.svc.cluster.local" \
-X POST \
-H "Ce-Id: say-hello" \
-H "Ce-Specversion: 1.0" \
-H "Ce-Type: greeting" \
-H "Ce-Source: mycurl" \
-H "Content-Type: application/json" \
-d '{"key":"from a curl"}'

"Ce-Type: greeting" is the key to insuring that both aloha and bonjour respond to this event

And by watching the knativetutorial namespace, you will see both eventingaloha and eventingbonjour will come to life:

kubectl

oc

watch oc get pods

The command above should show the following output:

NAME                                         READY STATUS  AGE
curler                                       1/1   Running 3m21s
default-broker-filter-c6654bccf-vxm5m        1/1   Running 13m
default-broker-ingress-7479966dc7-pvtx6      1/1   Running 13m
eventingaloha-1-deployment-6cdc888d9d-nlpm8  2/2   Running 6s
eventingbonjour-1-deployment-fc7858b5b-btdcr 2/2   Running 6s
You can experiment by using different type filters in the Subscription to see how the different subscribed services respond. Filters may use an CloudEvent attribute for its criteria.

Cleanup
kubectl

oc

oc -n knativetutorial delete -f eventing-aloha-sink.yaml
oc -n knativetutorial delete -f eventing-bonjour-sink.yaml
oc -n knativetutorial delete -f trigger-helloaloha.yaml
oc -n knativetutorial delete -f trigger-hellobonjour.yaml
oc -n knativetutorial delete -f curler.yaml