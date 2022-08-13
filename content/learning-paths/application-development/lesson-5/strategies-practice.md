+++
description = ""
+++

<!-- https://kubebyexample.com/en/learning-paths/application-development-kubernetes/lesson-5-implementing-cloud-deployment-0 -->

# Guided Exercise: Implementing Cloud Deployment Strategies

## Outcomes

You should be able to:

- Deploy an application container with several replicas.

- Review the structure of the Deployment resource manifest.

- Update the application to a new version without losing availability.

## Prerequisites

You need a working Kubernetes cluster, and your kubectl command must be configured to communicate with the cluster.

Make sure your kubectl context refers to a namespace where you have enough permissions, usually username-dev or username-stage. Use the kubectl config set-context --current --namespace=namespace command to switch to the appropriate namespace.

## Instructions

1) Deploy a Node.js application container to your Kubernetes cluster.

1.1) Use the kubectl create command to create a new application with the following parameters:

> **Note**:
>
> This course uses the backslash character (`\`) to break long commands.
> On Linux and macOS, you can use the line breaks.
>
> On Windows, use the backtick character (<code>&#96;</code>) to break long commands.
>
> Alternatively, do not break long commands.

```bash
[user@host ~]$ kubectl create deployment do100-multi-version \
--replicas=5 \
--image quay.io/redhattraining/do100-multi-version:v1
deployment.apps/do100-multi-version created
```

1.2) Wait until the pod is deployed. The pod should be in the READY state.

```bash
[user@host ~]$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS      AGE
do100-multi-version-788cb59f94-54lcz   1/1     Running   0               4s
do100-multi-version-788cb59f94-cv4dd   1/1     Running   0               4s
do100-multi-version-788cb59f94-nt2lh   1/1     Running   0               4s
do100-multi-version-788cb59f94-snx4f   1/1     Running   0               4s
do100-multi-version-788cb59f94-x7k7n   1/1     Running   0               4s
```

Note that the exact names of your pods will likely differ from the previous example.

1.3) Review the application logs to see the running version.

```bash
[user@host ~] kubectl logs deploy/do100-multi-version
Found 5 pods, using pod/do100-multi-version-788cb59f94-54lcz

> multi-version@1.0.0 start /opt/app-root/src
> node app.js

do100-multi-version server running version 1.0 on http://0.0.0.0:8080
```

Note the version number that the application logs.

2) Edit the deployment to change the application version and add a readiness probe.

2.1) Verify that the deployment strategy for the application is RollingUpdate:

```bash
[user@host ~]$ kubectl describe deploy/do100-multi-version...output omitted...
StrategyType:           RollingUpdate
...output omitted...
```

2.2) Use kubectl edit to modify the deployment resource.

```bash
[user@host ~] kubectl edit deployment/do100-multi-version...output omitted...
```

2.3) Update the version of the image to v2. Additionally, configure a readiness probe so that you can watch the new deployment as it happens.

Your deployment resource should look like the following:

```yaml
...output omitted...
spec:
  ...output omitted...
  template:
    ...output omitted...
    spec:
      containers:
      - image: quay.io/redhattraining/do100-multi-version: v2...output omitted...
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 2
          timeoutSeconds: 2
```

When you are done, save your changes and close the editor.

3) Verify that the new version of the application is deployed via the rolling deployment strategy.

3.1) Watch the pods as Kubernetes redeploys the application.

```bash
[user@host ~]$ kubectl get pods -w
NAME                                   READY   STATUS              RESTARTS   AGE
do100-multi-version-788cb59f94-54lcz   1/1     Running             0          5m28s
...output omitted...
do100-multi-version-8477f6f4bb-lnlcz   0/1     ContainerCreating   0          3s
...output omitted...
do100-multi-version-8477f6f4bb-lnlcz   0/1     Running             0          5s
do100-multi-version-8477f6f4bb-lnlcz   1/1     Running             0          40s
...output omitted...
do100-multi-version-788cb59f94-54lcz   0/1     Terminating         0          6m8s
...output omitted...
```

As the new application pods start and become ready, pods running the older version are terminated. Note that the application takes about thirty seconds to enter the ready state.

Press `Ctrl+C` to stop the command.

3.2) View the logs of the new version of the application.

```bash
[user@host ~] kubectl logs deploy/do100-multi-version
Found 5 pods, using pod/do100-multi-version-8477f6f4bb-9h5xl

> multi-version@1.0.0 start /opt/app-root/src
> node app.js

do100-multi-version server running version 2.0 on http://0.0.0.0:8080
```

## Finish

Delete the deployment to clean your cluster. Kubernetes automatically deletes the associated pods.

```bash
[user@host ~]$ kubectl delete deploy/do100-multi-version
deployment.apps "do100-multi-version" deleted
```
