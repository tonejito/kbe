+++
description = ""
+++

<!-- https://kubebyexample.com/en/concept/secrets -->

# Secrets

You don't want sensitive information such as a database password or an API key stored in clear text.
Secrets provide you with a mechanism to store such information in a safe and reliable way with the following properties:

- Secrets are namespaced objects, that is, exist in the context of a specific namespace
- You can access them via a volume or an environment variable from a container running in a pod
- The secret data on nodes is stored in [`tmpfs`][tmpfs] volumes
- A per-secret size limit of 1MB exists
- The API server stores secrets as plaintext in etcd

Let's create a secret named apikey that holds an example API key.
The first step is to create a file that contains the secret data:

```bash
$ echo -n "A19fh68B001j" > ./apikey.txt
```

That file is passed to the command that creates the secret:

```bash
$ kubectl create secret generic apikey --from-file=./apikey.txt
```

Information about the secret is retrieved using the `describe` subcommand:

```bash
$ kubectl describe secrets/apikey
```

The value of the secret isn't displayed by default, but other metadata is shown:

```text
Name: apikey
Namespace: default
Labels: <none>
Annotations: <none>

Type: Opaque

Data
====
apikey.txt: 12 bytes
```

Now let's use the secret in a [pod] through a volume:

```bash
$ kubectl apply -f https://github.com/openshift-evangelists/kbe/raw/main/specs/secrets/pod.yaml
```

Connect to the container to verify the attached secret:

```bash
$ kubectl exec -it consumesec -c shell -- bash
```

The secret is mounted at `/tmp/apikey`:

```bash
$ mount | grep apikey
```

The value of the key is stored in a file with the same name as the original file the secret was created from:

```bash
$ cat /tmp/apikey/apikey.txt
```

Disconnect from the running container by running `exit`.
 
Note that for service accounts, Kubernetes automatically creates secrets containing credentials for accessing the API and modifies your pods to use this type of secret.
 
You can remove both the pod and the secret with:

```bash
$ kubectl delete pod/consumesec secret/apikey
```

--------------------------------------------------------------------------------

[tmpfs]: https://www.kernel.org/doc/Documentation/filesystems/tmpfs.txt
[pod]: https://github.com/openshift-evangelists/kbe/raw/main/specs/secrets/pod.yaml
