# Knative Eventing - Channel and Subscribers

- **Channels** - Channels are an event forwarding and persistence layer where each channel is a separate Kubernetes Custom Resource. A Channel may be backed by Apache Kafka or InMemoryChannel. This recipe focuses on InMemoryChannel.

- **Subscriptions** - Subscriptions are how you register your service to listen to a particular channel.

## 1. Prerequisites

Make sure you completed all the steps in the Prerequistes lab.

Use `oc` client on your terminal to navigate to `knativetutorial` project

```
oc project knativetutorial
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20project%20knativetutorial&completion=Run%20oc%20project%20command. "Opens a new terminal and sends the command above"){.didact})

## 2. Channel (Sink)

The channel or sink is an interface between the event source and the subscriber. The channels are built in to store the incoming events and distribute the event data to the subscribers. When forwarding event to subscribers the channel transforms the event data as per CloudEvent specification.

Check out the Knative `eventing/channel.yaml` ([open](didact://?commandId=vscode.openFolder&projectFilePath=eventing/channel.yaml&completion=Opened%20the%20eventing/channel.yaml%20file "Opens the eventing/channel.yaml file"){.didact})

> The name of the channel. Knative makes it addressable, i.e. resolveable to a target (a consumer service)

### 2.1 To create the channel

```
oc apply -n knativetutorial -f eventing/channel.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20apply%20-n%20knativetutorial%20-f%20eventing/channel.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

### 2.2 To verify channel creation
```
oc -n knativetutorial get channels.messaging.knative.dev
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20-n%20knativetutorial%20get%20channels.messaging.knative.dev&completion=Run%20oc%20get%20command. "Opens a new terminal and sends the command above"){.didact})

Running the above command should return the following result:
```
NAME             READY URL
eventinghello-ch True  http://eventinghello-ch-kn-channel.knativetutorial.svc.cluster.local
```

## 3. Event Source

The event source listens to external events e.g. a kafka topic or for a file on a FTP server. It is responsible to drain the received event(s) along with its data to a configured sink.

### 3.1 Create Event Source

Lets check out the eventing/eventinghello-source-ch.yaml([open](didact://?commandId=vscode.openFolder&projectFilePath=eventing/eventinghello-source-ch.yaml&completion=Opened%20the%20eventing/eventinghello-source-ch.yaml%20file "Opens the eventing/eventinghello-source-ch.yaml file"){.didact})

> The Channel API is in api-group `messaging.eventing.knative.dev`
> Kind is `Channel` instead of direct to a specific service; default is `InMemoryChannel` implementation

Run the following commands to create the event source resources:

```
oc apply -n knativetutorial -f eventing/eventinghello-source-ch.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20apply%20-n%20knativetutorial%20-f%20eventing/eventinghello-source-ch.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

### 3.2 Verifying Event Source

```
oc -n knativetutorial get cronjobsources.sources.eventing.knative.dev
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20-n%20knativetutorial%20get%20cronjobsources.sources.eventing.knative.dev&completion=Run%20oc%20get%20command. "Opens a new terminal and sends the command above"){.didact})

Running the above command should return the following result:

```
NAME                           READY   AGE
eventinghello-cronjob-source   True    8s
```

## 4. Event Subscriber

The event subscription is responsible of connecting the channel(sink) with the service. Once a service connected to a channel it starts receiving the events (cloud events).

### 4.1 Create Subscriber Services

Lets open the Subscriber yaml now. ([open](didact://?commandId=vscode.openFolder&projectFilePath=eventing/channel-subscriber.yaml&completion=Opened%20the%20eventing/channel-subscriber.yaml%20file "Opens the eventing/channel-subscriber.yaml file"){.didact})

> The string of eventinghello will help you identify this particular service.

```
oc apply -n knativetutorial -f eventing/channel-subscriber.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20apply%20-n%20knativetutorial%20-f%20eventing/channel-subscriber.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

### 4.2 Create Channel Subscription

Now create the appropriate Subscription for eventinghello to the Channel eventinghello, open file eventing/eventing-hello-sub.yaml([open](didact://?commandId=vscode.openFolder&projectFilePath=eventing/eventing-hello-sub.yaml&completion=Opened%20the%20eventing/eventing-hello-sub.yaml%20file "Opens the eventing/eventing-hello-sub.yaml file"){.didact}):

And create the appropriate Subscription for eventinghellob to the Channel eventinghello-ch:

```
oc apply -n knativetutorial -f eventing/eventing-hello-sub.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20apply%20-n%20knativetutorial%20-f%20eventing/eventing-hello-sub.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

### 4.3 Verification
Use the command below to verify subscription is created

```
oc -n knativetutorial get subscriptions.messaging.knative.dev
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20-n%20knativetutorial%20get%20subscriptions.messaging.knative.dev&completion=Run%20oc%20get%20command. "Opens a new terminal and sends the command above"){.didact})

Running the above command should return the following result:
```
NAME                       AGE
event-greeter-subscriber  39s
```

If you wait approximately 1 minute for the CronJobSource then you will see `eventinghello` begin to run in the `knativetutorial` project.

Watch pods in the knativetutorial

```
oc -n knativetutorial get pods
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20-n%20knativetutorial%20get%20pods&completion=Run%20oc%20get%20pods%20command. "Opens a new terminal and sends the command above"){.didact})


## 5. See what you have deployed

channels

```
oc --namespace knativetutorial get channels.eventing.knative.dev eventinghello-ch
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20-n%20knativetutorial%20get%20channels.messaging.knative.dev&completion=Run%20oc%20get%20command. "Opens a new terminal and sends the command above"){.didact})

sources
```
oc --namespace knativetutorial get cronjobsources.sources.eventing.knative.dev eventinghello-cronjob-source
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20-n%20knativetutorial%20get%20cronjobsources.sources.eventing.knative.dev&completion=Run%20oc%20get%20command. "Opens a new terminal and sends the command above"){.didact})

subscriptions
```
oc --namespace knativetutorial get subscriptions.messaging.knative.dev eventinghello-subscriber
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20-n%20knativetutorial%20get%20subscriptions.messaging.knative.dev&completion=Run%20oc%20get%20command. "Opens a new terminal and sends the command above"){.didact})

Add -oyaml to the above commands to get more details about each object that were queried for.

## 6. Cleanup

```
oc apply -n knativetutorial -f eventing/channel.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20-f%20eventing/channel.yaml&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})

```
oc apply -n knativetutorial -f eventing/channel-subscriber.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20-f%20eventing/channel-subscriber.yaml&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})
```
oc -n knativetutorial delete -f eventing/eventing-hello-sub.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20-f%20eventing/eventing-hello-sub.yaml&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})
```
oc -n knativetutorial delete -f eventinghello-source-ch.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20-f%20eventing/eventinghello-source-ch.yaml&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})

