Knative Tutorial
Knative Client is the command line utility aimed at enhancing the developer experience when doing Knative Serving and Eventing tasks.

At the end of this chapter you will be able to :

Install Knative Client

Create, update, list and delete Knative service

Create, update, list and delete Knative service revisions

List Knative service routes

Knative Client (kn) is still under aggressive development, so commands and options might change rapidly.

As of writing the tutorial v0.12.0 was the latest version of the Knative Client

Install
Download the latest Knative Client and add to your PATH.

Verify installation by running the command:

kn version

The above command will return a response like

Version:      v0.12.0
Build Date:   2020-01-29 21:03:45
Git Revision: 164cb5f
Supported APIs:
* Serving
  - serving.knative.dev/v1 (knative-serving v0.12.0)
* Eventing
  - sources.eventing.knative.dev/v1alpha1 (knative-eventing v0.12.0)
  - eventing.knative.dev/v1alpha1 (knative-eventing v0.12.0)
Knative Service Commands
In the previous chapter you created, updated and deleted the Knative service using the YAML and kubectl/oc command line tools.

We will perform the same operations in this chapter but with kn:

Create Service
To create the greeter service using kn run the following command:

kn service create greeter --namespace knativetutorial --image quay.io/rhdevelopers/knative-tutorial-greeter:quarkus

A successful create of the greeter service should show a response like

Service 'greeter' successfully created in namespace 'knativetutorial'.
Waiting for service 'greeter' to become ready ... OK

Service URL:
http://greeter.knativetutorial.example.com
List Knative Services
You can list the created services using the command:

kn service list --namespace knativetutorial

Invoke Service
Kubernetes

OpenShift

export SVC_URL=`oc get rt greeter -o yaml | yq read - 'status.url'` && \
http $SVC_URL

You can verify what you the kn client has deployed, to make sure its inline with what you have see in previous chapter.

Update Knative Service
To create a new revision using kn is as easy as running another command.

In previous chapter we deployed a new revision of Knative service by adding an environment variable. Lets try do the same thing with kn to trigger a new deployment:

kn service update greeter --env "MESSAGE_PREFIX=Namaste"

Now Invoking the service will return me a response like Namaste greeter ⇒ '9861675f8845' : 1

Describe Knative Service
Sometime you wish you get the YAML of the Knative service to build a new service or to compare with with another service. kn makes it super easy for you to get the YAML:

kn service describe greeter

The describe should show you a short summary of your service :

Name:       greeter
Namespace:  knativetutorial
Age:        1m
URL:        http://greeter.knativetutorial.example.com

Revisions:
  100%  @latest (greeter-twpgf-1) [1] (1m)
        Image:  quay.io/rhdevelopers/knative-tutorial-greeter:quarkus (pinned to 767e2f)

Conditions:
  OK TYPE                   AGE REASON
  ++ Ready                  34s
  ++ ConfigurationsReady    34s
  ++ RoutesReady            34s
Delete Knative Service
If you are going to work with other kn commands Revisions and Routes, then run these exercises after those commands

You can also use kn to delete the service that were created, to delete the service named greeter run the following command:

kn service delete greeter

A successful delete should show an output like

Service 'greeter' successfully deleted in namespace 'knativetutorial'.
Listing services you will notice that the greeter service no longer exists.

Knative Revision Commands
The kn revision commands are used to interact with revision(s) of Knative service.

List Revisions
You can list the available revisions of a Knative service using:

kn revision list

The command should show a list of revisions like

NAME              SERVICE   TRAFFIC   TAGS   GENERATION   AGE   CONDITIONS   READY   REASON
greeter-tjtpm-2   greeter   100%             2            98s   3 OK / 4     True
greeter-twpgf-1   greeter                    1            11h   3 OK / 4     True
Describe Revision
To get the details about a specific revision you can use the command:

kn revision describe greeter-twpgf-1

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
Delete Revision
To delete a specific revision you can use the command:

kn revision delete greeter-7cqzq

The command should return an output like

Revision 'greeter-7cqzq' successfully deleted in namespace 'knativetutorial'.
Now invoking service will return the response from revision greeter-6m45j.

Knative Route Commands
The kn revision commands are used to interact with route(s) of Knative service.

List Routes
kn route list

The command should return an output like

NAME      URL                                          AGE   CONDITIONS   TRAFFIC
greeter   http://greeter.knativetutorial.example.com   10m   3 OK / 3     100% -> greeter-zd7jk
As an exercise you can run the exercises of previous chapter and try listing the routes using kn.

Cleanup
kn service delete greeter


TRAFFIC DISTRIBUTION

Knative Tutorial
At the end of this chapter you will be able to :

Providing custom name to deployment

Understanding advanced deployment techniques

Apply blue-green deployment pattern

Apply Canary Release Deployment pattern

Reduce the service visibility

As you noticed, Knative service always routes traffic to the latest revision of the service deployment. It is possible to split the traffic amongst the available revisions.

Arbitrary Revision Names
By default Knative generates a random revision names for the service based with Knative service’s metadata.name as prefix.

The following service deployments will show how to use an arbitrary revision names for the services. The service are exactly same greeter service except that their Revision name is specified using the service revision template spec.

Deploy greeter service revision v1:

greeter-v1
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: greeter
spec:
  template:
    metadata:
      name: greeter-v1
    spec:
      containers:
        - image: quay.io/rhdevelopers/knative-tutorial-greeter:quarkus
          livenessProbe:
            httpGet:
              path: /healthz
          readinessProbe:
            httpGet:
              path: /healthz
Deploy greeter service revision v2:

greeter-v2
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: greeter
spec:
  template:
    metadata:
      name: greeter-v2
    spec:
      containers:
        - image: quay.io/rhdevelopers/knative-tutorial-greeter:quarkus
          env:
            - name: MESSAGE_PREFIX
              value: Namaste
          livenessProbe:
            httpGet:
              path: /healthz
          readinessProbe:
            httpGet:
              path: /healthz
Check to ensure you have two revisions of the greeter service:

revisions
kubectl

oc

oc --namespace knativetutorial get rev \
 --selector=serving.knative.dev/service=greeter \
 --sort-by="{.metadata.creationTimestamp}"

The command above should list two revisions namely greeter-v1 and greeter-v2.

add -oyaml to the commands above to see more detail

Applying Blue-Green Deployment Pattern
Knative offers a simple way of switching 100% of the traffic from one Knative service revision (blue) to another newly rolled out revision (green). If the new revision (e.g. green) has erroneous behavior then it is easy to rollback the change.

In this exercise you will applying theBlue/Green deployment pattern with the Knative Service called greeter. You have already deployed two revisions of greeter named greeter-v1 and greeter-v2 earlier in this chapter.

With the deployment of greeter-v2 you noticed that Knative automatically started to routing 100% of the traffic to greeter-v2. Now let us assume that we need to roll back greeter-v2 to greeter-v1 for some critical reason.

The following Knative Service YAML is identical to the previously deployed greeter-v2 except that we have added the traffic section to indicate that 100% of the traffic should be routed to greeter-v1.

All traffic to greeter-v1
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: greeter
spec:
  template:
    metadata:
      name: greeter-v1
    spec:
      containers:
        - image: quay.io/rhdevelopers/knative-tutorial-greeter:quarkus
          livenessProbe:
            httpGet:
              path: /healthz
          readinessProbe:
            httpGet:
              path: /healthz
  traffic:
    - tag: v1
      revisionName: greeter-v1
      percent: 100
    - tag: v2
      revisionName: greeter-v2
      percent: 0
    - tag: latest
      latestRevision: true
      percent: 0
The above service definition creates three sub-routes(named after traffic tags) to existing greeter route.

v1 - The revision is going to have all 100% traffic distribution

v2 - The previously active revision, which will now have zero traffic

latest - The route pointing to any latest service deployment, by setting to zero we are making sure the latest revision is not picked up automatically.

If you observe the resource YAML above, we have added a special tag latest. Since you have defined that all 100% of traffic need to go to greeter-v1, this tag can be used to suppress the default behavior of Knative Service to route all 100% traffic to latest revision.

Before you apply the resource $BOOK_HOME/basics/service-pinned.yaml, call the greeter service again to verify that it is still providing the response from greeter-v2 that includes Namaste.

$ $BOOK_HOME/bin/call.sh
Namaste  greeter => '9861675f8845' : 1

$ kubectl get pods
NAME                                    READY   STATUS    AGE
greeter-v2-deployment-9984bb56d-gr4gp   2/2     Running   14s
Now apply the update Knative service configuration using the command as shown in following listing:

Create greeter deployment (blue)
kubectl -n knativetutorial apply -f service-pinned.yaml
Let us list the available sub-routes:

kubectl

oc

oc -n knativetutorial get ksvc greeter -oyaml \
  | yq r - 'status.traffic[*].url'

The above command should return you three sub-routes for the main greeter route:

- http://current-greeter.knativetutorial.example.com 
- http://prev-greeter.knativetutorial.example.com 
- http://latest-greeter.knativetutorial.example.com 
the sub route for the traffic tag current
the sub route for the traffic tag prev
the sub route for the traffic tag latest
You will notice that the command does not create any new configuration/revision/deployment as there was no application update (e.g. image tag, env var, etc), but when you call the service, Knative scales up the greeter-v1 and the service responds with the text Hi greeter ⇒ '9861675f8845' : 1.

$ $BOOK_HOME/bin/call.sh
Hi  greeter => '9861675f8845' : 1

$ kubectl get pods
NAME                                     READY   STATUS    AGE
greeter-v1-deployment-6f75dfd9d8-s5bvr   2/2     Running   5s
As an exercise, flip all the traffic back to greeter-v2 (green). You need to edit the traffic block of the service-pinned.yaml and update the revision name to greeter-v2. After you redeploy the service-pinned.yaml, try calling the service again to notice the difference. If everything went smooth you will notice the service calls will now go to only greeter-v2.

Applying Canary Release Pattern
A Canary release is more effective when you want to reduce the risk of introducing new feature. It allows you a more effective feature-feedback loop before rolling out the change to your entire user base.

Knative allows you to split the traffic between revisions in increments as small as 1%.

To see this in action, apply the following Knative service definition that will split the traffic 80% to 20% between greeter-v1 and greeter-v2.

Canary between greeter v1 and v2
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: greeter
spec:
  template:
    metadata:
      name: greeter-v2
    spec:
      containers:
        - image: quay.io/rhdevelopers/knative-tutorial-greeter:quarkus
          env:
            - name: MESSAGE_PREFIX
              value: Namaste
          livenessProbe:
            httpGet:
              path: /healthz
          readinessProbe:
            httpGet:
              path: /healthz
  traffic:
    - tag: v1
      revisionName: greeter-v1
      percent: 80
    - tag: v2
      revisionName: greeter-v2
      percent: 20
    - tag: latest
      latestRevision: true
      percent: 0
To roll out the greeter canary deployment use the following command:

Create greeter canary Deployment
$ kubectl -n knativetutorial apply -f service-canary.yaml
As in the previous section on Applying Blue-Green Deployment Pattern deployments, the command will not create any new configuration/revision/deployment. To observe the traffic distribution you need to run the script $BOOK_HOME/bin/poll.sh, which is almost identical to $BOOK_HOME/bin/call.sh but will invoke the Knative service in a loop.

Verify Canary rollout
$ $BOOK_HOME/bin/poll.sh
With the poll.sh script running you will see that approximately 80% of the responses are returned from greeter-v1 and approximately 20% from greeter-v2. See the listing below for sample output:

Sample greeter Canary roll out output
Hi  greeter => '9861675f8845' : 1
Hi  greeter => '9861675f8845' : 2
Namaste  greeter => '9861675f8845' : 1
Hi  greeter => '9861675f8845' : 3
Hi  greeter => '9861675f8845' : 4
Hi  greeter => '9861675f8845' : 5
Hi  greeter => '9861675f8845' : 6
Hi  greeter => '9861675f8845' : 7
Hi  greeter => '9861675f8845' : 8
Hi  greeter => '9861675f8845' : 9
Hi  greeter => '9861675f8845' : 10
Hi  greeter => '9861675f8845' : 11
Namaste  greeter => '9861675f8845' : 2
Hi  greeter => '9861675f8845' : 12
Hi  greeter => '9861675f8845' : 13
Hi  greeter => '9861675f8845' : 14
Hi  greeter => '9861675f8845' : 15
Hi  greeter => '9861675f8845' : 16
...
You should also notice that two pods are running representing both greeter-v1 and greeter-v2:

$ watch kubectl get pods
NAME                                     READY   STATUS    AGE
greeter-v1-deployment-6f75dfd9d8-86q89   2/2     Running   12s
greeter-v2-deployment-9984bb56d-n7xvm    2/2     Running   2s
As a challenge, adjust the traffic distribution and observe the responses while the poll.sh script is actively running.

Cleanup
kubectl

oc

oc -n knativetutorial delete services.serving.knative.dev greeter

SCALING

Knative Tutorial
At the end of this chapter you will be able to:

Understand what scale-to-zero is and why it’s important.

Configure the scale-to-zero time period.

Configure the autoscaler.

Understand types of autoscaling strategies.

Enable concurrency based autoscaling.

Configure a minimum number of replicas for a service.

Prerequisites
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

Navigate to the tutorial chapter’s basics folder:

cd $TUTORIAL_HOME/basics

Deploy Service
The following snippet shows what a Knative service YAML will look like:

service.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: greeter
spec:
  template:
    spec:
      containers:
      - image: quay.io/rhdevelopers/knative-tutorial-greeter:quarkus
        livenessProbe:
          httpGet:
            path: /healthz
        readinessProbe:
          httpGet:
            path: /healthz
The service can be deployed using the command:

kubectl

oc

oc apply -n knativetutorial -f service.yaml

After the deployment of the service was successful we should see a Kubernetes deployment like greeter-v1-deployment.

Invoke Service
Kubernetes

OpenShift

export SVC_URL=`oc get rt greeter -o yaml | yq read - 'status.url'` && \
http $SVC_URL

The last http command should return a response like Hi greeter ⇒ '9be9ccd9a2e3' : 1

Check deployed Knative resources for more details on which Knative objects and resources have been created with the service deployment above.

Scale to zero
Assuming that Greeter service has been deployed, once no more traffic is seen going into that service, we’d like to scale this service down to zero replicas. That’s called scale-to-zero.

Scale-to-zero is one of the main properties making Knative a serverless platform. After a defined time of idleness (the so called stable-window) a revision is considered inactive. Now, all routes pointing to the now inactive revision will be pointed to the so-called activator. This reprogramming of the network is asynchronous in nature so the scale-to-zero-grace-period should give enough slack for this to happen. Once the scale-to-zero-grace-period is over, the revision will finally be scaled to zero replicas.

If another request tries to get to this revision, the activator will get it, instruct the autoscaler to create new pods for the revision as quickly as possible and buffer the request until those new pods are created.

By default the scale-to-zero-grace-period is 30s, and the stable-window is 60s. Firing a request to the greeter service will bring up the pod (if it is already terminated, as described above) to serve the request. Leaving it without any further requests will automatically cause it to scale to zero in approx 60-70 secs. There are at least 20 seconds after the pod starts to terminate and before it’s completely terminated. This gives Istio enough time to leave out the pod from its own networking configuration.

For better clarity and understanding let us clean up the deployed Knative resources before going to next section.

Auto Scaling
By default Knative Serving allows 100 concurrent requests into a pod. This is defined by the container-concurrency-target-default setting in the configmap config-autoscaler in the knative-serving namespace.

For this exercise let us make our service handle only 10 concurrent requests. This will cause Knative autoscaler to scale to more pods as soon as we run more than 10 requests in parallel against the revision.

Service with concurrency of 10 requests
service-10.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: prime-generator
spec:
  template:
    metadata:
      annotations:
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
The Knative service definition above will allow each service pod to handle max of 10 in-flight requests per pod (configured via autoscaling.knative.dev/target annotation) before automatically scaling to new pod(s)

Deploy service
kubectl

oc

oc apply -n knativetutorial -f service-10.yaml

Invoke Service
We will not invoke the service directly as we need to send the load to see the autoscaling:

Open a new terminal and run the following command:

kubectl

oc

watch 'oc get pods -n knativetutorial'

Load the service
We will now send some load to the greeter service. The command below sends 50 concurrent requests (-c 50) for the next 10s (-z 30s)

Kubernetes

OpenShift

hey -c 50 -z 10s \
  "${SVC_URL}/?sleep=3&upto=10000&memload=100"

After you’ve successfully run this small load test, you will notice the number of greeter service pods will have scaled to 5 automatically.

The autoscale pods is computed using the formula:

totalPodsToScale = inflightRequests / concurrencyTarget
With this current setting of concurrencyTarget=10 and inflightRequests=50 , you will see Knative automatically scales the greeter services to 50/10 = 5 pods.

For more clarity and understanding let us clean up existing deployments before proceeding to next section.

Minimum Scale
In real world scenarios your service might need to handle sudden spikes in requests. Knative starts each service with a default of 1 replica. As described above, this will eventually be scaled to zero as described above. If your app needs to stay particularly responsive under any circumstances and/or has a long startup time, it might be beneficial to always keep a minimum number of pods around. This can be done via an the annotation autoscaling.knative.dev/minScale.

The following example shows how to make Knative create services that start with a replica count of 2 and never scale below it.

Deploy service
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

Cleanup
kubectl

oc

oc -n knativetutorial delete services.serving.knative.dev greeter &&\
oc -n knativetutorial delete services.serving.knative.dev prime-generator