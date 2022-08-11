+++
description = ""
+++

<!-- https://kubebyexample.com/en/concept/persistent-volumes -->

# Persistent Volumes

A [persistent volume][persistent-volume] (PV) is a cluster-wide resource that you can use to store data in a way that it persists beyond the lifetime of a pod.
The PV is not backed by locally-attached storage on a worker node but by networked storage system such as EBS or NFS or a distributed filesystem like Ceph.

Depending on your cluster and storage type, the configuration of a PV will vary slightly.
The command below will work for minikube clusters, where it will create the volume as a mount on the `minikube` VM:

```bash
$ kubectl apply -f https://github.com/openshift-evangelists/kbe/raw/main/specs/pv/pv.yaml
```

In order to use a PV, you need to claim it first, using a persistent volume claim (PVC).
The PVC requests a PV with your desired specification (size, speed, etc.) from Kubernetes and binds it to a pod where you it is mounted as a volume.
Let's create a PVC, asking Kubernetes for 1 GB of storage using the default [storage class][storage-class]:

```bash
$ kubectl apply -f https://github.com/openshift-evangelists/kbe/raw/main/specs/pv/pvc.yaml
```

Persistent Volume Claims can be queried using the abbreviation `pvc`:

```bash
$ kubectl get pvc
```

The output reflects the name of the created PVC and some basic information:

```text
NAME      STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
myclaim   Bound    pv0001   5Gi        RWO            standard       10s
```

To understand how the persistence works, let's create a deployment that uses above PVC and mounts it as a volume into `/tmp/persistent`:

```bash
$ kubectl apply -f https://raw.githubusercontent.com/openshift-evangelists/kbe/main/specs/pv/deploy.yaml
```

Now we want to test if data in the volume actually persists.
Start by finding the pod managed by above deployment using `kubectl get pods` (it will begin with `pv-deploy-`) and then connecting into it.

**Note**: You'll need to replace `${POD_NAME}` with the generated name of one of your pods.

```bash
$ kubectl exec ${POD_NAME} -it -- /bin/bash
```

Once in the pod, create a new file in the mounted persistent volume:

```bash
$ echo "Hello World" > /tmp/persistent/test
```

Once you've verified the file was created, disconnect from the pod using `exit`.

It's time to destroy the pod and let the deployment launch a new pod.
The expectation is that the PV will be reconnected to the new pod and the data in `/tmp/persistent` is still present:

```bash
$ kubectl delete pod ${POD_NAME}
```

Since Kubernetes will ensure that the desired number of pods in a deployment are present, it will start a new pod with the same spec as the original.
When viewing the list of pods, you will likely see two: the previous pod (which should be in the `Terminating` state) and the new pod being started.
For example (your pod names will vary slightly):

```text
NAME                         READY   STATUS        RESTARTS   AGE
pv-deploy-7d5f79cb7f-d4jb6   1/1     Terminating   0          4m32s
pv-deploy-7d5f79cb7f-fnscf   1/1     Running       0          19s
```

Connect to the newly created pod (the one in the `Running` state) as you did previously:

```bash
$ kubectl exec ${POD_NAME} -it -- /bin/bash
```

Display the contents of the file that was created from the original pod:

```bash
$ cat /tmp/persistent/test 
```

The text `Hello World` should appear, showing that the original persistent volume was mounted to the newly created pod.

Note that the default behavior is that even when the deployment is deleted, the PVC and the PV continue to exist.
This storage protection feature helps avoid data loss.
Once you're sure you don't need the data anymore, you can go ahead and delete the PVC (for the purposes of this lesson, we'll delete the PV as well).
To clean up before the next lesson, we'll also delete the deployment:

```bash
$ kubectl delete deployment pv-deploy
$ kubectl delete pvc myclaim
$ kubectl delete pv pv0001
```

The types of persistent volume available to your Kubernetes cluster depend on the environment (on-prem or public cloud).
The [Stateful Kubernetes][stateful-kubernetes] site has more information on the types of volumes available.

--------------------------------------------------------------------------------

[persistent-volume]: https://kubernetes.io/docs/concepts/storage/persistent-volumes/
[storage-class]: https://kubernetes.io/docs/concepts/storage/storage-classes/
[stateful-kubernetes]: https://stateful.kubernetes.sh/#storage
