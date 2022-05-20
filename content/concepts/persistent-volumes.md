+++
description = "Persistent Volumes provide storage for Kubernetes pods"
+++

<!-- https://kubebyexample.com/en/concept/persistent-volumes -->

# Persistent Volume

A [persistent volume][persistent-volume] (PV) is a cluster-wide resource that you can use to store data in a way that it persists beyond the lifetime of a pod.
The PV is not backed by locally-attached storage on a worker node but by networked storage system such as EBS or NFS or a distributed filesystem like Ceph.

Depending on your cluster and storage type, the configuration of a PV will vary slightly.
The command below will work for `minikube` clusters, where it will create the volume as a mount on the VM.

```text
$ kubectl apply -f https://github.com/openshift-evangelists/kbe/raw/main/specs/pv/pv.yaml
```

View the status of the persistent volume that was just created.

```bash
$ kubectl get pv
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM             STORAGECLASS   REASON   AGE
pv0001   5Gi        RWO            Recycle          Available   default/myclaim                           30s
```

Review the details of the persistent volume.

```bash
$ kubectl describe pv pv0001
Name:            pv0001
Labels:          volume=pv0001
Annotations:     pv.kubernetes.io/bound-by-controller: yes
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:
Status:          Available  # <= The persistent volume is not bound to a PVC
Claim:           default/myclaim
Reclaim Policy:  Recycle
Access Modes:    RWO
VolumeMode:      Filesystem
Capacity:        5Gi
Node Affinity:   <none>
Message:
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /mnt/pv-data/pv0001
    HostPathType:
Events:            <none>
```

In order to use a PV, you need to claim it first, using a persistent volume claim (PVC).
The PVC requests a PV with your desired specification (size, speed, etc.), and it's mounted as a volume inside the pod.
Let's create a PVC that uses the default [storage class][storage-class].

```bash
$ kubectl apply -f https://github.com/openshift-evangelists/kbe/raw/main/specs/pv/pvc.yaml
```

The persistent volume status is set to `Bound` when a persistent volume claim is using it.

```bash
$ kubectl get pv
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM             STORAGECLASS   REASON   AGE
pv0001   5Gi        RWO            Recycle          Bound    default/myclaim                           120s
```

Persistent Volume Claims can be queried using the abbreviation `pvc`.
The output reflects the name of the created PVC and some basic information.

```bash
$ kubectl get pv
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM             STORAGECLASS   REASON   AGE
pv0001   5Gi        RWO            Recycle          Bound    default/myclaim                           120s

$ kubectl get pvc
NAME      STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
myclaim   Bound    pv0001   5Gi        RWO            standard       30s
```

Review the details of the persistent volume claim that was just created.

```bash
$ kubectl describe pvc myclaim
Name:          myclaim
Namespace:     default
StorageClass:  standard
Status:        Bound  # <= The persistent volume claim is bound to a PV
Volume:        pv0001  # <= The PV that provides the persistent storage for this PVC
Labels:        <none>
Annotations:   pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      5Gi
Access Modes:  RWO
VolumeMode:    Filesystem
Used By:       <none>  # <= The PVC is currently not being used by a pod
Events:        <none>
```

To understand how the persistence works, let's create a deployment that uses above PVC and mounts it as a volume into the `/tmp/persistent` directory.

```bash
$ kubectl apply -f https://github.com/openshift-evangelists/kbe/raw/main/specs/pv/deploy.yaml
```

View the status of the deployment and the pod.
The `-L` option displays a column with the value associated with the `app` label.

```bash
$ kubectl get deployments,pods -L app
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE   APP
deployment.apps/pv-deploy   1/1     1            1           31s

NAME                             READY   STATUS    RESTARTS   AGE   APP
pod/pv-deploy-7d5f79cb7f-j28rd   1/1     Running   0          30s   mypv
```

Inspect the persistent volume claim resource.
The `Used By` field now displays the name of the pod that has the persistent volume mounted.

```bash
$ kubectl describe pvc myclaim
Name:          myclaim
Namespace:     default
StorageClass:  standard
Status:        Bound  # <= The persistent volume claim is bound to a PV
Volume:        pv0001  # <= The PV that provides the persistent storage for this PVC
Labels:        <none>
Annotations:   pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      5Gi
Access Modes:  RWO
VolumeMode:    Filesystem
Used By:       pv-deploy-7d5f79cb7f-j28rd  # <= The PVC is now being used by a pod
Events:        <none>
```

Verify that the pod template in the deployment mounts the volume requested in the PVC.

```bash
$ kubectl describe deployment pv-deploy | egrep -A2 '(Volumes|Mounts):'
    Mounts:
      /tmp/persistent from mypd (rw)
  Volumes:
   mypd:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
```

<!--
```bash
$ kubectl get deployment pv-deploy -o jsonpath='{.spec.template.spec.volumes[0]}{"\n"}'
{"name":"mypd","persistentVolumeClaim":{"claimName":"myclaim"}}

$ kubectl get deployment pv-deploy -o jsonpath='{.spec.template.spec.containers[0].volumeMounts}{"\n"}'
[{"mountPath":"/tmp/persistent","name":"mypd"}]
```
-->

Get the name of the pod and export it to an environment variable.

```bash
$ kubectl get pods -l app=mypv -o name
pod/pv-deploy-7d5f79cb7f-j28rd

$ export POD_NAME="pv-deploy-7d5f79cb7f-j28rd"
```

Verify that the persistent volume is mounted in the pod.

```bash
$ kubectl exec -it ${POD_NAME} -- df -m /tmp/persistent
Filesystem     1M-blocks  Used Available Use% Mounted on
tmpfs               5232   623      4609  12% /tmp/persistent
```

Now we want to test if data in the volume actually persists.

```bash
$ kubectl exec -it ${POD_NAME} -- /bin/bash
```

Connect to the pod, then create a new file in the mounted persistent volume.
Once you've verified the file was created, disconnect from the pod using the `exit` command.

```bash
$ kubectl exec -it ${POD_NAME} -- /bin/bash

[root@pod /]# echo "Kube by Example" > /tmp/persistent/test

[root@pod /]# cat /tmp/persistent/test
Kube by Example

[root@pod /]# exit

$ 
```

It's time to destroy the pod and let the deployment launch a new pod.
The expectation is that the PV will be reconnected to the new pod and the data in `/tmp/persistent` is still present.

```bash
$ kubectl delete pod ${POD_NAME}
```

Since Kubernetes will ensure that the desired number of pods in a deployment are present, it will start a new pod with the same spec as the original.
When viewing the list of pods, you will likely see two: the previous pod (which should be in the `Terminating` state) and the new pod being started.
For example (your pod names will vary slightly).

```bash
$ kubectl get pods
NAME                         READY   STATUS        RESTARTS   AGE
pv-deploy-7d5f79cb7f-j28rd   1/1     Terminating   0          120s
pv-deploy-7d5f79cb7f-cxcgx   1/1     Running       0          10s
```

Get the name of the new pod (the one in the `Running` state) and export it to an environment variable.

```bash
$ kubectl get pods -l app=mypv -o name
pod/pv-deploy-7d5f79cb7f-cxcgx

$ export POD_NAME="pv-deploy-7d5f79cb7f-cxcgx"
```

Connect to the newly created pod as you did previously and display the contents of the file that was created from the original pod.
The text `Kube by Example` should appear, showing that the original persistent volume was mounted to the newly created pod.

```bash
$ kubectl exec ${POD_NAME} -it -- cat /tmp/persistent/test
Kube by Example
```

Note that the default behavior is that even when the deployment is deleted, the PVC and the PV continue to exist.
This storage protection feature helps avoid data loss.

```bash
$ kubectl delete deployment pv-deploy
deployment.apps "pv-deploy" deleted
```

After the deployment and pod are deleted the PVC status displays that is not being used by any pod.

```bash
$ kubectl describe pvc myclaim | grep 'Used By'
Used By:       <none>  # <= The PVC is currently not being used by a pod
```

Create the same deployment again using the resource manifest.

```bash
$ kubectl apply -f https://github.com/openshift-evangelists/kbe/raw/main/specs/pv/deploy.yaml
deployment.apps/pv-deploy created
```

Wait until the deployment and pod are ready again.

```bash
$ kubectl get deployments,pods
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/pv-deploy   1/1     1            1           6s

NAME                             READY   STATUS    RESTARTS   AGE
pod/pv-deploy-7d5f79cb7f-l4bmw   1/1     Running   0          5s
```

View the status of the PVC, it displays that is being used by the pod we just created.

```bash
$ kubectl describe pvc myclaim | grep 'Used By'
Used By:       pv-deploy-7d5f79cb7f-l4bmw  # <= The PVC is now being used by a pod
```

Connect to the deployment and view the contents of the file stored in the persistent volume.

```bash
$ kubectl exec -it deployment/pv-deploy -- cat /tmp/persistent/test
Kube by Example
```

Once you're sure you don't need the data anymore, you can go ahead and delete the PVC (for the purposes of this lesson, we'll delete the PV as well).
To clean up before the next lesson, we'll also delete the deployment and remove the environment variable that stores the name of the pod.

```bash
$ kubectl delete deployment pv-deploy
deployment.apps "pv-deploy" deleted

$ kubectl delete pvc myclaim
persistentvolumeclaim "myclaim" deleted

$ kubectl delete pv pv0001
persistentvolume "pv0001" deleted

$ unset POD_NAME
```

The types of persistent volume available to your Kubernetes cluster depend on the environment (on-prem or public cloud).
The [Stateful Kubernetes][stateful-kubernetes] site has more information on the types of volumes available.

--------------------------------------------------------------------------------

[persistent-volume]: https://kubernetes.io/docs/concepts/storage/persistent-volumes/
[storage-class]: https://kubernetes.io/docs/concepts/storage/storage-classes/
[stateful-kubernetes]: https://stateful.kubernetes.sh/#storage
