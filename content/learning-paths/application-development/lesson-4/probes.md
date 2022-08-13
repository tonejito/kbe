+++
description = ""
+++

<!-- https://kubebyexample.com/en/learning-paths/application-development-kubernetes/lesson-4-customize-deployments-application-2 -->

# Liveness, Readiness, and Startup Probes

## Objectives

After completing this section, you should be able to review how Kubernetes evaluates application health status via probes and automatic application restart.

## Kubernetes Readiness and Liveness Probes

Applications can become unreliable for a variety of reasons, for example:

- Temporary connection loss
- Configuration errors
- Application errors

Developers can use probes to monitor their applications. Probes make developers aware of events such as application status, resource usage, and errors.

Monitoring of such events is useful for fixing problems, but can also help with resource planning and managing.

A probe is a periodic check that monitors the health of an application. Developers can configure probes by using either the kubectl command-line client or a YAML deployment template.

There are currently three types of probes in Kubernetes:

**Startup Probe**
: A startup probe verifies whether the application within a container is started.
: Startup probes run before any other probe, and, unless it finishes successfully, disables other probes.
: If a container fails its startup probe, then the container is killed and follows the pod's restartPolicy.

This type of probe is only executed at startup, unlike readiness probes, which are run periodically.

The startup probe is configured in the spec.containers.startupprobe attribute of the pod configuration.

**Readiness Probe**
: Readiness probes determine whether or not a container is ready to serve requests.
If the readiness probe returns a failed state, then Kubernetes removes the IP address for the container from the endpoints of all Services.

Developers use readiness probes to instruct Kubernetes that a running container should not receive any traffic. This is useful when waiting for an application to perform time-consuming initial tasks, such as establishing network connections, loading files, and warming caches.

The readiness probe is configured in the spec.containers.readinessprobe attribute of the pod configuration.

**Liveness Probe**
: Liveness probes determine whether or not an application running in a container is in a healthy state.
: If the liveness probe detects an unhealthy state, then Kubernetes kills the container and tries to redeploy it.

The liveness probe is configured in the spec.containers.livenessprobe attribute of the pod configuration.

Kubernetes provides five options that control these probes:

| Name                  | Mandatory | Default Value | Description
|:---------------------:|:---------:|:-------------:|:-----------:
| `initialDelaySeconds` | Yes       |             0 | Determines how long to wait after the container starts before beginning the probe.
| `timeoutSeconds`      | Yes       |             1 | Determines how long to wait for the probe to finish. If this time is exceeded, then Kubernetes assumes that the probe failed.
| `periodSeconds`       | No        |            10 | Specifies the frequency of the checks.
| `successThreshold`    | No        |             1 | Specifies the minimum consecutive successes for the probe to be considered successful after it has failed.
| `failureThreshold`    | No        |             3 | Specifies the minimum consecutive failures for the probe to be considered failed after it has succeeded.

## Methods of Checking Application Health

Startup, readiness, and liveness probes can check the health of applications in three ways: HTTP checks, container execution checks, and TCP socket checks.

### HTTP Checks

An HTTP check is ideal for applications that return HTTP status codes, such as REST APIs.

HTTP probe uses GET requests to check the health of an application. The check is successful if the HTTP response code is in the range 200-399.

The following example demonstrates how to implement a readiness probe with the HTTP check method:

```yaml
...contents omitted...
readinessProbe:
  httpGet:
    path: /health (1)
    port: 8080
  initialDelaySeconds: 15 (2)
  timeoutSeconds: 1 (3)
...contents omitted...
```

1. The readiness probe endpoint.

2. How long to wait after the container starts before checking its health.

3. How long to wait for the probe to finish.

### Container Execution Checks

Container execution checks are ideal in scenarios where you must determine the status of the container based on the exit code of a process or shell script running in the container.

When using container execution checks Kubernetes executes a command inside the container. Exiting the check with a status of 0 is considered a success. All other status codes are considered a failure.

The following example demonstrates how to implement a container execution check:

```yaml
...contents omitted...
livenessProbe:
  exec:
    command: (1)
    - cat
    - /tmp/health
  initialDelaySeconds: 15
  timeoutSeconds: 1
...contents omitted...
```

1. The command to run and its arguments, as a YAML array.

### TCP Socket Checks

A TCP socket check is ideal for applications that run as daemons, and open TCP ports, such as database servers, file servers, web servers, and application servers.

When using TCP socket checks Kubernetes attempts to open a socket to the container. The container is considered healthy if the check can establish a successful connection.

The following example demonstrates how to implement a liveness probe by using the TCP socket check method:

```yaml
...contents omitted...
livenessProbe:
  tcpSocket:
    port: 8080 (1)
  initialDelaySeconds: 15
  timeoutSeconds: 1
...contents omitted...
```

1. The TCP port to check.

## Creating Probes

To configure probes on a deployment, edit the deployment's resource definition. To do this, you can use the kubectl edit or kubectl patch commands. Alternatively, if you already have a deployment YAML definition, you can modify it to include the probes and then apply it with kubectl apply.

The following example demonstrates using the kubectl edit command to add a readiness probe to a deployment:

> **Note**:
>
> This will open your system's default editor with the deployment definition.
> Once you make the necessary changes, save and quit the editor to apply them.

```bash
[user@host ~]$ kubectl set probe deployment myapp --readiness \
--get-url=http://:8080/healthz --period=20

[user@host ~]$ kubectl patch deployment myapp \
-p '{"spec":{"containers"[0]: {"readinessProbe": {}}}}'
```

The following examples demonstrate using the kubectl set probe command with a variety of options:

```bash
[user@host ~]$ kubectl set probe deployment myapp --readiness \
--get-url=http://:8080/healthz --period=20

[user@host ~]$ kubectl set probe deployment myapp --liveness \
--open-tcp=3306 --period=20 \
--timeout-seconds=1

[user@host ~]$ kubectl set probe deployment myapp --liveness \
--get-url=http://:8080/healthz --initial-delay-seconds=30 \
--success-threshold=1 --failure-threshold=3
```
