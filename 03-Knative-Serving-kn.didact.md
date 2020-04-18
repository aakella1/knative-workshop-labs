# Knative Serving and oc client

Knative Client is the command line utility aimed at enhancing the developer experience when doing Knative Serving and Eventing tasks.

At the end of this chapter you will be able to :

- Install Knative Client

- Create, update, list and delete Knative service

- Create, update, list and delete Knative service revisions

- List Knative service routes

Knative Client (kn) is still under aggressive development, so commands and options might change rapidly.

As of writing the tutorial v0.12.0 was the latest version of the Knative Client

## 1. Install

Knative Client was installed as part of the prerequisites exercise.

Verify installation by running the command:

```
kn version
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$kn%20version&completion=Run%20kn%20command. "Opens a new terminal and sends the command above"){.didact})

The above command will return a response like
```
Version:      v0.12.0
Build Date:   2020-01-29 21:03:45
Git Revision: 164cb5f
```

Supported APIs:
- Serving
  - serving.knative.dev/v1 (knative-serving v0.12.0)
- Eventing
  - sources.eventing.knative.dev/v1alpha1 (knative-eventing v0.12.0)
  - eventing.knative.dev/v1alpha1 (knative-eventing v0.12.0)

## 2. Knative Service Commands

In the previous chapter you created, updated and deleted the Knative service using the YAML and kubectl/oc command line tools.

We will perform the same operations in this chapter but with kn:

### 2.1 Create Service

To create the `greeter` service using kn run the following command:

```
kn service create greeter --namespace knativetutorial --image quay.io/rhdevelopers/knative-tutorial-greeter:quarkus
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$kn%20service%20create%20greeter%20--namespace%20knativetutorial%20--image%20quay.io/rhdevelopers/knative-tutorial-greeter:quarkus&completion=Run%20kn%20command. "Opens a new terminal and sends the command above"){.didact})

A successful create of the `greeter` service should show a response like

```
Service 'greeter' successfully created in namespace 'knativetutorial'.
Waiting for service 'greeter' to become ready ... OK
```

### 2.2 List Knative Services

You can list the created services using the command:

```
kn service list --namespace knativetutorial
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$kn%20service%20list%20--namespace%20knativetutorial&completion=Run%20kn%20command. "Opens a new terminal and sends the command above"){.didact})

### 2.3 Invoke Service

Use the command below to invoke the knative service

```
export SVC_URL=`oc get rt greeter -o yaml | yq read - 'status.url'` && http $SVC_URL
```

([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$export%20SVC_URL%3D%60oc%20get%20rt%20greeter%20-o%20yaml%20%7C%20yq%20read%20-%20%27status.url%27%60%20%26%26%20http%20%24SVC_URL&completion=Run%20kn%20command. "Opens a new terminal and sends the command above"){.didact})

You can verify what you the kn client has deployed, to make sure its inline with what you have see in previous chapter.

### 2.4 Update Knative Service

To create a new revision using kn is as easy as running another command.

In previous chapter we deployed a new revision of Knative service by adding an environment variable. Lets try do the same thing with kn to trigger a new deployment:

```
kn service update greeter --env "MESSAGE_PREFIX=Namaste"
```

([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$kn%20service%20update%20greeter%20--env%20"MESSAGE_PREFIX=Namaste"&completion=Run%20kn%20command. "Opens a new terminal and sends the command above"){.didact})

Use the command below to invoke the knative service again

```
export SVC_URL=`oc get rt greeter -o yaml | yq read - 'status.url'` && http $SVC_URL
```

([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$export%20SVC_URL%3D%60oc%20get%20rt%20greeter%20-o%20yaml%20%7C%20yq%20read%20-%20%27status.url%27%60%20%26%26%20http%20%24SVC_URL%0A&completion=Run%20kn%20command. "Opens a new terminal and sends the command above"){.didact})

Now Invoking the service will return me a response like `Namaste greeter ⇒ '9861675f8845' : 1`

### 2.5 Describe Knative Service

Sometime you wish you get the YAML of the Knative service to build a new service or to compare with with another service. kn makes it super easy for you to get the YAML:

```
kn service describe greeter
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$kn%20service%20describe%20greeter&completion=Run%20kn%20command. "Opens a new terminal and sends the command above"){.didact})

The describe should show you a short summary of your service :
```
Name:       greeter
Namespace:  knativetutorial
Age:        1m
URL:        http://greeter.knativetutorial.example.com
```

```
Revisions:
  100%  @latest (greeter-twpgf-1) [1] (1m)
        Image:  quay.io/rhdevelopers/knative-tutorial-greeter:quarkus (pinned to 767e2f)
```

```
Conditions:
  OK TYPE                   AGE REASON
  ++ Ready                  34s
  ++ ConfigurationsReady    34s
  ++ RoutesReady            34s
```
### 2.6 Delete Knative Service

We are going to work with other kn commands on Revisions and Routes. So, we moved the `kn delete` command to the end of the exercise.

## 3. Knative Revision Commands

The kn revision commands are used to interact with revision(s) of Knative service.

### 3.1 List Revisions

You can list the available revisions of a Knative service using:

```
kn revision list
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$kn%20revision%20list&completion=Run%20kn%20command. "Opens a new terminal and sends the command above"){.didact})

The command should show a list of revisions like

```
NAME              SERVICE   TRAFFIC   TAGS   GENERATION   AGE   CONDITIONS   READY   REASON
greeter-tjtpm-2   greeter   100%             2            98s   3 OK / 4     True
greeter-twpgf-1   greeter                    1            11h   3 OK / 4     True
```

### 3.2 Describe Revision

To get the details about a specific revision you can use the command:

```
kn revision describe greeter-twpgf-1
```
You have to type the command manually as the name of the `greeter` revision changes for every run.

```
The command should return a output like

Name:       greeter-twpgf-1
Namespace:  knativetutorial
Age:        10m
Image:      quay.io/rhdevelopers/knative-tutorial-greeter:quarkus (pinned to 767e2f)
Service:    greeter

Conditions:
  OK TYPE                  AGE REASON
  ++ Ready                  9m
  ++ ContainerHealthy       9m
  ++ ResourcesAvailable     9m
   I Active                 8m NoTraffic
```

### 3.2 Delete Revision

To delete a specific revision you can use the command:

```
kn revision delete greeter-7cqzq
```

You have to type the command manually as the name of the `greeter` revision changes for every run.

The command should return an output like

```
Revision 'greeter-7cqzq' successfully deleted in namespace 'knativetutorial'.
Now invoking service will return the response from revision greeter-6m45j.
```

## 4. Knative Route Commands

The kn revision commands are used to interact with route(s) of Knative service.

### 4.1.List Routes

```
kn route list
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$kn%20route%20list&completion=Run%20kn%20command. "Opens a new terminal and sends the command above"){.didact})

The command should return an output like

```
NAME      URL                                          AGE   CONDITIONS   TRAFFIC
greeter   http://greeter.knativetutorial.example.com   10m   3 OK / 3     100% -> greeter-zd7jk
As an exercise you can run the exercises of previous chapter and try listing the routes using kn.
```

## 5. Cleanup

You can use kn to delete the service that were created, to delete the service named greeter run the following command:

```
kn service delete greeter
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$kn%20service%20delete%20greeter&completion=Run%20kn%20command. "Opens a new terminal and sends the command above"){.didact})

A successful delete should show an output like

```
Service 'greeter' successfully deleted in namespace 'knativetutorial'.
```


