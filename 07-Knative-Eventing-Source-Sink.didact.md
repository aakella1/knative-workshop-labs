# Knative Eventing - Source and Sink

## 1. Prerequisites

Make sure you completed all the steps in the Prerequistes lab.

Use `oc` client on your terminal to navigate to `knativetutorial` project

```
oc project knativetutorial
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20project%20knativetutorial&completion=Run%20oc%20project%20command. "Opens a new terminal and sends the command above"){.didact})

## 2. Watching Logs

In the eventing related subsections of this tutorial, event sources are configured to emit events every minute with a CronJobSource or with a ContainerSource.

The logs could be watched using the command:
```
oc logs -n knativetutorial -f <pod-name> -c user-container
```

Using stern with the command stern -n knativetutorial event-greeter, to filter the logs further add -c user-container to the stern command.

```
stern -n knativetutorial -c user-container event-greeter
```

## 3. Eventing Source to Sink

Navigate to `eventing` directory to find all the yaml files for the labs.


## 7. Event Source

Knative Eventing Sources are software components that emit events. The job of a Source is to connect to, drain, capture and potentially buffer events; often from an external system and then relay those events to the Sink.

Knative Eventing Sources installs the following four sources out-of-the-box:

```
kubectl api-resources --api-group='sources.eventing.knative.dev'
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$kubectl%20api-resources%20--api-group='sources.eventing.knative.dev'&completion=Run%20kubectl%20command. "Opens a new terminal and sends the command above"){.didact})

```
NAME              APIGROUP                      NAMESPACED   KIND
apiserversources  sources.eventing.knative.dev  true         ApiServerSource
containersources  sources.eventing.knative.dev  true         ContainerSource
cronjobsources    sources.eventing.knative.dev  true         CronJobSource
sinkbindings      sources.eventing.knative.dev  true         SinkBinding
```
Check out the Knative `eventing/eventinghello-source.yaml` ([open](didact://?commandId=vscode.openFolder&projectFilePath=eventing/eventinghello-source.yaml&completion=Opened%20the%20eventing/eventinghello-source.yaml%20file "Opens the eventing/eventinghello-source.yaml file"){.didact})

Notice that the `kind` will show you the type of event source the eventing system deploys. A bunch of sources come out of the box and Knative also provides way to deploy custom resources.
If you look into the `spec`, it will be unique per event source and per kind

## 7. Referencing the Event Sink

Knative Eventing Sink is how you specify the event receiver — that is the consumer of the event. Sinks can be invoked directly in a point-to-point fashion by referencing them via the Event Source’s sink as shown below:

Check out the Knative `eventing/eventinghello-source.yaml` ([open](didact://?commandId=vscode.openFolder&projectFilePath=eventing/eventinghello-source.yaml&completion=Opened%20the%20eventing/eventinghello-source.yaml%20file "Opens the eventing/eventinghello-source.yaml file"){.didact})

`sink` can target any Kubernetes Service or a Knative Service, and deployed with unique names, for example `eventinghello`

> Event Source can define the attributes that it wishes to receive via the spec. In the above example it defines schedule(the cron expression) and data that will be sent as part of the event.
>
> When you watch logs, you will notice this data being delivered to the service.

Run the following commands to create the event source resources:

## 8. Create Event Source

```
oc apply -n knativetutorial -f eventing/eventinghello-source.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20apply%20-n%20knativetutorial%20-f%20eventing/eventinghello-source.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

## 9. Verification

```
oc -n knativetutorial get cronjobsources.sources.eventing.knative.dev eventinghello-cronjob-source
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20-n%20knativetutorial%20get%20cronjobsources.sources.eventing.knative.dev%20eventinghello-cronjob-source&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

Running the above command should return the following result:
```
NAME                       AGE
eventinghello-cronjob-source  39s
```

## 10. Create Sink Service

Run the following command to create the Knative service that will be used as the subscriber for the cron events:

Check out the Knative `eventing/eventing-hello-sink.yaml` ([open](didact://?commandId=vscode.openFolder&projectFilePath=eventing/eventing-hello-sink.yaml&completion=Opened%20the%20eventing/eventing-hello-sink.yaml%20file "Opens the eventing/eventing-hello-sink.yaml file"){.didact})

## 11. Deploy Sink Service

Run the following commands to create the service:

```
oc apply -n knativetutorial -f eventing/eventing-hello-sink.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20apply%20-n%20knativetutorial%20-f%20eventing/eventing-hello-sink.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

Let's see the pods that got created

```
oc -n knativetutorial get pods
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20-n%20knativetutorial%20get%20pods&completion=Run%20oc%20get%20pods%20command. "Opens a new terminal and sends the command above"){.didact})

The above command will return an output like,
```
$ oc get pods
NAME                                                              READY   STATUS    RESTARTS   AGE
cronjobsource-eventinghell-6b70a96d-995f-4cd4-82f8-e05aefah2mcr   1/1     Running   0          2m16s
eventinghello-v1-deployment-5b9fd55999-hcqr4                      2/2     Running   0          2m30s
```

You can watch logs to see the cron job source sending an event every 1 minute.
```
oc logs -n knativetutorial -f <pod-name> -c user-container
```

## 12. See what you have deployed

### 12.1 sources

```
oc --namespace knativetutorial get cronjobsources.sources.eventing.knative.dev eventinghello-cronjob-source
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20-n%20knativetutorial%20get%20cronjobsources.sources.eventing.knative.dev%20event-greeter-cronjob-source&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

### 12.2 services

```
oc --namespace knativetutorial  get services.serving.knative.dev eventinghello
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20-n%20knativetutorial%20get%20services.serving.knative.dev%20eventinghello&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

## 13. Cleanup

```
oc -n knativetutorial delete -f eventing/eventinghello-source.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20-f%20eventing/eventinghello-source.yaml&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})
```
oc -n knativetutorial delete -f eventing/eventing-hello-sink.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20-f%20eventing/eventing-hello-sink.yaml&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})
