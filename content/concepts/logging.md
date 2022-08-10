+++
description = ""
+++

<!-- https://kubebyexample.com/en/concept/logging -->

# Logging

Logging is one option to understand what is going on inside your applications and the cluster at large.
Basic logging in Kubernetes makes the output a container produces available through the kubectl tool.
More advanced [setups] consider logs across nodes and store them in a central place, either within the cluster or via a dedicated (cloud-based) service.

Let's create a [pod][pod] called `logme` that runs a container writing to `stdout` and `stderr`:

```bash
$ kubectl apply -f https://github.com/openshift-evangelists/kbe/raw/main/specs/logging/pod.yaml
```

To view the five most recent log lines of the `gen` container in the `logme` pod, execute:

```bash
$ kubectl logs --tail=5 logme -c gen
```

Streaming functionality, similar to running `tail -f`, is available as well:

```bash
$ kubectl logs -f --since=10s logme -c gen
```

Note that if you didn't specify `--since=10s` in the above command, you would have gotten all of the log lines from the start of the container.
 

You can also view logs of pods that have already completed their lifecycle.
To demonstrate this, create a [pod called `oneshot`][oneshot] that counts down from 9 to 1 and then exits:

```bash
$ kubectl apply -f https://github.com/openshift-evangelists/kbe/raw/main/specs/logging/oneshotpod.yaml
```

By using the `-p` option, you can print the logs for previous instances of the container in a pod:

```bash
$ kubectl logs -p oneshot -c gen
```

You can remove the created pods with:

```bash
$ kubectl delete pod/logme pod/oneshot
```

--------------------------------------------------------------------------------

[setups]: https://kubernetes.io/docs/concepts/cluster-administration/logging/
[pod]: https://github.com/openshift-evangelists/kbe/raw/main/specs/logging/pod.yaml
[oneshot]: https://github.com/openshift-evangelists/kbe/raw/main/specs/logging/oneshotpod.yaml
