+++
description = ""
+++

<!-- https://kubebyexample.com/en/learning-paths/application-development-kubernetes/lesson-2-deploying-managed-applications/guided -->

## Guided Exercise: Deploying Managed Applications

In this exercise you will deploy a managed containerized application in your Kubernetes cluster.
You will observe how automatic deployment works and some of the High Availability features of Kubernetes.

## Outcomes

You should be able to:

- Deploy an application container with several replicas.
- Review the structure of the Deployment resource manifest.
- Update the application to a new version without losing availability.

## Prerequisites

You need a working Kubernetes cluster, and your kubectl command must be configured to communicate with the cluster.

Make sure your kubectl context refers to a namespace where you have enough permissions, usually username-dev or username-stage.
Use the kubectl config set-context --current --namespace=namespace command to switch to the appropriate namespace.

## Instructions

In this exercise, you will deploy an existing application by using the container image quay.io/redhattraining/do100-versioned-hello:v1.0.

1) Create a default deployment that starts one replica of the do100-versioned-hello application and review the deployment was successful.

1.1) Use the kubectl create deployment command to create the deployment.
Name the deployment do100-versioned-hello.

```bash
[user@host ~]$ kubectl create deployment do100-versioned-hello --image quay.io/redhattraining/do100-versioned-hello:v1.0
deployment.apps/do100-versioned-hello created
```

1.2) Validate that the deployment created the expected application pod.
Use the kubectl get pods -w command in a new terminal.
Keep the command running for observing further updates.

```bash
[user@host ~]$ kubectl get pods -w
NAME                                     READY   STATUS    RESTARTS   AGE
do100-versioned-hello-76c4494b5d-4ldff   1/1     Running   0          51m
```

1.3) Use the kubectl describe deployment command to get relevant information about the deployment:

```bash
[user@host ~]$ kubectl describe deployment do100-versioned-helloName:               do100-versioned-hello
...output omitted...
Labels:             app=do100-versioned-hello
...output omitted...
Selector:           app=do100-versioned-hello
Replicas:           1 desired | 1 updated | 1 total | 1 available | 0 unavailable
...output omitted...
Pod Template:
  Labels:  app=do100-versioned-hello
  Containers:
   do100-versioned-hello:
    Image:        quay.io/redhattraining/do100-versioned-hello:v1.0
...output omitted...
```

Optionally, use the kubectl get deployment command to get the full manifest for the deployment:

```bash
[user@host ~]$ kubectl get deployment do100-versioned-hello -o yaml
apiVersion: apps/v1
kind: Deployment
...output omitted...
  labels:
    app: do100-versioned-hello
  name: do100-versioned-hello
...output omitted...
spec:
...output omitted...
  replicas: 1
...output omitted...
  selector:
    matchLabels:
      app: do100-versioned-hello
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
...output omitted...
      labels:
        app: do100-versioned-hello
    spec:
      containers:
      - image: quay.io/redhattraining/do100-versioned-hello:v1.0
...output omitted...
        name: do100-versioned-hello
...output omitted...
```

2) Enable high availability by increasing the number of replicas to two.

2.1) Edit the number of replicas in the Deployment resource using the kubectl scale deployment command:

```bash
[user@host ~]$ kubectl scale deployment do100-versioned-hello --replicas=2
deployment.apps/do100-versioned-hello scaled
```

2.2) Validate that Kubernetes deployed a new replica pod.
Go back to the terminal where the kubectl get pods -w command is running.
Observe how the output displays a new pod named do100-versioned-hello-76c4494b5d-qtfs9.
The pod updates from the Pending status to ContainerCreating and finally to Running.

```bash
[user@host ~]$ kubectl get pods -w
NAME                                    READY  STATUS             RESTARTS  AGE
do100-versioned-hello-76c4494b5d-4ldff  1/1    Running            0         51m
do100-versioned-hello-76c4494b5d-qtfs9  0/1    Pending            0         0sdo100-versioned-hello-76c4494b5d-qtfs9  0/1    Pending            0         0sdo100-versioned-hello-76c4494b5d-qtfs9  0/1    ContainerCreating  0         0sdo100-versioned-hello-76c4494b5d-qtfs9  1/1    Running            0         2s
```

3) Verify high availability features in Kubernetes.
Kubernetes must ensure that two replicas are available at all times.
Terminate one pod and observe how Kubernetes creates a new pod to ensure the desired number of replicas.

3.1) Terminate one of the pods by using the kubectl delete pod command.
This action emulates a failing application or unexpected pod unavailability.

```bash
[user@host ~]$ kubectl delete pod do100-versioned-hello-76c4494b5d-qtfs9
```

This example terminates the pod named do100-versioned-hello-76c4494b5d-qtfs9.
Use a pod name from your list of pods, which are displayed in the terminal that is running the kubectl get pods -w command.

3.2) In the terminal running the kubectl get pods -w command, observe that the deleted pod changed to the Terminating status.

```bash
[user@host ~]$ kubectl get pods -w
NAME                                    READY  STATUS             RESTARTS AGE
do100-versioned-hello-76c4494b5d-4ldff  1/1    Running            0        51m
do100-versioned-hello-76c4494b5d-qtfs9  0/1    Pending            0        0s
do100-versioned-hello-76c4494b5d-qtfs9  0/1    Pending            0        0s
do100-versioned-hello-76c4494b5d-qtfs9  0/1    ContainerCreating  0        0s
do100-versioned-hello-76c4494b5d-qtfs9  1/1    Running            0        2s
do100-versioned-hello-76c4494b5d-qtfs9  1/1    Terminating        0        97m
...output omitted...
```

Immediately after the pod becomes unavailable, Kubernetes creates a new replica:

```bash
[user@host ~]$ kubectl get pods -w
NAME                                   READY STATUS            RESTARTS AGE
do100-versioned-hello-76c4494b5d-4ldff 1/1   Running           0        51m
do100-versioned-hello-76c4494b5d-qtfs9 0/1   Pending           0        0s
do100-versioned-hello-76c4494b5d-qtfs9 0/1   Pending           0        0s
do100-versioned-hello-76c4494b5d-qtfs9 0/1   ContainerCreating 0        0s
do100-versioned-hello-76c4494b5d-qtfs9 1/1   Running           0        2s
do100-versioned-hello-76c4494b5d-qtfs9 1/1   Terminating       0        97m
do100-versioned-hello-76c4494b5d-8qmk8 0/1   Pending           0        0sdo100-versioned-hello-76c4494b5d-8qmk8 0/1   Pending           0        0sdo100-versioned-hello-76c4494b5d-8qmk8 0/1   ContainerCreating 0        1s
do100-versioned-hello-76c4494b5d-qtfs9 0/1   Terminating       0        97m
do100-versioned-hello-76c4494b5d-8qmk8 1/1   Running           0        2s
...output omitted...
```

> **Note**:
> 
> The Terminating and Pending status might appear many times in the output.
> This repetition reflects the fact that those statuses are aggregating status for another fine-grained status for the deployment.

4) Deploy a new version of the application and observe the default deployment rollingUpdate strategy.

4.1) Edit the deployment and update the container image version from v1.0 to v1.1.
Use the kubectl edit deployment command to edit the Deployment manifest:

```bash
[user@host ~]$ kubectl edit deployment do100-versioned-hello
```

Look for the image: quay.io/redhattraining/do100-versioned-hello:v1.0 entry and change the image tag from v1.0 to v1.1.
Save the changes and exit the editor.

4.2) Analyze the status timeline for the pods.
Observe how Kubernetes orchestrates the termination and deployment of the pods.
The maximum unavailability is zero pods (25% of 2 pods, rounding down), so there must always be at least two available replicas.
The maximum surge is 1 (20% of 2 pods, rounding up), so Kubernetes will create new replicas one by one.

```bash
[user@host ~]$ kubectl get pods -w
NAME                                    READY STATUS            RESTARTS AGE
...output omitted...
do100-versioned-hello-76c4494b5d-qtfs9  1/1   Running           0        2s
...output omitted...
do100-versioned-hello-76c4494b5d-8qmk8  1/1   Running           0        2s(1)
...output omitted...
do100-versioned-hello-76c4494b5d-7729k  0/1   Pending           0        0s(2)
do100-versioned-hello-76c4494b5d-7729k  0/1   Pending           0        0s
do100-versioned-hello-76c4494b5d-7729k  0/1   ContainerCreating 0        0s
do100-versioned-hello-76c4494b5d-7729k  1/1   Running           0        1s(3)do100-versioned-hello-77fc5857fc-qtfs9  1/1   Terminating       0        4m46s(4)do100-versioned-hello-76c4494b5d-vrlkw  0/1   Pending           0        0s(5)
do100-versioned-hello-76c4494b5d-vrlkw  0/1   Pending           0        0s
do100-versioned-hello-76c4494b5d-vrlkw  0/1   ContainerCreating 0        0s
do100-versioned-hello-77fc5857fc-qtfs9  0/1   Terminating       0        4m47s
do100-versioned-hello-77fc5857fc-qtfs9  0/1   Terminating       0        4m48s
do100-versioned-hello-77fc5857fc-qtfs9  0/1   Terminating       0        4m48s
do100-versioned-hello-77fc5857fc-qtfs9  0/1   Terminating       0        4m48s
do100-versioned-hello-76c4494b5d-vrlkw  1/1   Running           0        2s(6)do100-versioned-hello-77fc5857fc-8qmk8  1/1   Terminating       0        4m49s(7)
do100-versioned-hello-77fc5857fc-8qmk8  0/1   Terminating       0        4m50s
```

Rollout starts.
At this point, two v1.0 replicas are available.

Kubernetes creates a single new v1.1 replica, as maxSurge limits the over-deployment to one.

The new v1.1 replica is running and becomes available.

There are three pods available, so Kubernetes terminates the do100-versioned-hello-77fc5857fc-qtfs9 pod (v1.0 replica).

After starting the termination, the number of available pods is two, so Kubernetes starts a new v1.1 replica.

The new v1.1 replica is running and becomes available.

Again, three pods are available, so Kubernetes terminates the last v1.0 replica.

## Finish

Delete the deployment to clean your cluster.
Kubernetes automatically deletes the associated pods.

```bash
[user@host ~]$ kubectl delete deployment do100-versioned-hello
deployment.apps "do100-versioned-hello" deleted
```

Observe in the other terminal that Kubernetes automatically terminates all pods associated with the deployment:

```bash
[user@host ~]$ kubectl get pods -w
NAME                                     READY   STATUS           RESTARTS   AGE
...output omitted...
do100-versioned-hello-77fc5857fc-8qmk8   0/1     Terminating      0          4m50s
do100-versioned-hello-76c4494b5d-7729k   1/1     Terminating      0          5m35sdo100-versioned-hello-76c4494b5d-vrlkw   1/1     Terminating      0          5m35sdo100-versioned-hello-76c4494b5d-7729k   0/1     Terminating      0          5m35sdo100-versioned-hello-76c4494b5d-vrlkw   0/1     Terminating      0          5m35s
...output omitted...
```

Press `Ctrl+C` to exit the `kubectl get pods -w` command.

This concludes the guided exercise.
