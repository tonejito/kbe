+++
description = ""
+++

<!-- https://kubebyexample.com/en/concept/labels -->

# Labels

Labels are the mechanism used to organize Kubernetes objects.
A label is a key-value pair with certain [restrictions][restrictions] concerning length and allowed values but without any pre-defined meaning.
You're free to choose labels as you see fit, for example, to express environments such as "this pod is running in production" or ownership, like "department X owns that pod".

aaa bbb ccc

Let's create a [pod][pod] that initially has one label (`env=development`):

```
$ kubectl apply -f https://raw.githubusercontent.com/openshift-evangelists/kbe/main/specs/labels/pod.yaml
```

The `get` subcommand can be used to display a pod's labels:

```
$ kubectl get pods --show-labels
```

The labels are rendered as an additional column in the output:

```
NAME      READY   STATUS    RESTARTS   AGE   LABELS
labelex   1/1     Running   0          6s    env=development
```

You can add a label to the pod through the `label` subcommand:

```
$ kubectl label pods labelex owner=michael
```

Running the `get` subcommand from above shows the new label in addition to the existing one:

```
NAME      READY   STATUS    RESTARTS   AGE   LABELS
labelex   1/1     Running   0          65s   env=development,owner=michael
```

To use a label for filtering, for example to list only pods that have an `owner` that equals `michael`, use the `--selector` option:

```
$ kubectl get pods --selector owner=michael
```

The `--selector` option can be abbreviated to `-l`, so selecting pods that are labelled with `env=development` can also be done using:

```
$ kubectl get pods -l env=development
```

Oftentimes, Kubernetes objects support set-based selectors.
Let's launch [another pod][another-pod] that has two labels (`env=production` and `owner=michael`):

```
$ kubectl apply -f https://raw.githubusercontent.com/openshift-evangelists/kbe/main/specs/labels/anotherpod.yaml
```

Now, let's list all pods that are either labelled with `env=development` or with `env=production`:

```
$ kubectl get pods -l 'env in (production, development)'
```

Since we have each pod has one of those two labels, they both appear in the output:

```
NAME           READY   STATUS    RESTARTS   AGE
labelex        1/1     Running   0          6m39s
labelexother   1/1     Running   0          46s
```

Other verbs also support label selection.
For example, you could remove both of these pods with the same selector:

```
$ kubectl delete pods -l 'env in (production, development)'
```

Beware that this will destroy any pods with those labels.

You can also delete them directly, via their names, with:

```
$ kubectl delete pods labelex
$ kubectl delete pods labelexother
```

Note that labels are not restricted to pods.
In fact you can apply them to all sorts of objects, such as nodes or services.

--------------------------------------------------------------------------------

[restrictions]: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#syntax-and-character-set
[pod]: https://github.com/openshift-evangelists/kbe/blob/main/specs/labels/pod.yaml
[another-pod]: https://github.com/openshift-evangelists/kbe/blob/main/specs/labels/anotherpod.yaml
