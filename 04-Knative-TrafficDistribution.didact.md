# Knative traffic distribution

At the end of this chapter you will be able to :

- Providing custom name to deployment

- Understanding advanced deployment techniques

- Apply blue-green deployment pattern

- Apply Canary Release Deployment pattern

- Reduce the service visibility

As you noticed, Knative service always routes traffic to the latest revision of the service deployment. It is possible to split the traffic amongst the available revisions.

## 1. Arbitrary Revision Names
By default Knative generates a random revision names for the service based with Knative service’s `metadata.name` as prefix.

The following service deployments will show how to use an arbitrary revision names for the services. The service are exactly same greeter service except that their Revision name is specified using the service revision template spec.

### 1.1 Deploy greeter service revision v1:

To create the `greeter-v1`, check out the Knative `basics/greeter-v1-service.yaml` ([open](didact://?commandId=vscode.openFolder&projectFilePath=basics/greeter-v1-service.yaml&completion=Opened%20the%20greeter-v1-service.yaml%20file "Opens the basics/greeter-v1-service.yaml file"){.didact})service using kn run the following command:


The service can be deployed using the following command:

```
oc apply -n knativetutorial -f basics/greeter-v1-service.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=knTerm$$oc%20apply%20-n%20knativetutorial%20-f%20basics/greeter-v1-service.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

After successful deployment of the service we should see a Kubernetes Deployment.

```
oc get deployments -n knativetutorial
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20get%20deployments%20-n%20knativetutorial&completion=Run%20oc%20get%20deployments%20command. "Opens a new terminal and sends the command above"){.didact})

### 1.2 Deploy greeter service revision v2:

To create the `greeter-v2`, check out the Knative `basics/greeter-v2-service.yaml` ([open](didact://?commandId=vscode.openFolder&projectFilePath=basics/greeter-v2-service.yaml&completion=Opened%20the%20greeter-v2-service.yaml%20file "Opens the basics/greeter-v2-service.yaml file"){.didact})service using kn run the following command:

The service can be deployed using the following command:

```
oc apply -n knativetutorial -f basics/greeter-v2-service.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=knTerm$$oc%20apply%20-n%20knativetutorial%20-f%20basics/greeter-v2-service.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

After successful deployment of the service we should see a Kubernetes Deployment.

```
oc get deployments -n knativetutorial
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20get%20deployments%20-n%20knativetutorial&completion=Run%20oc%20get%20deployments%20command. "Opens a new terminal and sends the command above"){.didact})

### 1.3 Check to ensure you have two revisions of the greeter service:

```
oc --namespace knativetutorial get rev --selector=serving.knative.dev/service=greeter --sort-by="{.metadata.creationTimestamp}"
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20get%20rev%20--selector%3Dserving.knative.dev%2Fservice%3Dgreeter%20--sort-by%3D%22%7B.metadata.creationTimestamp%7D%22&completion=Run%20oc%20get%20revisions%20command. "Opens a new terminal and sends the command above"){.didact})

The command above should list two revisions namely greeter-v1 and greeter-v2.

add -oyaml to the commands above to see more detail

([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20get%20rev%20--selector%3Dserving.knative.dev%2Fservice%3Dgreeter%20--sort-by%3D%22%7B.metadata.creationTimestamp%7D%22%20-oyaml&completion=Run%20oc%20get%20revisions%20command. "Opens a new terminal and sends the command above"){.didact})

## 2. Applying Blue-Green Deployment Pattern

Knative offers a simple way of switching 100% of the traffic from one Knative service revision (blue) to another newly rolled out revision (green). If the new revision (e.g. green) has erroneous behavior then it is easy to rollback the change.

In this exercise you will applying theBlue/Green deployment pattern with the Knative Service called greeter. You have already deployed two revisions of greeter named greeter-v1 and greeter-v2 earlier in this chapter.

With the deployment of greeter-v2 you noticed that Knative automatically started to routing 100% of the traffic to greeter-v2. Now let us assume that we need to roll back greeter-v2 to greeter-v1 for some critical reason.

The following Knative Service YAML is identical to the previously deployed greeter-v2 except that we have added the traffic section to indicate that 100% of the traffic should be routed to greeter-v1.

### 2.1 All traffic to greeter-v1

To route 100% of the traffic to `greeter-v1`, check out the Knative `basics/service-pinned.yaml` ([open](didact://?commandId=vscode.openFolder&projectFilePath=basics/service-pinned.yaml&completion=Opened%20the%20service-pinned.yaml%20file "Opens the basics/service-pinned.yaml file"){.didact})service using kn run the following command:

Notice that the above yaml creates three sub-routes(named after traffic tags) to existing greeter route at the end of the file.

- v1 - The revision is going to have all 100% traffic distribution

- v2 - The previously active revision, which will now have zero traffic

- latest - The route pointing to any latest service deployment, by setting to zero we are making sure the latest revision is not picked up automatically.

If you observe the resource YAML above, we have added a special tag latest. Since you have defined that all 100% of traffic need to go to greeter-v1, this tag can be used to suppress the default behavior of Knative Service to route all 100% traffic to latest revision.

Before you apply the resource $BOOK_HOME/basics/service-pinned.yaml, call the greeter service again to verify that it is still providing the response from greeter-v2 that includes Namaste.

Use the command below to invoke the knative service

```
export SVC_URL=`oc get rt greeter -o yaml | yq read - 'status.url'` && http $SVC_URL
```

([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$export%20SVC_URL%3D%60oc%20get%20rt%20greeter%20-o%20yaml%20%7C%20yq%20read%20-%20%27status.url%27%60%20%26%26%20http%20%24SVC_URL&completion=Invoke%20Greeter%20service. "Opens a new terminal and sends the command above"){.didact})


It should return a response like `Namaste greeter ⇒ '9861675f8845' : 1`

### 2.2 Create greeter deployment (blue)

Now apply the update Knative service configuration using the command as shown in following listing:

```
oc apply -n knativetutorial -f basics/service-pinned.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=knTerm$$oc%20apply%20-n%20knativetutorial%20-f%20basics/service-pinned.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

After successful deployment of the service we should see a Kubernetes Deployment.

```
oc get deployments -n knativetutorial
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20get%20deployments%20-n%20knativetutorial&completion=Run%20oc%20get%20deployments%20command. "Opens a new terminal and sends the command above"){.didact})

Run the command below:

```
oc -n knativetutorial get ksvc greeter -oyaml | yq r - 'status.traffic[*].url'
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20-n%20knativetutorial%20get%20ksvc%20greeter%20-oyaml%20%7C%20yq%20r%20-%20%27status.traffic%5B%2A%5D.url%27&completion=Run%20oc%20get%20subroutes%20command. "Opens a new terminal and sends the command above"){.didact})


The above command should return you three sub-routes for the main greeter route:

```
- http://current-greeter.knativetutorial.example.com 
- http://prev-greeter.knativetutorial.example.com 
- http://latest-greeter.knativetutorial.example.com 
the sub route for the traffic tag current
the sub route for the traffic tag prev
the sub route for the traffic tag latest
```

You will notice that the command does not create any new configuration/revision/deployment as there was no application update (e.g. image tag, env var, etc), but when you call the service, Knative scales up the greeter-v1 and the service responds with the text Hi greeter ⇒ '9861675f8845' : 1.

Use the command below to invoke the knative service

```
export SVC_URL=`oc get rt greeter -o yaml | yq read - 'status.url'` && http $SVC_URL
```

([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$export%20SVC_URL%3D%60oc%20get%20rt%20greeter%20-o%20yaml%20%7C%20yq%20read%20-%20%27status.url%27%60%20%26%26%20http%20%24SVC_URL&completion=Invoke20Greeter%20service. "Opens a new terminal and sends the command above"){.didact})

```
Hi  greeter => '9861675f8845' : 1
```

Run the command below and see how may pods are running
```
oc get pods
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20get%20pods&completion=Run%20oc%20get%20pods%20command. "Opens a new terminal and sends the command above"){.didact})

```
NAME                                     READY   STATUS    AGE
greeter-v1-deployment-6f75dfd9d8-s5bvr   2/2     Running   5s
```

### 2.3 Create greeter deployment (green)

As an exercise, flip all the traffic back to greeter-v2 (green). You need to edit the traffic block of the service-pinned.yaml and update the revision name to greeter-v2. After you redeploy the service-pinned.yaml, try calling the service again to notice the difference. If everything went smooth you will notice the service calls will now go to only greeter-v2.

## 3. Applying Canary Release Pattern

A Canary release is more effective when you want to reduce the risk of introducing new feature. It allows you a more effective feature-feedback loop before rolling out the change to your entire user base.

Knative allows you to split the traffic between revisions in increments as small as 1%.

To see this in action, apply the following Knative service definition that will split the traffic 80% to 20% between greeter-v1 and greeter-v2.

### 3.1 Canary between greeter v1 and v2

To create the canary deployment, check out the Knative `basics/service-canary.yaml` ([open](didact://?commandId=vscode.openFolder&projectFilePath=basics/service-canary.yaml&completion=Opened%20the%20service-canary.yaml%20file "Opens the basics/service-canary.yaml file"){.didact})service using kn run the following command:

### 3.2 Create greeter canary Deployment

The service can be deployed using the following command:

```
oc apply -n knativetutorial -f basics/service-canary.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=knTerm$$oc%20apply%20-n%20knativetutorial%20-f%20basics/service-canary.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

After successful deployment of the service we should see a Kubernetes Deployment.

```
oc get deployments -n knativetutorial
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20get%20deployments%20-n%20knativetutorial&completion=Run%20oc%20get%20deployments%20command. "Opens a new terminal and sends the command above"){.didact})


As in the previous section on Applying Blue-Green Deployment Pattern deployments, the command will not create any new configuration/revision/deployment. 

### 3.3 Verify Canary rollout

Let us try to observe the traffic distribution now.

```
while true; do http `oc get rt greeter -o yaml | yq read - 'status.url'` --body; sleep .5; done
```

([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$while%20true%3B%20do%20http%20%60oc%20get%20rt%20greeter%20-o%20yaml%20%7C%20yq%20read%20-%20%27status.url%27%60%20--body%3B%20sleep%20.5%3B%20done "Opens a new terminal and sends the command above"){.didact})

You will see that approximately 80% of the responses are returned from greeter-v1 and approximately 20% from greeter-v2. See the listing below for sample output:


**To exit and terminate the execution**, [just click here](didact://?commandId=vscode.didact.sendNamedTerminalCtrlC&text=ocTerm&completion=loop%20interrupted. "Interrupt the current operation on the terminal"){.didact}

or hit `ctrl+c` on the terminal window.

You should also notice that two pods are running representing both greeter-v1 and greeter-v2:
```
watch 'oc get pods -n knativetutorial'
```

([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$watch%20'oc%20get%20pods%20-n%20knativetutorial'&completion=Run%20watch%20command. "Opens a new terminal and sends the command above"){.didact})

```
NAME                                     READY   STATUS    AGE
greeter-v1-deployment-6f75dfd9d8-86q89   2/2     Running   12s
greeter-v2-deployment-9984bb56d-n7xvm    2/2     Running   2s
```
**To exit and terminate the execution**, [just click here](didact://?commandId=vscode.didact.sendNamedTerminalCtrlC&text=ocTerm&completion=loop%20interrupted. "Interrupt the current operation on the terminal"){.didact}

or hit `ctrl+c` on the terminal window.

## 4. Cleanup

Run the command below

```
oc -n knativetutorial delete services.serving.knative.dev greeter
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20services.serving.knative.dev%20greeter&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})