# Knative Eventing - Triggers and Brokers

Use the Knative Eventing Broker and Trigger Custom Resources to allow for CloudEvent attribute filtering.


## 1. Prerequisites

Make sure you completed all the steps in the Prerequistes lab.

Use `oc` client on your terminal to navigate to `knativetutorial` project

```
oc project knativetutorial
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20project%20knativetutorial&completion=Run%20oc%20project%20command. "Opens a new terminal and sends the command above"){.didact})

## 2. Introduction

Use the Knative Eventing Broker and Trigger Custom Resources to allow for CloudEvent attribute filtering.

## 3. Broker

By labeling knativetutorial namespace with knative-eventing-injection=enabled as shown below, will make Knative Eventing to deploy a default Knative Eventing Broker and its related Ingress :

```
kubectl label namespace knativetutorial knative-eventing-injection=enabled
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$kubectl%20label%20namespace%20knativetutorial%20knative-eventing-injection=enabled&completion=Run%20kubectl%20command. "Opens a new terminal and sends the command above"){.didact})

Verify that the default broker is running:

```
watch oc --namespace knativetutorial get broker
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$watch%20oc%20-n%20knativetutorial%20get%20broker&completion=Run%20oc%20get%20pods%20command. "Opens a new terminal and sends the command above"){.didact})


Running command above should show an output like:
```
NAME     READY REASON URL                                                 AGE
default  True         http://default-broker.knativetutorial.svc.cluster.local   22s
```
**To exit and terminate the execution**, [just click here](didact://?commandId=vscode.didact.sendNamedTerminalCtrlC&text=ocTerm&completion=loop%20interrupted. "Interrupt the current operation on the terminal"){.didact}

or hit `ctrl+c` on the terminal window.

This will also start two additional pods namely default-broker-filter and default-broker-ingress :

```
watch -n knativetutorial oc get pods
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$watch%20oc%20-n%20knativetutorial%20get%20pods&completion=Run%20oc%20get%20pods%20command. "Opens a new terminal and sends the command above"){.didact})

**To exit and terminate the execution**, [just click here](didact://?commandId=vscode.didact.sendNamedTerminalCtrlC&text=ocTerm&completion=loop%20interrupted. "Interrupt the current operation on the terminal"){.didact}

or hit `ctrl+c` on the terminal window.

Running command above should show the following pods in knativetutorial:
```
NAME                                         READY STATUS      AGE
default-broker-filter-c6654bccf-qb272        1/1   Running     18s
default-broker-ingress-7479966dc7-99xvm      1/1   Running     18s
```

## 4. Service

Now, that you have the broker configured, you need to create the sinks eventingaloha and eventingbonjour, which will receive the filtered events.

Check out the Knative `eventing/eventing-aloha-sink.yaml` ([open](didact://?commandId=vscode.openFolder&projectFilePath=eventing/eventing-aloha-sink.yaml&completion=Opened%20the%20eventing/eventing-aloha-sink.yaml%20file "Opens the eventing/eventing-aloha-sink.yaml file"){.didact}):

Also, check out the Knative `eventing/eventing-bonjour-sink.yaml` ([open](didact://?commandId=vscode.openFolder&projectFilePath=eventing/eventing-bonjour-sink.yaml&completion=Opened%20the%20eventing/eventing-bonjour-sink.yaml%20file "Opens the eventing/eventing-bonjour-sink.yaml file"){.didact}):

The image being used by both of these services is identical. However, the difference in name aloha vs bonjour will make obvious which one is receiving a particular event.

## 5. Deploy Service

Run the following commands to deploy the eventingaloha and eventingbonjour services:

```
oc apply -n knativetutorial -f eventing/eventing-aloha-sink.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=knTerm$$oc%20apply%20-n%20knativetutorial%20-f%20eventing/eventing-aloha-sink.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

```
oc apply -n knativetutorial -f eventing/eventing-bonjour-sink.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=knTerm$$oc%20apply%20-n%20knativetutorial%20-f%20eventing/eventing-bonjour-sink.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

Wait approximately 60 seconds for eventingaloha and eventingbonjour to terminate, scale-down to zero before proceeding.

## 6. Trigger

Now create the the trigger for eventingaloha that will associate the filtered events to a service:

Check out the Knative `eventing/trigger-helloaloha.yaml` ([open](didact://?commandId=vscode.openFolder&projectFilePath=eventing/trigger-helloaloha.yaml&completion=Opened%20the%20eventing/trigger-helloaloha.yaml%20file "Opens the eventing/trigger-helloaloha.yaml file"){.didact}):

The type is the CloudEvent type that is mapped to the ce-type HTTP header. A Trigger can filter by CloudEvent attributes such as type, source or extension.
Run the following commands to create the trigger:

```
oc apply -n knativetutorial -f trigger-helloaloha.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=knTerm$$oc%20apply%20-n%20knativetutorial%20-f%20eventing/trigger-helloaloha.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

Check out the Knative `eventing/trigger-hellobonjour.yaml` ([open](didact://?commandId=vscode.openFolder&projectFilePath=eventing/trigger-hellobonjour.yaml&completion=Opened%20the%20eventing/trigger-hellobonjour.yaml%20file "Opens the eventing/trigger-hellobonjour.yaml file"){.didact}):

Now create the the trigger for eventingbonjour that will associate the filtered events to a service:

Run the following commands to create the trigger:

```
oc apply -n knativetutorial -f trigger-hellobonjour.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=knTerm$$oc%20apply%20-n%20knativetutorial%20-f%20eventing/trigger-hellobonjour.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

Verify that your triggers are ready:

```
oc --namespace knativetutorial  get triggers.eventing.knative.dev helloaloha hellobonjour
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=knTerm$$oc%20-n%20knativetutorial%20get%20triggers.eventing.knative.dev%20helloaloha%20hellobonjour&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

The command should show the following output:
```
NAME         READY BROKER  SUBSCRIBER_URI                                      AGE
helloaloha   True  default http://eventingaloha.knativetutorial.svc.cluster.local   24s
hellobonjour True  default http://eventingbonjour.knativetutorial.svc.cluster.local 48s
```
## 7. See what you have deployed

```
oc --namespace knativetutorial get containersources.sources.eventing.knative.dev heartbeat-event-source
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=knTerm$$oc%20-n%20knativetutorial%20get%20containersources.sources.eventing.knative.dev%20heartbeat-event-source&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

```
oc --namespace knativetutorial  get services.serving.knative.dev eventinghello
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=knTerm$$oc%20-n%20knativetutorial%20get%20services.serving.knative.dev%20eventinghello&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

## 8. Verification
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

## 9. Cleanup

```
oc -n knativetutorial delete -f eventing/event-source-broker.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20-f%20eventing/event-source-broker.yaml&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})

```
oc -n knativetutorial delete -f eventing/eventing-aloha-sink.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20-f%20eventing/eventing-aloha-sink.yaml&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})

```
oc -n knativetutorial delete -f eventing-bonjour-sink.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20-f%20eventing/eventing-bonjour-sink.yaml&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})

```
oc -n knativetutorial delete -f trigger-helloaloha.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20-f%20eventing/trigger-helloaloha.yaml&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})

```
oc -n knativetutorial delete -f trigger-hellobonjour.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20-f%20eventing/trigger-hellobonjour.yaml&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})

```
oc -n knativetutorial delete -f eventinghello-source.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20-f%20eventing/eventinghello-source.yaml&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})

