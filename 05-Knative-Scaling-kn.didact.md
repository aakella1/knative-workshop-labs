# Knative Scaling 

At the end of this chapter you will be able to:

- Understand what scale-to-zero is and why it’s important.

- Configure the scale-to-zero time period.

- Configure the autoscaler.

- Understand types of autoscaling strategies.

- Enable concurrency based autoscaling.

- Configure a minimum number of replicas for a service.

## 1. Prerequisites

Make sure you completed all the steps in the Prerequistes lab

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
export SVC_URL=`oc get rt prime-generator -o yaml | yq read - 'status.url'` && http $SVC_URL
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=curlTerm$$export%20SVC_URL%3D%60oc%20get%20rt%20prime-generator%20-o%20yaml%20%7C%20yq%20read%20-%20%27status.url%27%60%20%26%26%20http%20%24SVC_URL%0A&completion=Invoke%20Knative%20deployment. "Opens a new terminal and sends the command above"){.didact})

The http command should return a response containing a line similar to 
```
Hi greeter ⇒ '6fee83923a9f' : 1
```

> Sometimes the response might not be returned immediately especially when the pod is coming up from dormant state. In that case, repeat service invocation.

## 4. Scale to zero

Assuming that Greeter service has been deployed, once no more traffic is seen going into that service, we’d like to scale this service down to zero replicas. That’s called scale-to-zero.

Scale-to-zero is one of the main properties making Knative a serverless platform. After a defined time of idleness (the so called stable-window) a revision is considered inactive. Now, all routes pointing to the now inactive revision will be pointed to the so-called activator. This reprogramming of the network is asynchronous in nature so the scale-to-zero-grace-period should give enough slack for this to happen. Once the scale-to-zero-grace-period is over, the revision will finally be scaled to zero replicas.

If another request tries to get to this revision, the activator will get it, instruct the autoscaler to create new pods for the revision as quickly as possible and buffer the request until those new pods are created.

By default the scale-to-zero-grace-period is 30s, and the stable-window is 60s. Firing a request to the greeter service will bring up the pod (if it is already terminated, as described above) to serve the request. Leaving it without any further requests will automatically cause it to scale to zero in approx 60-70 secs. There are at least 20 seconds after the pod starts to terminate and before it’s completely terminated. This gives Istio enough time to leave out the pod from its own networking configuration.

For better clarity and understanding let us clean up the deployed Knative resources before going to next section.

## 5. Auto Scaling

By default Knative Serving allows 100 concurrent requests into a pod. This is defined by the container-concurrency-target-default setting in the configmap config-autoscaler in the knative-serving namespace.

For this exercise let us make our service handle only 10 concurrent requests. This will cause Knative autoscaler to scale to more pods as soon as we run more than 10 requests in parallel against the revision.

Check out the Knative `scaling/service-10.yaml` ([open](didact://?commandId=vscode.openFolder&projectFilePath=scaling/service-10.yaml&completion=Opened%20the%20service-10.yaml%20file "Opens the basics/service.yaml file"){.didact}):

The service can be deployed using the following command:

```
oc apply -n knativetutorial -f scaling/service-10.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=knTerm$$oc%20apply%20-n%20knativetutorial%20-f%20scaling/service-10.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

After successful deployment of the service we should see a Kubernetes Deployment.

```
oc get deployments -n knativetutorial
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20get%20deployments%20-n%20knativetutorial&completion=Run%20oc%20get%20deployments%20command. "Opens a new terminal and sends the command above"){.didact})


The Knative service definition above will allow each service pod to handle max of 10 in-flight requests per pod (configured via autoscaling.knative.dev/target annotation) before automatically scaling to new pod(s)

### 5.1 Deploy service


The service can be deployed using the following command:

```
oc apply -n knativetutorial -f scaling/service-10.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=knTerm$$oc%20apply%20-n%20knativetutorial%20-f%20scaling/service-10.yaml&completion=Run%20oc%20apply%20command. "Opens a new terminal and sends the command above"){.didact})

After successful deployment of the service we should see a Kubernetes Deployment.

```
oc get deployments -n knativetutorial
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20get%20deployments%20-n%20knativetutorial&completion=Run%20oc%20get%20deployments%20command. "Opens a new terminal and sends the command above"){.didact})

### 5.2 Invoke Service

We will not invoke the service directly as we need to send the load to see the autoscaling:

Open a new terminal and run the following command:

```
watch 'oc get pods -n knativetutorial'
```

([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$watch%20'oc%20get%20pods%20-n%20knativetutorial'&completion=Run%20watch%20command. "Opens a new terminal and sends the command above"){.didact})

### 5.3 Load the service
We will now send some load to the greeter service. The command below sends 50 concurrent requests (-c 50) for the next 100s (-z 30s)

```
hey -c 50 -z 100s "${SVC_URL}/?sleep=1&upto=10000&memload=100"
```

([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=curlTerm$$hey%20-c%2050%20-z%20100s%20%22%24%7BSVC_URL%7D%2F%3Fsleep%3D1%26upto%3D10000%26memload%3D100%22%0A&completion=Run%20watch%20command. "Opens a new terminal and sends the command above"){.didact})

After you’ve successfully run this small load test, you will notice the number of greeter service pods will have scaled to 5 automatically.

The autoscale pods is computed using the formula:

totalPodsToScale = inflightRequests / concurrencyTarget
With this current setting of concurrencyTarget=10 and inflightRequests=50 , you will see Knative automatically scales the greeter services to 50/10 = 5 pods.

For more clarity and understanding let us clean up existing deployments before proceeding to next section.

## 6. Minimum Scale
In real world scenarios your service might need to handle sudden spikes in requests. Knative starts each service with a default of 1 replica. As described above, this will eventually be scaled to zero as described above. If your app needs to stay particularly responsive under any circumstances and/or has a long startup time, it might be beneficial to always keep a minimum number of pods around. This can be done via an the annotation autoscaling.knative.dev/minScale.

The following example shows how to make Knative create services that start with a replica count of 2 and never scale below it.

### 6.1 Deploy service
service-min-max-scale.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: prime-generator
spec:
  template:
    metadata:
      annotations:
        # the minimum number of pods to scale down to
        autoscaling.knative.dev/minScale: "2"
        # Target 10 in-flight-requests per pod.
        autoscaling.knative.dev/target: "10"
    spec:
      containers:
      - image: quay.io/rhdevelopers/prime-generator:v27-quarkus
        livenessProbe:
          httpGet:
            path: /healthz
        readinessProbe:
          httpGet:
            path: /healthz
The deployment of this service will always have a minimum of 2 pods.

Will allow each service pod to handle max of 10 in-flight requests per pod before automatically scaling to new pods.

kubectl

oc

oc apply -n knativetutorial -f service-min-max-scale.yaml

After the deployment was successful we should see a Kubernetes Deployment called prime-generator-v2-deployment with two pods available.

Open a new terminal and run the following command :

kubectl

oc

watch 'oc get pods -n knativetutorial'

Let us send some load to the service to trigger autoscaling.

When all requests are done and if we are beyond the scale-to-zero-grace-period, we will notice that Knative has terminated only 3 out 5 pods. This is because we have configured Knative to always run two pods via the annotation autoscaling.knative.dev/minScale: "2".

## 7. Cleanup

You can delete the deployed knative service using the command below

```
oc -n knativetutorial delete services.serving.knative.dev greeter &&\
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20services.serving.knative.dev%20greeter&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})
```
oc -n knativetutorial delete services.serving.knative.dev prime-generator
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=ocTerm$$oc%20--namespace%20knativetutorial%20delete%20services.serving.knative.dev%20prime-generator&completion=Run%20oc%20delete%20kn-services%20command. "Opens a new terminal and sends the command above"){.didact})
