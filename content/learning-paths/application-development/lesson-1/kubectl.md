+++
description = ""
+++

<!-- https://kubebyexample.com/en/learning-paths/application-development-kubernetes/lesson-1-running-containerized-applications -->

# Introducing `kubectl`

Objectives
After completing this section, you should be able to review the basic usage of the `kubectl` command and understand how to connect to your Kubernetes cluster by using the CLI.

## Introducing `kubectl`
The `kubectl` tool is a Kubernetes command-line tool that allows you to interact with your Kubernetes cluster.
It provides an easy way to perform tasks such as creating resources or redirecting cluster traffic.
The `kubectl` tool is available for the three main operating systems (Linux, Windows and macOS).

For example, the following command displays the `kubectl` and Kubernetes version.

```bash
[user@host ~]$ kubectl version
Client Version: version.Info{Major:"1", Minor:"21", GitVersion:"v1.21.0", GitCommit:"…", GitTreeState:"clean", BuildDate:"…", GoVersion:"…", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"21", GitVersion:"v1.21.0", GitCommit:"…", GitTreeState:"clean", BuildDate:"…", GoVersion:"…", Compiler:"gc", Platform:"linux/amd64"}
```

## Introducing `kubectl` configuration

`kubectl` reads all the information necessary to connect to the Kubernetes cluster from a config file within your system.
By default, this file is located at `$HOME/kube/config`.
You can change this path by setting the environment variable `KUBECONFIG` to a custom file.

For example, the following sample sets the `KUBECONFIG` to the file `/tmp/config`.

```bash
[user@host ~]$ export KUBECONFIG=/tmp/config
```

All the commands related to the `kubectl` configuration are of the form:

```bash
kubectl config option
```

If you want to see what the configuration file contains, then you can use the following command.

```bash
[user@host ~]$ kubectl config view
```

The `kubectl` configuration file comprehends three topics:

- **Cluster**: The URL for the API of a Kubernetes cluster. This URL identifies the cluster itself.

- **User**: Credentials that identify a user connecting to the Kubernetes cluster.

- **Context**: Puts together a cluster (the API URL) and a user (who is connecting to that cluster).

For example, you might have two contexts that are using different clusters but the same user.

## Defining Clusters

It is often necessary to work with multiple clusters, so `kubectl` can hold the information of several Kubernetes clusters.
In relation to the configuration for `kubectl`, a cluster is just the URL of the API of the Kubernetes cluster.
The `kubectl config set-cluster` command allows you to create a new cluster connection by using the API URL.

For example, the following command creates a new cluster connection named `my-cluster` with server `127.0.0.1:8087`.

```bash
[user@host ~]$ kubectl config set-cluster my-cluster --server=127.0.0.1:8087
```

Use the `get-clusters` command to list all available clusters.

```bash
[user@host ~]$ kubectl config get-clusters
my-cluster
my-cluster-2
```

## Defining Users

The cluster configuration tells `kubectl` where the Kubernetes cluster is.
The user configuration identifies who connects to the cluster.
To connect to the cluster, it is necessary to provide an authentication method.
There are several options to authenticate with the cluster:

- Using a token

The following command creates a new user named `my-user` with the token `Py93bt12mT`.

```bash
[user@host ~]$ kubectl config set-credentials my-user --token=Py93bt12mT
```

- Using basic authentication

The following command creates a new user named `my-user` with username `kubernetes-username` and password `kubernetes-password`.

```bash
[user@host ~]$ kubectl config set-credentials my-user \
    --username=kubernetes-username --password=kubernetes-password
```

- Using certificates

The following command creates a new user named `my-user` with a certificate `redhat-certificate.crt` and a key `redhat-key.key`.

```bash
[user@host ~]$ kubectl config set-credentials my-user \
    --client-certificate=redhat-certificate.crt --client-key=redhat-key.key
```

Use the `get-users` command to list all available users.

```bash
[user@host ~]$ kubectl config get-users
my-user
my-user-2
```

## Defining Contexts

A context puts together a cluster and a user.
`kubectl` uses both to connect and authenticate against a Kubernetes cluster.

For example, the following command creates a new context by using a cluster named `my-cluster` and a user named `my-user`.

```bash
[user@host ~]$ kubectl config set-context --cluster=my-cluster --user=my-user
```

In a `kubectl` context, it is possible to set a namespace.
If provided, then any command would be executed in that namespace.
The following command creates a context that points to the `redhat-dev` namespace.

```bash
[user@host ~]$ kubectl config set-context my-context \
    --cluster=my-cluster --user=my-user --namespace=redhat-dev
```

Once a context has been created, you can select it by using the `use-context` command.

```bash
[user@host ~]$ kubectl config use-context my-context
```

After executing the previous command, further `kubectl` commands will use the `my-cluster` context and, therefore, the cluster and user associated to that context.

You can also list the contexts available in the configuration by using the `get-contexts` command.
The `*` in the `CURRENT` column indicates the context that you are currently using.

```bash
[user@host ~]$ kubectl config get-contexts
CURRENT   NAME            CLUSTER           AUTHINFO      NAMESPACE
*         my-context      172.0.7.2:6443    my-user       redhat-dev
          my-context-2    172.1.8.0:6443    my-user-2
```

Another way of checking the current context is by using the `current-context` command.

```bash
[user@host ~]$ kubectl config current-context
my-context
```

## Working with resources

Once you are connected to a Kubernetes cluster, `kubectl` allows you to list, create, update and delete Kubernetes resources.
Most of these commands will be introduced in later chapters in the course, but there are some of them that can be mentioned at this point.

### The `get` command

This commands is used to display one or more resources.

For example, `kubectl get pods` will display all pods in the current namespace.

```bash
[user@host ~]$ kubectl get pods
NAME       READY   STATUS        RESTARTS   AGE
example1   1/1     Running       0          67s
example2   1/1     Running       0          67s
```

If you want to display just the information for one pod, then add the pod's name to the previous command.

```bash
[user@host ~]$ kubectl get pods example1
NAME       READY   STATUS        RESTARTS   AGE
example1   1/1     Running       0          67s
```

You can use this command to display other resources (`services`, `jobs`, `ingresses`…​).

> **Note**
> Use the command `kubectl` api-resources to display all resource types that you can create.

### The `delete` command

This command allows you to delete a resource.

For example, `kubectl delete pod example1` deletes the pod named `example1`.

```bash
[user@host ~]$ kubectl delete pod example1
pod "example1" deleted
```

You can use this command to delete other resources (`services`, `jobs`, `ingresses`…​).

### The `apply` command

A common way to manage Kubernetes resources is by using a _manifest_.
A manifest is a YML or JSON file containing one or many Kubernetes resources.

The `apply` command allows you to create, update or delete resources from a manifest.

For example, the following snippet creates a **deployment** resource.

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

If the snippet was in a file named `deployment.yaml`, then you could use `apply` to create the deployment.
Note that the `-f` option is used to indicate the file.

```bash
[user@host ~]$ kubectl apply -f deployment.yml
deployment.apps/nginx-deployment created
```

--------------------------------------------------------------------------------
