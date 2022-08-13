+++
description = ""
+++

<!-- https://kubebyexample.com/en/learning-paths/application-development-kubernetes/lesson-4-customize-deployments-application-1 -->

# Guided Exercise: Limiting Resource Usage

## Outcomes

You should be able to use the Kubernetes command-line interface to:

- Configure an application to specify resource requests for CPU and memory usage.

- Modify an application to work within existing cluster restrictions.

## Prerequisites

You need a working Kubernetes cluster, and your kubectl command must be configured to communicate with the cluster.

Make sure your kubectl context refers to a namespace where you have enough permissions, usually username-dev or username-stage. Use the kubectl config set-context --current --namespace=namespace command to switch to the appropriate namespace.

## Instructions

1) Deploy a test application for this exercise that explicitly requests container resources for CPU and memory.

1.1) Create a deployment resource file and save it to a file named hello-limit.yaml. Name the application hello-limit and use the container image located at quay.io/redhattraining/hello-world-nginx:v1.0.

> **Note**:
>
> This course uses the backslash character (`\`) to break long commands.
> On Linux and macOS, you can use the line breaks.
>
> On Windows, use the backtick character (<code>&#96;</code>) to break long commands.
>
> Alternatively, do not break long commands.

```bash
[user@host ~]$ kubectl create deployment hello-limit \
  --image quay.io/redhattraining/hello-world-nginx:v1.0 \
  --dry-run=client -o yaml > hello-limit.yaml
```

1.2) Edit the file hello-limit.yaml to replace the resources: {} line with the highlighted lines below. Ensure that you have proper indentation before saving the file.

```yaml
...output omitted...
    spec:
      containers:
      - image: quay.io/redhattraining/hello-world-nginx:v1.0
        name: hello-world-nginx
        resources:requests:cpu: "8"memory: 20Mi
status: {}
```

1.3) Create the new application using your resource file.

```bash
[user@host ~]$ kubectl create --save-config -f hello-limit.yaml
deployment.apps/hello-limit created
```

1.4) Although a new deployment was created for the application, the application pod should have a status of Pending.

```bash
[user@host ~]$ kubectl get pods
NAME                            READY   STATUS      RESTARTS   AGE
hello-limit-d86874d86b-fpmrt    0/1     Pending     0          10s
```

1.5) The pod cannot be customized because none of the compute nodes have sufficient CPU resources. This can be verified by viewing warning events.

```bash
[user@host ~]$ kubectl get events --field-selector type=Warning
LAST SEEN   TYPE      REASON             OBJECT                            MESSAGE
88s         Warning   FailedScheduling   pod/hello-limit-d86874d86b-fpmrt  0/3 nodes are available: 8 Insufficient cpu.
```

2) Redeploy your application so that it requests fewer CPU resources.

2.1) Edit the hello-limit.yaml file to request 1.2 CPUs for the container. Change the cpu: "8" line to match the highlighted line below.

```yaml
...output omitted...
        resources:
          requests:
            cpu: "1200m"
            memory: 20Mi
```

2.2) Apply the changes to your application.

```bash
[user@host ~]$ kubectl apply -f hello-limit.yaml
deployment.apps/hello-limit configured
```

2.3) Verify that your application deploys successfully. You might need to run kubectl get pods multiple times until you see a running pod. The previous pod with a pending status will terminate and eventually disappear.

```bash
[user@host ~]$ kubectl get pods
NAME                           READY   STATUS        RESTARTS   AGE
hello-limit-d86874d86b-fpmrt   0/1     Terminating   0          2m19s
hello-limit-7c7998ff6b-ctsjp   1/1     Running       0          6s
```

> **Note**:
>
> If your application pod does not get customized, modify the hello-limit.yaml file to reduce the CPU request to 1000m.
> Apply the changes again and verify the pod status is Running.

## Finish

Delete the created resources to clean your cluster.

```bash
[user@host ~] kubectl delete -f hello-limit.yaml
deployment.apps "hello-limit" deleted

[user@host ~] rm hello-limit.yaml
```
