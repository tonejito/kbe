+++
description = ""
+++

<!-- https://kubebyexample.com/en/concept/volumes -->

# Volumes

A Kubernetes _volume_ is essentially a directory accessible to all containers running in a pod.
In contrast to the container-local filesystem, the data in volumes is preserved across container restarts.
The medium backing a volume and its contents are determined by the volume type:

- node-local types such as `emptyDir` or `hostPath`
- file-sharing types such as `nfs`
- cloud provider-specific types like `awsElasticBlockStore`, `azureDisk`, or `gcePersistentDisk`
- distributed file system types, for example `glusterfs` or `cephfs`
- special-purpose types like `secret`, `gitRepo`

A special type of volume is `PersistentVolume`, which is covered in its own lesson.

Let's create a [pod][pod] with two containers that use an `emptyDir` volume to exchange data:

```bash
$ kubectl apply -f https://github.com/openshift-evangelists/kbe/blob/main/specs/volumes/pod.yaml
```

Volume information is displayed in the detailed output:

```bash
$ kubectl describe pod sharevol
```

The output below is truncated to show the relevant volume information:

```text
Name:         sharevol
Namespace:    default
Priority:     0
Node:         minikube/192.168.39.51
...
Containers:
  c1:
    Container ID:  docker://0cfe351e5a3131d3e02ca92a4aad8ea196cde403dcbc4713329bb418e1cce144
    ...
    Mounts:
      /tmp/xchange from xchange (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-sckql (ro)
  c2:
    Container ID:  docker://93eadd487c18f5fc77885b8c343dff6891c2fdbae9752160a7d5a08c2763ba9c
    ...
    Mounts:
      /tmp/data from xchange (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-sckql (ro)
...
Volumes:
  xchange:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
...
```

We first connect to one of the containers in the pod, `c1`, to view the volume mount and generate some data:

```bash
$ kubectl exec -it sharevol -c c1 -- bash
```

The volume is mounted like any other Linux volume mount:

```bash
$ mount | grep xchange
```

Create a file in the mount that we'll be able to access from the other container in the pod:

```bash
$ echo 'some data' > /tmp/xchange/data
```

When you're finished, disconnect from the container:

```bash
$ exit
```

When we now connect to the container `c2`, the second container running in the pod, we can see the volume mounted at `/tmp/data` (as compared to `c1` where it is mounted to `/tmp/xchange`) and are able to read the data created in the previous step:

```bash
$ kubectl exec -it sharevol -c c2 -- bash``

$ cat /tmp/data/data
```

Once again, exit from the connected container by running `exit`.

Note that in each container you need to decide where to mount the volume, and that for `emptyDir` you currently can not specify resource consumption limits.

You can remove the pod with:

```bash
$ kubectl delete pod/sharevol
```

As already described, this will destroy the shared volume and all its contents.

--------------------------------------------------------------------------------

[pod]: https://github.com/openshift-evangelists/kbe/blob/main/specs/volumes/pod.yaml
