+++
description = ""
+++

# Running and Interacting with Your First Application

## Objectives

After completing this section, you should be able to execute a pre-built application in your Kubernetes cluster and review the resources related to the process.

## Running Pods From Container Images

The simplest way to run a container in your Kubernetes cluster is with the `kubectl` run command.
At a minimum, you must specify a name and container image.
This container image must be accessible by the Kubernetes cluster.

The following example command creates a new pod named `myname` that uses the container image referenced by `myimage`.

```bash
[user@host ~] kubectl run myname --image=myimage
```

Recent versions of `kubectl run` can only create new pods.
For example, older example uses of this command might include a `--replicas` option, which has been removed.

> **Important**
>
> Use `kubectl` run to create pods for quick tests and experimentation.
>
>For other situations, create a Deployment, as explained in [Deploying Manged Applications](../../lesson-2).

## Creating Resources

The `kubectl create` command creates new resources within the Kubernetes cluster.
You must specify the name and type of the resource, along with any information required for that resource type.

You can specify the `--dry-run=client` option to prevent the creation of the object within the cluster.
By combining this with the output type option, you can generate resource definitions.

For example, the following command outputs the YAML definition of a new deployment resource named `webserver`, by using the `nginx` image.

```bash
[user@host ~] kubectl create deployment webserver \
--image=nginx --dry-run=client -o yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: webserver
  name: webserver
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webserver
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: webserver
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}
```

You can save this output to a file to actually create the object later.
Reference the file by specifying it with the `-f` option.

For example, the following command creates a new resource using the definition found in `mydef.yaml`:

```bash
[user@host ~] kubectl create -f mydef.yaml
...output omitted...
```

## Comparing `create` and `apply`

The `kubectl create` command can only create _new_ resources.
To modify an existing resource or create it if it does not exist, use the `kubectl apply` command.
Like `kubectl create`, this command also accepts YAML or JSON definitions.

If you are familiar with certain variants of SQL syntax, then `kubectl` create is comparable to `INSERT` whereas `kubectl` apply is akin to `UPSERT`.

## Executing Commands Within an Existing Pod

With the `kubectl exec` command, you can execute commands inside _existing_ pods.
The `kubectl exec` command is useful for troubleshooting problematic containers, but the changes are not persistent.
To make persistent changes, you must change the container image.

At a minimum, this command requires the name of the pod and the command to execute.
For example, the following command will execute ls within the running pod named `mypod`.

```bash
[user@host ~] kubectl exec mypod -- /bin/ls
bin
boot
dev
...output omitted...
```

The `--` option separates the parts of the command intended for Kubernetes itself from the command that should be passed to and executed within the container.

## Connecting a Shell to an Existing Pod

A common use of `kubectl exec` is to open a new shell within a running pod.
For example, the following command creates and attaches a new shell session to the pod named `mypod`:

```bash
[user@host ~] kubectl exec --stdin --tty mypod -- /bin/bash
```

Notice the addition of the `--stdin` and `--tty` options.
These are necessary to ensure input and output are forwarded correctly to the interactive shell within the container.

--------------------------------------------------------------------------------

## References

- [The `kubectl` Command line tool](https://kubernetes.io/docs/reference/kubectl/)
- [`kubectl` command reference](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
