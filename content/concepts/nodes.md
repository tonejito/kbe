+++
description = ""
+++

<!-- https://kubebyexample.com/en/concept/nodes -->

# Nodes

In Kubernetes, nodes are the (potentially virtual) machines where your workloads run. As a developer, you typically don't deal with nodes directly, however as an admin
you might want to familiarize yourself with node [operations][operations].
 
Node information is captured in a resource type named `node`:

```bash
$ kubectl get nodes
```

The output will vary depending on your cluster. The example below is taken from a minikube cluster:

```text
NAME       STATUS   ROLES                  AGE   VERSION
minikube   Ready    control-plane,master   42m   v1.20.2
```

One uncommon, but still important, requirement is to make Kubernetes schedule a pod on a certain node. For this, we first need to label the node we want to target (using the node name as retrieved above):

```bash
$ kubectl label nodes minikube shouldrun=here
```

Now we can create a [pod][pod] that is scheduled on the node with the label `shouldrun=here`:

```bash
$ kubectl apply -f https://github.com/openshift-evangelists/kbe/raw/main/specs/nodes/pod.yaml
```

The `-o wide` flag, when retrieving pod information, will show the node on which the pod is running:

```bash
$ kubectl get pods --output=wide
```

In this case, the node is the same one that was labeled in the `label` command above.  

The `describe` subcommand contains a wealth of information about the node (the example output below has been truncated for readability):

```text
Name:               minikube
Roles:              control-plane,master
...
Addresses:
  InternalIP:  192.168.39.147
  Hostname:    minikube
Capacity:
  cpu:                4
  ephemeral-storage:  17784752Ki
  hugepages-2Mi:      0
  memory:             11999700Ki
  pods:               110
...
Events:
  Type    Reason                   Age                From        Message
  ----    ------                   ----               ----        -------
  Normal  NodeHasSufficientMemory  47m (x7 over 47m)  kubelet     Node minikube status is now: NodeHasSufficientMemory
  Normal  NodeHasNoDiskPressure    47m (x6 over 47m)  kubelet     Node minikube status is now: NodeHasNoDiskPressure
  Normal  NodeHasSufficientPID     47m (x6 over 47m)  kubelet     Node minikube status is now: NodeHasSufficientPID
  Normal  Starting                 47m                kubelet     Starting kubelet.
...
```

Note that there are more sophisticated methods than shown above, such as using affinity, to [assign pods to nodes][assign-pods-to-nodes].

--------------------------------------------------------------------------------

[operations]: https://kubernetes.io/docs/concepts/nodes/node/
[pod]: https://github.com/openshift-evangelists/kbe/raw/main/specs/nodes/pod.yaml
[assign-pods-to-nodes]: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
