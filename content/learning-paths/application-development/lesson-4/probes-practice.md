+++
description = ""
+++

<!-- https://kubebyexample.com/en/learning-paths/application-development-kubernetes/lesson-4-customize-deployments-application-3 -->

# Guided Exercise: Liveness, Readiness, and Startup Probes

## Activating Probes

In this exercise, you will configure liveness and readiness probes to monitor the health of an application deployed to your Kubernetes cluster.

The application you deploy in this exercise exposes two HTTP GET endpoints:

- The /healthz endpoint responds with a 200 HTTP status code when the application pod can receive requests.

  The endpoint indicates that the application pod is healthy and reachable. It does not indicate that the application is ready to serve requests.

- The /ready endpoint responds with a 200 HTTP status code if the overall application works.

  The endpoint indicates that the application is ready to serve requests.

In this exercise, the /ready endpoint responds with the 200 HTTP status code when the application pod starts. The /ready endpoint responds with the 503 HTTP status code for the first 30 seconds after deployment to simulate slow application startup.

You will configure the /healthz endpoint for the liveness probe, and the /ready endpoint for the readiness probe.

You will simulate network failures in your Kubernetes cluster and observe behavior in the following scenarios:

- The application is not available.

- The application is available but cannot reach the database. Consequently, it cannot serve requests.

## Outcomes

You should be able to:

- Configure readiness and liveness probes for an application from the command line.

- Locate probe failure messages in the event log.

## Prerequisites

You need a working Kubernetes cluster, and your kubectl command must be configured to communicate with the cluster.

Make sure your kubectl context refers to a namespace where you have enough permissions, usually username-dev or username-stage. Use the kubectl config set-context --current --namespace=namespace command to switch to the appropriate namespace.

## Instructions

1) Deploy the do100-probes sample application to the Kubernetes cluster and expose the application.

1.1) Create a new deployment by using kubectl.

> **Note**:
>
> This course uses the backslash character (`\`) to break long commands.
> On Linux and macOS, you can use the line breaks.
>
> On Windows, use the backtick character (<code>&#96;</code>) to break long commands.
>
> Alternatively, do not break long commands.

```bash
[user@host ~]$ kubectl create deployment do100-probes \
--image quay.io/redhattraining/do100-probes:latest
deployment.apps/do100-probes created
```

1.2) Expose the deployment on port 8080.

```bash
[user@host ~]$ kubectl expose deployment/do100-probes --port 8080
service/do100-probes exposed
```

1.3) Use a text editor to create a file in your current directory called probes-ingress.yml.

Create the probes-ingress.yml file with the following content. Ensure correct indentation (using spaces rather than tabs) and then save the file.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: do100-probes
  labels:
    app: do100-probes
spec:
  rules:
    - host: INGRESS-HOST
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: do100-probes
                port:
                  number: 8080
```

Replace INGRESS-HOST with the hostname associated with your Kubernetes cluster, such as hello.example.com or do100-probes-USER-dev.apps.sandbox.x8i5.p1.openshiftapps.com. If you are unsure of the hostname to use then refer to [Guided Exercise: Contrasting Kubernetes Distributions]() to find the appropriate value.

The file at https://github.com/RedHatTraining/DO100-apps/blob/main/probes/probes-ingress.yml contains the correct content for the probes-ingress.yml file. You can download the file and use it for comparison.

1.4) Use the kubectl create command to create the ingress resource.

```bash
[user@host ~]$ kubectl create -f probes-ingress.yml
ingress.networking.k8s.io/do100-probes created
```

2) Manually test the application's /ready and /healthz endpoints.

2.1) Display information about the do100-probes ingress. If the command does not display an IP address, then wait up to a minute and try running the command again.

```bash
[user@host ~]$ kubectl get ingress/do100-probes
NAME           CLASS   HOSTS               ADDRESS        PORTS   ...
do100-probes   nginx   hello.example.com   192.168.49.2   80      ...
```

The value in the HOST column matches the host line specified in your probes-ingress.yml file. Your IP address is likely different from the one displayed here.

2.2) Test the /ready endpoint:

```bash
[user@host ~]$ curl -i hello.example.com/ready
```

On Windows, remove -i flag:

```bash
[user@host ~]$ curl hello.example.com/ready
```

The /ready endpoint simulates a slow startup of the application, and so for the first 30 seconds after the application starts, it returns an HTTP status code of 503, and the following response:

```text
HTTP/1.1 503 Service Unavailable
...output omitted...
Error! Service not ready for requests...
```

After the application has been running for 30 seconds, it returns:

```text
HTTP/1.1 200 OK
...output omitted...
Ready for service requests...
```

2.3) Test the /healthz endpoint of the application:

```bash
[user@host ~]$ curl -i hello.example.com/healthz
HTTP/1.1 200 OK
...output omitted...
OK
```
On Windows, remove the -i flag:

```bash
[user@host ~]$ curl hello.example.com/healthz
```

2.4) Test the application response:

```bash
[user@host ~]$ curl hello.example.com
Hello! This is the index page for the app.
```

3) Activate readiness and liveness probes for the application.

3.1) Use the kubectl edit command to edit the deployment definition and add readiness and liveness probes.

- For the liveness probe, use the /healthz endpoint on the port 8080.

- For the readiness probe, use the /ready endpoint on the port 8080.

- For both probes:

    - Configure an initial delay of 2 seconds.

    - Configure the timeout as 2 seconds.

```bash
[user@host ~] kubectl edit deployment/do100-probes
...output omitted...
```

This command opens your default system editor. Make changes to the definition so that it displays as follows.

```yaml
...output omitted...
spec:
  ...output omitted...
  template:
    ...output omitted...
    spec:
      containers:
      - image: quay.io/redhattraining/do100-probes:latest
        ...output omitted...readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 2
          timeoutSeconds: 2
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 2
          timeoutSeconds: 2
```

> **WARNING**:
>
> The YAML resource is space sensitive. Use spaces to preserve the spacing.
>
> Do not use the tab character to edit the preceding deployment.

Save and exit the editor to apply your changes.

3.2) Verify the value in the livenessProbe and readinessProbe entries:

```bash
[user@host DO288-apps]$ kubectl describe deployment do100-probes
...output omitted...
Liveness:  http-get http://:8080/healthz delay=2s timeout=2s period=10s #success=1 #failure=3
Readiness: http-get http://:8080/ready   delay=2s timeout=2s period=10s #success=1 #failure=3
...output omitted...
```

3.3) Wait for the application pod to redeploy and change into the READY state:

```bash
[user@host ~]$ kubectl get pods
NAME                            READY   STATUS    RESTARTS      AGE
...output omitted...
do100-probes-7794c5cb4f-vwl4x   0/1     Running   0             6s
```

The READY status shows 0/1 if the AGE value is less than approximately 30 seconds. After that, the READY status is 1/1. Note the pod name for the following steps.

```bash
[user@host ~]$ kubectl get pods
NAME                            READY   STATUS    RESTARTS      AGE
...output omitted...
do100-probes-7794c5cb4f-vwl4x1/1     Running   0             62s
```

3.4) Use the kubectl logs command to see the results of the liveness and readiness probes. Use the pod name from the previous step.

```bash
[user@host ~]$ kubectl logs -f do100-probes-7794c5cb4f-vwl4x
...output omitted...
nodejs server running on http://0.0.0.0:8080
ping /healthz => pong [healthy]
ping /ready => pong [notready]
ping /healthz => pong [healthy]
ping /ready => pong [notready]
ping /healthz => pong [healthy]
ping /ready => pong [ready]
...output omitted...
```

Observe that the readiness probe fails for about 30 seconds after redeployment, and then succeeds. Recall that the application simulates a slow initialization of the application by forcibly setting a 30-second delay before it responds with a status of ready.

Do not terminate this command. You will continue to monitor the output of this command in the next step.

4) Simulate a network failure.

In case of a network failure, a service becomes unresponsive. This means both the liveness and readiness probes fail.

Kubernetes can resolve the issue by recreating the container on a different node.

4.1) In a different terminal window or tab, run the following commands to simulate a liveness probe failure:

```bash
[user@host ~]$ curl http://hello.example.com/flip?op=kill-health
Switched app state to unhealthy...

[user@host ~]$ curl http://hello.example.com/flip?op=kill-ready
Switched app state to not ready...
```

4.2) Return to the terminal where you are monitoring the application deployment:

```bash
[user@host ~]$ kubectl logs -f do100-probes-7794c5cb4f-vwl4x
...output omitted...
Received kill request for health probe.
Received kill request for readiness probe.
...output omitted...
ping /ready => pong [notready]
ping /healthz => pong [unhealthy]
...output omitted...
Received kill request for health probe.
...output omitted...
Received kill request for readiness probe.
...output omitted...
```

Kubernetes restarts the pod when the liveness probe fails repeatedly (three consecutive failures by default). This means Kubernetes restarts the application on an available node not affected by the network failure.

You see this log output only when you immediately check the application logs after you issue the kill request. If you check the logs after Kubernetes restarts the pod, then the logs are cleared and you only see the output shown in the next step.

4.3) Verify that Kubernetes restarts the unhealthy pod. Keep checking the output of the kubectl get pods command. Observe the RESTARTS column and verify that the count is greater than zero. Note the name of the new pod.

```bash
[user@host ~]$ kubectl get pods
NAME                           READY   STATUS    RESTARTS      AGE
do100-probes-95758759b-4cm2j   1/1     Running   1 (11s ago)   62s
```

4.4) Review the application logs. The liveness probe succeeds and the application reports a healthy state.

```bash
[user@host ~]$ kubectl logs -f do100-probes-95758759b-4cm2j
...output omitted...
ping /ready => pong [ready]
ping /healthz => pong [healthy]
...output omitted...
```

## Finish

Delete the deployment, ingress, and service resources to clean your cluster. Kubernetes automatically deletes the associated pods.

```bash
[user@host ~]$ kubectl delete deployment do100-probes
deployment.apps "do100-versioned-hello" deleted

[user@host ~]$ kubectl delete service do100-probes
service "do100-probes" deleted

[user@host ~]$ kubectl delete ingress do100-probes
ingress.networking.k8s.io "do100-probes" deleted
```
