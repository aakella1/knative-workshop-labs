# Knative Serving and oc client

At the end of this chapter you will be able to :

- Deploy a Knative service.

- Deploy multiple revisions of a service.

- Run different revisions of a service via traffic definition.

## 1. Prerequisite

Use `oc` client on your terminal to navigate to `knativetutorial` project

```
oc project knativetutorial
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20project%20knativetutorial&completion=Run%20oc%20project%20command. "Opens a new terminal and sends the command above"){.didact})

## 2. Deploy Service

Check out the Knative `basics/service.yaml` ([open](didact://?commandId=vscode.openFolder&projectFilePath=basics/service.yaml&completion=Opened%20the%20service.yaml%20file "Opens the basics/service.yaml file"){.didact}):

The service can be deployed using the following command:

```
oc apply -n knativetutorial -f basics/service.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=knTerm$$oc%20apply%20-n%20knativetutorial%20-f%20basics/service.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

After successful deployment of the service we should see a Kubernetes Deployment.

```
oc get deployments -n knativetutorial
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20get%20deployments%20-n%20knativetutorial&completion=Run%20oc%20get%20deployments%20command. "Opens a new terminal and sends the command above"){.didact})

## 3. Invoke the Service

Run the command to Invoke the service deployed
```
export SVC_URL=`oc get rt greeter -o yaml | yq read - 'status.url'` && http $SVC_URL
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=curlTerm$$export%20SVC_URL%3D%60oc%20get%20rt%20greeter%20-o%20yaml%20%7C%20yq%20read%20-%20%27status.url%27%60%20%26%26%20http%20%24SVC_URL%0A&completion=Invoke%20Knative%20deployment. "Opens a new terminal and sends the command above"){.didact})

The http command should return a response containing a line similar to 
```
Hi greeter ⇒ '6fee83923a9f' : 1
```

> Sometimes the response might not be returned immediately especially when the pod is coming up from dormant state. In that case, repeat service invocation.

## 4. See what you have deployed

The service-based deployment strategy that we did now will create many Knative resources, the following commands will help you to query and find what has been deployed.

### 4.1 Info on services
```
oc --namespace knativetutorial  get services.serving.knative.dev greeter
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20get%20services.serving.knative.dev%20greeter&completion=Run%20oc%20get%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})

### 4.2 Info on configurations

```
oc --namespace knativetutorial get configurations.serving.knative.dev greeter
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20get%20configurations.serving.knative.dev%20greeter&completion=Run%20oc%20get%20kn-config%20command. "Opens a new terminal and sends the command above"){.didact})

### 4.3 Info on routes

```
oc --namespace knativetutorial get routes.serving.knative.dev greeter
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20get%20routes.serving.knative.dev%20greeter&completion=Run%20oc%20get%20kn-routes%20command. "Opens a new terminal and sends the command above"){.didact})

When the service was invoked with `httpie`, you noticed that we added a Host header to the request with value `greeter.knativetutorial.example.com`. This FQDN is automatically assigned to your `Knative service` by the `Knative Routes` and uses the following format: `<service-name>.<namespace>.<domain-suffix>`.

### 4.4 Info on revisions

```
oc --namespace knativetutorial get rev --selector=serving.knative.dev/service=greeter --sort-by="{.metadata.creationTimestamp}"
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20get%20rev%20--selector%3Dserving.knative.dev%2Fservice%3Dgreeter%20--sort-by%3D%22%7B.metadata.creationTimestamp%7D%22%0A&completion=Run%20oc%20get%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})

>add `-oyaml` to the commands above to see more details
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20get%20rev%20--selector%3Dserving.knative.dev%2Fservice%3Dgreeter%20--sort-by%3D%22%7B.metadata.creationTimestamp%7D%22%20-oyaml&completion=Run%20oc%20get%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})

## 5. Deploy a New Revision of a Service

Check out the Knative `basics/service-env.yaml` ([open](didact://?commandId=vscode.openFolder&projectFilePath=basics/service-env.yaml&completion=Opened%20the%20service-env.yaml%20file "Opens the basics/service-env.yaml file"){.didact}):

The service can be deployed using the following command:

```
oc apply -n knativetutorial -f basics/service-env.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=knTerm$$oc%20apply%20-n%20knativetutorial%20-f%20basics/service-env.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

After successful deployment of the service we should see a Kubernetes Deployment.

```
oc get deployments -n knativetutorial
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20get%20deployments%20-n%20knativetutorial&completion=Run%20oc%20get%20deployments%20command. "Opens a new terminal and sends the command above"){.didact})

To see the revisions deployed, run the command below

```
oc --namespace knativetutorial get rev --selector=serving.knative.dev/service=greeter --sort-by="{.metadata.creationTimestamp}"
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20get%20rev%20--selector%3Dserving.knative.dev%2Fservice%3Dgreeter%20--sort-by%3D%22%7B.metadata.creationTimestamp%7D%22%0A&completion=Run%20oc%20get%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})

Run the command to Invoke the service deployed
```
export SVC_URL=`oc get rt greeter -o yaml | yq read - 'status.url'` && http $SVC_URL
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=curlTerm$$export%20SVC_URL%3D%60oc%20get%20rt%20greeter%20-o%20yaml%20%7C%20yq%20read%20-%20%27status.url%27%60%20%26%26%20http%20%24SVC_URL%0A&completion=Invoke%20Knative%20deployment. "Opens a new terminal and sends the command above"){.didact})

Invoking Service will now show an output like `Namaste greeter ⇒ '6fee83923a9f' : 1`, where `Namaste` is the value we configured via environment variable in the Knative service resource file.

## 6. Cleanup

You can delete the deployed knative service using the command below

```
oc -n knativetutorial delete services.serving.knative.dev greeter
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20services.serving.knative.dev%20greeter&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})