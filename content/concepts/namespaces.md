+++
description = ""
+++

<!-- https://kubebyexample.com/en/concept/namespaces -->

# Namespaces

Namespaces provide a scope for Kubernetes resources, carving up your cluster in smaller units.

You can think of it as a workspace you're sharing with other users.
Many resources such as pods and services are namespaced.
Others, such as nodes, are not namespaced, but are instead treated as cluster-wide.

As a developer, you'll usually use an assigned namespace, however admins may wish to manage them, for example to set up access control or resource quotas.

Like other resources, the `get` subcommand displays a list of all namespaces a user has access to in a cluster (both the full resource type name `namespace` and the abbreviation `ns` can be used):

```bash
$ kubectl get ns
```

On a simple `minikube` installation, the result shows:

```text
NAME              STATUS   AGE
default           Active   17h
kube-node-lease   Active   17h
kube-public       Active   17h
kube-system       Active   17h
```

You can learn more about a namespace using the `describe` verb:

```bash
$ kubectl describe ns default
```

If no changes were made to the minikube cluster, the output should look like the following:

```text
Name:         default
Labels:       <none>
Annotations:  <none>
Status:       Active

No resource quota.

No LimitRange resource.
```

Let's now create a new [namespace][namespace] called `test`:

```bash
$ kubectl apply -f https://github.com/openshift-evangelists/kbe/raw/main/specs/ns/ns.yaml
```

Once the namespace is created, it will appear in the list of available namespaces:

```bash
$ kubectl get ns
```

Alternatively, we could have created the namespace using the `kubectl create namespace test` command.
 
To launch a [pod][pod] in the newly created namespace test, run:

```bash
$ kubectl apply --namespace=test -f https://github.com/openshift-evangelists/kbe/raw/main/specs/ns/pod.yaml
```

Note that using above method the namespace becomes a runtime property.
In other words, you can deploy the same pod or service into multiple namespaces (for example, dev and prod).
Hard-coding the namespace directly in the `metadata` section as shown in the following is possible, but causes less flexibility when deploying your apps:

```yaml
apiVersion: v1
kind: Pod
metadata:
name: podintest
namespace: test
```

To list namespaced objects, such as our pod `podintest`, pass the `--namespace` variable to the get call:

```bash
$ kubectl get pods --namespace=test
```

You can remove the namespace (and everything inside of it) with:

```bash
$ kubectl delete ns test
```

If you're an admin, you might want to check out the [docs][docs] for more info how to handle namespaces.

--------------------------------------------------------------------------------

[namespace]: https://github.com/openshift-evangelists/kbe/raw/main/specs/ns/ns.yaml
[pod]: https://github.com/openshift-evangelists/kbe/raw/main/specs/ns/pod.yaml
[docs]: https://kubernetes.io/docs/tasks/administer-cluster/namespaces/
