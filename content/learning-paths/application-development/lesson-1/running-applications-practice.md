# **Guided Exercise**: Running and Interacting with Your First Application

In this exercise, you will create a pod and connect to it.
You will also create and manage a new namespace resource by using a resource definition file that you create.

## Outcomes

You should be able to:

- Connect a shell session to an existing pod.
- Create a resource definition file.
- Use a resource definition to create and update a namespace resource.

> **Note**
>
> You do not need to understand Kubernetes namespaces to do this exercise, as they are solely used as an example resource.

## Prerequisites

You need a working Kubernetes cluster, and your `kubectl` command must be configured to communicate with the cluster.

Ensure your `kubectl` context refers to the `user-dev` namespace.
Use the `kubectl config set-context --current --namespace=user-dev` command to switch to the appropriate namespace.

## Instructions

1) Use `kubectl` run and `kubectl exec` to create a new pod and attach a shell session to it.

1.1) Create a new pod named `webserver` that uses the `httpd` container image.

> **Note**:
>
> This course uses the backslash character (`\`) to break long commands.
> On Linux and macOS, you can use the line breaks.
>
> On Windows, use the backtick character (<code>&#96;</code>) to break long commands.
>
> Alternatively, do not break long commands.

```bash
[user@host ~]$ kubectl run webserver \
--image=registry.access.redhat.com/ubi8/httpd-24:1-161
pod/webserver created
```

1.2) Confirm the `webserver` pod is running.

```bash
[user@host ~]$ kubectl get pods
NAME        READY   STATUS    RESTARTS   AGE
webserver   1/1     Running   0          5s
```

1.3) Connect to the pod by using `kubectl exec`.

```bash
[user@host ~]$ kubectl exec --stdin --tty \
webserver -- /bin/bash
root@webserver:/#
```

1.4) View the contents of the `httpd` configuration file within the pod.

```bash
[root@webserver:/]# cat /etc/httpd/conf/httpd.conf
...output omitted...
ServerAdmin root@localhost
...output omitted...
```

1.5) Disconnect from the pod by using the `exit` command.

```bash
[root@webserver:/]# exit
```

2) Create a pod resource definition file and use that file to create another pod in your cluster.

2.1) Create a new file named `probes-pod.yml`.
Add the following resource manifest to the file.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probes
  labels:
    app: probes
  namespace: user-dev
spec:
  containers:
    - name: probes
      image: 'quay.io/redhattraining/do100-probes:latest'
      ports:
        - containerPort: 8080
```

Replace user by your OpenShift Developer Sandbox username.

You can generate the basic YAML file with the `kubectl run` command

```bash
[user@host ~]$ kubectl run probes --dry-run=client -o yaml \
    --image=quay.io/redhattraining/do100-probes:latest
```

2.2) Use the `kubectl create` command to create a new pod from the resource manifest file.

```bash
[user@host ~]$ kubectl create -f probes-pod.yml
pod/probes created
```

2.3) Verify that the pod is running.

```bash
[user@host ~]$ kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
probes        1/1     Running   0          15s
webserver     1/1     Running   0          10m
```

3) Modify the `metadata.labels.app` field of the pod manifest and apply the changes.

3.1) Open the `probes-pod.yaml` file.
Replace `probes` by `do100-probes` in the `metadata.labels.app` field.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probes
  labels:
    app: do100-probes...output omitted...
```

3.2) Attempt to update the pod by using the `kubectl create` command.

```bash
[user@host ~]$ kubectl create -f probes-pod.yml
Error from server (AlreadyExists): error when creating "probes-pod.yml": pods "probes" 
already exists
```

Notice the error.
Because you have previously created the pod, you can not use `kubectl create`.

3.3) Update the pod by using the `kubectl apply` command.

```bash
[user@host ~]$ kubectl apply -f probes-pod.yml
pod/probes configured
```
> **Note**
>
> The preceding usage of `kubectl` apply produces a warning that the `kubectl.kubernetes.io/last-applied-configuration` annotation is missing.
> In most scenarios, this can be safely ignored.
>
> Ideally, to use `kubectl apply` in this precise manner, you should use the `--save-config` option with `kubectl create`.

3.4) Verify that the label has been updated by using the `kubectl describe pod` command.

```bash
[user@host ~]$ kubectl describe pod probes
Name:                 probes
Namespace:            user-dev
...output omitted...
Labels:               app=do100-probes
...output omitted...
```

## Finish

Delete the pod and namespace to clean your cluster.

```bash
[user@host ~]$ kubectl delete pod/webserver
pod "webserver" deleted

[user@host ~]$ kubectl delete pod/probes
pod "probes" deleted
```

This concludes the guided exercise.
