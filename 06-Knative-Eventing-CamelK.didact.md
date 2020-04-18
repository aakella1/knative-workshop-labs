Make sure to be on knativetutorial OpenShift project

oc project -q

If you are not on knativetutorial project, then run following command to change to knativetutorial project:

oc project knativetutorial

Install Camel-k
Download the latest camel-k release from here. Extract the content and add the binary kamel to the PATH.

Camel-K is installed using its operator.Use the Operator Hub in OpenShift webconsole to install the Camel-K operator.

Once the operator is deployed successfully, run the following command to setup Camel-K in the namespace:

kamel install --cluster-setup --skip-operator-setup
In OpenShift, the kamel install command will not install Camel-K operator in each namespace, rather its done one time at cluster level when installing the Operator.

Configure Camel-k to build faster
Camel-K uses Apache Maven to build the integration kits and its related containers. The Apache Maven settings for Camel K are stored in a ConfigMap camel-k-maven-settings in the knativetutorial namespace. One of the ways to make the build faster is by using a maven repository manager such as Sonatype Nexus, the repository manager helps in caching the maven artifacts from remote repositories and serves them from local the subsequent times they are asked to be downloaded.

Edit the ConfigMap using the command:

oc edit  -n knativetutorial cm camel-k-maven-settings

The command above by default opens the ConfigMap YAML in vi. We can use the environment variable KUBE_EDITOR, to allow us to edit the YAML with the editor of our choice. For example setting export KUBE_EDITOR=code -w, will make the kubectl edit commands to open the Kubernetes resource YAML in vscode.

The following listing shows the Camel-K maven settings configured to use a Sonatype Nexus repository as its mirror:

Using Sonatype Nexus mirror
apiVersion: v1
data:
  settings.xml: |-
    <?xml version="1.0" encoding="UTF-8"?>
    <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
https://maven.apache.org/xsd/settings-1.0.0.xsd">
      <localRepository></localRepository>
      <mirrors>
        <mirror>
          <id>central</id>
          <name>central</name>
          <url>http://nexus:8081/nexus/content/groups/public</url> 
          <mirrorOf>*</mirrorOf>
        </mirror>
      </mirrors>
      ...
    </settings>
kind: ConfigMap
metadata:
  labels:
    app: camel-k
  name: camel-k-maven-settings
  namespace: knativetutorial
This repository address needs to be updated as per your cluster setting. In example above the installed the Sonatype Nexus in the knativetutorial.

Camel-K Basics
At the end of this chapter you will be able to:

Understand Camel-K deployment

How to create Camel-K integration

How to run using development mode

How to add dependencies to Camel-K

How to run your Camel-K integration in serverless mode

Prerequisite
The following checks ensure that each chapter exercises are done with the right environment settings.


Make sure to be on knativetutorial OpenShift project

oc project -q

If you are not on knativetutorial project, then run following command to change to knativetutorial project:

oc project knativetutorial

Navigate to the tutorial chapter’s folder advanced/camel-k:

cd $TUTORIAL_HOME/advanced/camel-k

Deploy Camel-K integration
Camel-K helps you in writing the Apache Camel integrations using Java, JS, XML and as YAML.

For all the integration exercises, we will be using YAML DSL.

Apache Camel YAML DSL is still under active development but using this DSL will give you a consistent resource definition across Kubernetes, Knative and Camel-K

Let us analyze our first Camel-K integration before running it. A Camel-K integration resource is an array of one flow or multiple route definitions. The following listing shows you simple timer integration with just one route:

Camel K integration - greeter
- from:
    uri: "timer:tick" 
    parameters: 
      period: "10s"
    steps: 
      - set-body: 
          constant: "Welcome to Apache Camel K"
      - set-header: 
          name: ContentType
          simple: text/plain
      - transform: 
          simple: "${body.toUpperCase()}"
      - to: 
          uri: "log:info?multiline=true&showAll=true"
The Apache Camel producer URI, in this case it is the timer component.
The parameters allows to specify the configurable properties of the component. In this case the timer component needs to tick every 10 seconds.
The steps defines the flow of Camel exchange(IN). Each Camel K integration should have at least one step defined.
Sets the body of the Camel exchange(OUT), a constant value of "Welcome to Apache Camel K"
It is possible to set headers as part of the step, this sets the ContentType header with its value text/plain.
It is possible to apply transformations as part of a step. This applies a simple transformation of converting the exchange OUT body to uppercase.
In the end you send the processed exchange(OUT) to its desired destination, here we simply log it out.
It is possible have any number of steps as needed for an integration based on your use case. In the later sections of this chapter you will deploy multi-step based integration examples.

kamel CLI tool is used to deploy the integrations. Run the following command to

Deploy the greeter integration
kamel run --dev --dependency 'camel:log' get-started/timed-greeter.yaml

A typical Camel K integration deployment will take approximately 2-5 minutes, as it involves multiple steps such as:

Building an integration kit(camel-k-kit) which builds the container image with all the required Camel modules downloaded and added to classpath within the container image.

If using Knative then deploy as a Knative Service

Run the container image as a Kubernetes pod and start the Camel context

Once the integration is built, you sill see the terminal populated with logs from the integration like:

timed-greeter logs
# kamel run --dev --dependency 'camel:log' get-started/timed-greeter.yaml
...
[1] 2020-01-13 03:25:28.548 INFO  [Camel (camel-k) thread #1 - timer://tick] info - Exchange[
[1]   Id: ID-timed-greeter-57b4d49974-vg859-1578885868551-0-13
[1]   ExchangePattern: InOnly
[1]   Properties: {CamelCreatedTimestamp=Mon Jan 13 03:25:28 UTC 2020, CamelExternalRedelivered=false, CamelMessageHistory=[DefaultMessageHistory[routeId=route1, node=setBody1], DefaultMessageHistory[routeId=route1, node=setHeader1], DefaultMessageHistory[routeId=route1, node=transform1], DefaultMessageHistory[routeId=route1, node=to1]], CamelTimerCounter=7, CamelTimerFiredTime=Mon Jan 13 03:25:28 UTC 2020, CamelTimerName=tick, CamelTimerPeriod=10000, CamelToEndpoint=log://info?multiline=true&showAll=true}
[1]   Headers: {ContentType=text/plain, firedTime=Mon Jan 13 03:25:28 UTC 2020}
[1]   BodyType: String
[1]   Body: WELCOME TO APACHE CAMEL K
[1] ]
If you are not using maven repository manager or it takes long time to download maven artifacts, your earlier command kamel run --dev .. will report a failure. In those cases, run the command kamel get to see the status of the integration. Once you see the timed-greeter pod running, then use kamel log timed-greeter to see the logs as shown in the earlier listing.

You can use Ctrl+C to stop the running Camel K integration and it automatically terminate its pods. If you had encountered the dev mode failure as described earlier, try to delete the integration using the command kamel delete timed-greeter.

The dev mode allows live reload of code. Update the timed-greeter.yaml body text to be "Hi Camel K rocks!" and observe the automatic reloading of the context and the logs printing the new message.

Deploy Camel-K Knative Integration
Any Camel-K integration can be converted into a serverless service using Knative. For an integration to be deployed as a Knative Service you need to use the Camel-K’s knative component.

The Camel-K Knative component provides two consumers: knative:endpoint and knative:channel. The former is used to deploy the integration as Knative Service, while the later is used to handle events from a Knative Event channel.

The Knative endpoints can be either a Camel producer or consumer depending on the context and need.

We wil now deploy a knative:endpoint consumer as part of your integration, that will add the serverless capabilities to your Camel-K integration using Knative.

The following listing shows a simple echoer Knative Camel-K integration, that will simply respond to your Knative Service call with same body that you sent into it in uppercase form. If there is no body received the service will respond with "no body received":

Echoer Integration
- from:
    uri: "knative:endpoint/echoer" 
    steps:
      - log:
          message: "Got Message: ${body}"
      - convert-body: "java.lang.String" 
      - choice:
          when:
            - simple: "${body} != null && ${body.length} > 0"
              steps:
                - set-body:
                    simple: "${body.toUpperCase()}"
                - set-header:
                    name: ContentType
                    simple: text/plain
                - log:
                    message: "${body}"
          otherwise:
            steps:
              - set-body:
                  constant: "no body received"
              - set-header:
                  name: ContentType
                  simple: text/plain
              - log:
                  message: "Otherwise::${body}"
The consumer needs to be a Knative endpoint URI of form knative:endpoint/<your endpoint name>, the name of the Knative service will be the last path segment of the URI, in this case your Knative service will be called echoer.
You will be converting the incoming data (request body) to java.lang.String as that will help you in converting to upper case.
You can run this integration as shown in the following listing. If you notice that you are now deploying the integration in production mode i.e without --dev option.

kamel run --wait --dependency camel:log --dependency camel:bean \
    get-started/echoer.yaml

You can use stern camel-k to monitor the progress of the builder pod as well as watch kubectl kamel get and monitor the PHASE column. In addition, watch kubectl get ksvc looking at the READY column to become True.

Since its the production mode and it takes some time for the integration to come up, you need to watch the integration’s logs using the command kamel log <integration name> i.e. kamel log echoer and you can get the name of the integration using the command kamel get.

In the integration that you had deployed, you had applied the Choice EIP when processing the exchange body. When the body has content then it simply converts the body to upper case otherwise it returns a canned response of "no body received". In either case, the content type header is set to text/plain.

Camel-K defines an integration via Custom Resource Definition (CRD) and you can view those CRDs and the actual integrations via the following commands:



oc api-resources --api-group=camel.apache.org


The command above shows the following output:

NAME                   SHORTNAMES   APIGROUP           NAMESPACED   KIND
builds                              camel.apache.org   true         Build
camelcatalogs          cc           camel.apache.org   true         CamelCatalog
integrationkits        ik           camel.apache.org   true         IntegrationKit
integrationplatforms   ip           camel.apache.org   true         IntegrationPlatform
integrations           it           camel.apache.org   true         Integration
kubectl

watch oc -n knativetutorial get integrations


A successful integration deployment should show the following output:

NAME              PHASE     KIT                        REPLICAS
echoer            Running   kit-bodug9d83u4bmr3uh8jg   1
Once the integration is started, you can check the Knative service using the command:


oc -n knativetutorial get ksvc echoer

When the service is in a ready state use the call script $TUTORIAL/bin/call.sh with parameter echoer and a request body of "Hello World":

$TUTORIAL_HOME/bin/call.sh echoer 'Hello World'

$TUTORIAL_HOME/bin/call.sh echoer ''

The invocation of a Knative Camel-K Integration is a bit different than previous Knative test calls. The Knative Camel-K integration service is expecting a POST where the input data is part of the request body. Therefore, you need to a few different elements to construct the invocation, the following snippet from $TUTORIAL_HOME/bin/call.sh shows how a Knative service call is constructed:

$ NODE_PORT=$(kubectl get svc istio-ingressgateway -n istio-system \
-o 'jsonpath={.spec.ports[?(@.port==80)].nodePort}') 
$ IP_ADDRESS="$(minikube ip):$NODE_PORT" 
$ HOST_HEADER="Host:echoer.knativetutorial.example.com" 
$ curl -X POST -H $HOST_HEADER -d "Hello World" $IP_ADDRESS 
All Knative traffic should flow through the Istio Ingress gateway and NodePort is the easiest solution on minikube
Minikube, which is running as a VM on your local machine, provides a local IP address (e.g. 192.168.99.100)
The host header can be determined by running kubectl get ksvc echoer, just make sure to remove the "http://" prefix
curl with a POST
Explore the kamel tool via its help option of kamel --help to see the list of available commands and their respective options.

Cleanup
kamel delete echoer

Camel-K Eventing
At the end of this chapter you will be able to:

How to use Knative Eventing Channels with Camel-K

Using Knative CamelSource

Connect Camel-K source to Sink

Prerequisite
The following checks ensure that each chapter exercises are done with the right environment settings.

Make sure to be on knativetutorial OpenShift project

oc project -q

If you are not on knativetutorial project, then run following command to change to knativetutorial project:

oc project knativetutorial

Deploy Knative Eventing CamelSource
The CamelSource allows you use a Camel-K integration as part of the Knative Eventing architecture. Simply speaking, you can make the Camel-K integration act as a Knative Event Source and send the Camel exchanges (OUT) through a Knative Event Sink.

To deploy CamelSource run the following command:

Use the OperatorHub in OpenShift web console to deploy the Knative Camel operator that will install the Knative Eventing CamelSource

Once you deploy, thee following new pod showing up the knative-sources namespace:

NAME                         READY   STATUS    RESTARTS   AGE
camel-controller-manager-0   1/1     Running   0          12h
Plus, CamelSource is now part of the API for your Kubernetes cluster:

kubectl api-resources --api-group=sources.eventing.knative.dev


The command above should list:

NAME               APIGROUP                       NAMESPACED   KIND
apiserversources   sources.eventing.knative.dev   true         ApiServerSource
camelsources       sources.eventing.knative.dev   true         CamelSource
containersources   sources.eventing.knative.dev   true         ContainerSource
cronjobsources     sources.eventing.knative.dev   true         CronJobSource
sinkbindings       sources.eventing.knative.dev   true         SinkBinding
kafkasources       sources.eventing.knative.dev   true         KafkaSource
View CloudEvents Messages
In order for you to view the events drained from the CamelSource timed-greeter, you need to deploy a utility service called event-display. Run the following command to deploy the service:


oc apply \
  -f https://github.com/knative/eventing-contrib/releases/download/v0.12.0/event-display.yaml

A successful event display should show the following pod in the knativetutorial:

NAME            URL                                                      READY
event-display   http://event-display.knativetutorial.example.com         True
CamelSource to a Knative Eventing Sink
Knative Eventing semantics allows you to link the Event Source to Event Sink using the sink block of the Knative Eventing source specification.

As part of this exercise we will deploy the same timed-greeter integration that you deployed earlier but now as a CamelSource that was deployed in previous section. The event source (CamelSource) is configured to drain the events to the sink event-display.

The following listing provides the details of CamelSource configuration:

timed-greeter CamelSource
apiVersion: sources.eventing.knative.dev/v1alpha1 
kind: CamelSource
metadata:
  name: timed-greeter
spec:
  integration: 
    dependencies:
      - camel:log
  source: 
    flow:
      from:
        uri: "timer:tick"
        parameters:
          period: "10s"
        steps:
          - set-body:
              constant: "Welcome to Apache Camel-K"
          - set-header:
              name: ContentType
              simple: text/plain
          - transform:
              simple: "${body.toUpperCase()}"
          - log:
              message: "${body}"
  sink: 
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
The CamelSource is provided by the API sources.eventing.knative.dev, it is now available as a result of deploying the CamelSource event source.
The CamelSource spec has two main sections: integration and source. The integration block is used to configure the Camel-K integration specific properties such as dependencies, traits, etc. In this example we add the required dependencies such as camel:log, it is the dependency that you earlier passed via kamel CLI.
The source block is used to define the Camel-K integration definition. The flow attribute of the source block allows you define the Camel route.
The event sink for messages from the Camel event source. The sink could be either a Knative Service, Knative Event Channel or Knative Event Broker. In this case it is configured to be the event-display Knative Service.
To deploy the CamelSource run the following command:


oc apply -n knativetutorial -f get-started/timed-greeter-source.yaml

A successful deployment will show the CamelSource timed-greeter in ready state along with its pods in the knativetutorial namespace.

watch oc -n knativetutorial get camelsources

When the camel source is successfully running you will see it in "READY" state True:

NAME            READY   AGE
timed-greeter   True    114s
You will also see the event-display pod scaling up to receive the events from timed-greeter.

CamelSource timed-greeter pod and event-display pod
# watch kubectl -n knativetutorial get pods
NAME                                              READY   STATUS    AGE
camel-k-operator-84d7896b68-sgmpk                 1/1     Running   2m36s
event-display-dmq4s-deployment-775789b565-fnf2t   2/2     Running   17s
timed-greeter-m4chq-7cbf4ddc66-kxpqd              1/1     Running   86s
Open a new terminal and run the following command to start watching the events that are being drained into the event-display Knative service using the command:

stern -n knativetutorial event-display -c user-container

The stern command above should show the following output:

event-... user-container   id: ID-timed-greeter-m4chq-7cbf4ddc66-kxpqd-1577072133461-0-19
event-... user-container   time: 2019-12-23T03:37:03.432Z
event-... user-container Data,
event-... user-container   WELCOME TO APACHE CAMEL K
event-... user-container ☁️  cloudevents.Event
event-... user-container Validation: valid
event-... user-container Context Attributes,
event-... user-container   specversion: 0.3
event-... user-container   type: org.apache.camel.event
event-... user-container   source: camel-source:knativetutorial/timed-greeter
Cleanup

oc -n knativetutorial delete camelsource timed-greeter

After few seconds you will see the event-display Knative Service scaling down to zero since it no longer receives events via the event source.

