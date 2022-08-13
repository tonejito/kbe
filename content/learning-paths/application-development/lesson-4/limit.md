+++
description = ""
+++

<!-- https://kubebyexample.com/en/learning-paths/application-development-kubernetes/lesson-4-customize-deployments-application-0 -->

# Limiting Resource Usage

## Objectives

After completing this section, you should be able to leverage how to avoid applications overusing system resources.

## Defining Resource Requests and Limits for Pods

A pod definition can include both resource requests and resource limits:

**Resource requests**
: Used for scheduling and indicating that a pod cannot run with less than the specified amount of compute resources. The scheduler tries to find a node with sufficient compute resources to satisfy the requests.

**Resource limits**
: Used to prevent a pod from using up all compute resources from a node. The node that runs a pod configures the Linux kernel cgroups feature to enforce the pod's resource limits.

You should define resource requests and resource limits for each container in a deployment. If not, then the deployment definition will include a resources: {} line for each container.

Modify the resources: {} line to specify the desired requests and or limits. For example:

```yaml
...output omitted...
    spec:
      containers:
      - image: quay.io/redhattraining/hello-world-nginx:v1.0
        name: hello-world-nginx
        resources:requests:cpu: "10m"memory: 20Milimits:cpu: "80m"memory: 100Mi
status: {}
```

> **Note**:
>
> If you use the kubectl edit command to modify a deployment, then ensure you use the correct indentation.
> Indentation mistakes can result in the editor refusing to save changes.
> To avoid indentation issues, you can use the kubectl set resources command to specify resource requests and limits.

The following command sets the same requests and limits as the preceding example:

```bash
[user@host ~]$ kubectl set resources deployment hello-world-nginx \
--requests cpu=10m,memory=20Mi --limits cpu=80m,memory=100Mi
```

If a resource quota applies to a resource request, then the pod should define a resource request. If a resource quota applies to a resource limit, then the pod should also define a resource limit. Even without quotas, you should define resource requests and limits.

## Viewing Requests, Limits, and Actual Usage

Using the Kubernetes command-line interface, cluster administrators can view compute usage information for individual nodes. The kubectl describe node command displays detailed information about a node, including information about the pods running on the node. For each pod, it shows CPU and memory requests, as well as limits for each. If a request or limit is not specified, then the pod shows a 0 for that column. A summary of all resource requests and limits is also displayed.

```bash
[user@host ~]$ kubectl describe node node1.us-west-1.compute.internal
Name:               node1.us-west-1.compute.internal
Roles:              worker
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=m4.xlarge
                    beta.kubernetes.io/os=linux
...output omitted...
Non-terminated Pods:                      (20 in total)
...  Name                CPU Requests  ...  Memory Requests  Memory Limits  AGE
...  ----                ------------  ...  ---------------  -------------  ---
...  tuned-vdwt4         10m (0%)      ...  50Mi (0%)        0 (0%)         8d
...  dns-default-2rpwf   110m (3%)     ...  70Mi (0%)        512Mi (3%)     8d
...  node-ca-6xwmn       10m (0%)      ...  10Mi (0%)        0 (0%)         8d
...output omitted...
  Resource                    Requests     Limits
  --------                    --------     ------
  cpu                         600m (17%)   0 (0%)
  memory                      1506Mi (9%)  512Mi (3%)
...output omitted...
```

> **Note**:
>
> The summary columns for Requests and Limits display the sum totals of defined requests and limits.
> In the preceding output, only one of the 20 pods running on the node defined a memory limit, and that limit was 512Mi.

The kubectl describe node command displays requests and limits, and the kubectl top command shows actual usage. For example, if a pod requests 10m of CPU, then the scheduler will ensure that it places the pod on a node with available capacity. Although the pod requested 10m of CPU, it might use more or less than this value, unless it is also constrained by a CPU limit. The kubectl top nodes command shows actual usage for one or more nodes in the cluster, and the kubectl top pods command shows actual usage for each pod in a namespace.

```bash
[user@host ~]$ kubectl top nodes -l node-role.kubernetes.io/worker
NAME                               CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
node1.us-west-1.compute.internal   519m         14%    3126Mi          20%
node2.us-west-1.compute.internal   167m         4%     1178Mi          7%
```

## Applying Quotas

Kubernetes can enforce quotas that track and limit the use of two kinds of resources:

**Object counts**
: The number of Kubernetes resources, such as pods, services, and routes.

**Compute resources**
: The number of physical or virtual hardware resources, such as CPU, memory, and storage capacity.

Imposing a quota on the number of Kubernetes resources avoids exhausting other limited software resources, such as IP addresses for services.

Similarly, imposing a quota on the amount of compute resources avoids exhausting the capacity of a single node in a Kubernetes cluster. It also prevents one application from starving other applications of resources.

Kubernetes manages resource quotas by using a ResourceQuota or quota resource. A quota specifies hard resource usage limits for a namespace. All attributes of a quota are optional, meaning that any resource that is not restricted by a quota can be consumed without bounds.

> **Note**:
> Although a single quota resource can define all of the quotas for a namespace, a namespace can also contain multiple quotas.
> For example, one quota resource might limit compute resources, such as total CPU allowed or total memory allowed.
> Another quota resource might limit object counts, such as the number of pods allowed or the number of services allowed.
> The effect of multiple quotas is cumulative, but it is expected that two different ResourceQuota resources for the same namespace do not limit the use of the same type of Kubernetes or compute resource.
> For example, two different quotas in a namespace should not both attempt to limit the maximum number of pods allowed.

The following table describes some resources that a quota can restrict by their count or number:

| Resource Name            | Quota Description
|:------------------------:|:-----------------:|
| `pods`                   | Total number of pods
| `replicationcontrollers` | Total number of replication controllers
| `services`               | Total number of services
| `secrets`                | Total number of secrets
| `persistentvolumeclaims` | Total number of persistent volume claims


The following table describes some compute resources that can be restricted by a quota:

| Compute resource Name        | Quota Description
|:----------------------------:|:-----------------:|
| CPU (`requests.cpu`)         | Total CPU use across all containers
| Memory (`requests.memory`)   | Total memory use across all containers
| Storage (`requests.storage`) | Total storage requests by containers across all persistent volume claims

Quota attributes can track either resource requests or resource limits for all pods in the namespace. By default, quota attributes track resource requests. Instead, to track resource limits, prefix the compute resource name with limits, for example, limits.cpu.

The following listing shows a ResourceQuota resource defined using YAML syntax. This example specifies quotas for both the number of resources and the use of compute resources:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
spec:
  hard:
    services: "10"
    cpu: "1300m"
    memory: "1.5Gi"
```

Resource units are the same for pod resource requests and resource limits. For example, Gi means GiB, and m means millicores. One millicore is the equivalent to 1/1000 of a single CPU core.

Resource quotas can be created in the same way as any other Kubernetes resource; that is, by passing a YAML or JSON resource definition file to the kubectl create command:

```bash
[user@host ~]$ kubectl create --save-config -f dev-quota.yml
```

Another way to create a resource quota is by using the kubectl create quota command, for example:

```bash
[user@host ~]$ kubectl create quota dev-quota --hard services=10,cpu=1300,memory=1.5Gi
```

Use the kubectl get resourcequota command to list available quotas, and use the kubectl describe resourcequota command to view usage statistics related to any hard limits defined in the quota, for example:

```bash
[user@host ~]$ kubectl get resourcequota
NAME            AGE   REQUEST
compute-quota   51s   cpu: 500m/10, memory: 300Mi/1Gi                        ...
count-quota     28s   pods: 1/3, replicationcontrollers: 1/5, services: 1/2  ...
```

Without arguments, the kubectl describe quota command displays the cumulative limits set for all ResourceQuota resources in the namespace:

```bash
[user@host ~]$ kubectl describe quota
Name:       compute-quota
Namespace:  schedule-demo
Resource    Used    Hard
--------    ----    ----
cpu         500m    10
memory      300Mi   1Gi


Name:                   count-quota
Namespace:              schedule-demo
Resource                Used  Hard
--------                ----  ----
pods                    1     3
replicationcontrollers  1     5
services                1     2
```

An active quota can be deleted by name using the kubectl delete command:

```bash
[user@host ~]$ kubectl delete resourcequota QUOTA
```

When a quota is first created in a namespace, the namespace restricts the ability to create any new resources that might violate a quota constraint until it has calculated updated usage statistics. After a quota is created and usage statistics are up-to-date, the namespace accepts the creation of new resources. When creating a new resource, the quota usage immediately increments. When deleting a resource, the quota use decrements during the next full recalculation of quota statistics for the namespace.

Quotas are applied to new resources, but they do not affect existing resources. For example, if you create a quota to limit a namespace to 15 pods, but 20 pods are already running, then the quota will not remove the additional 5 pods that exceed the quota.

> **IMPORTANT**:
>
> ResourceQuota constraints are applied for the namespace as a whole, but many Kubernetes processes, such as builds and deployments, create pods inside the namespace and might fail because starting them would exceed the namespace quota.
>
> If a modification to a namespace exceeds the quota for a resource count, then Kubernetes denies the action and returns an appropriate error message to the user.
> However, if the modification exceeds the quota for a compute resource, then the operation does not fail immediately; Kubernetes retries the operation several times, giving the administrator an opportunity to increase the quota or to perform another corrective action, such as bringing a new node online.

> **IMPORTANT**:
>
> If a quota that restricts usage of compute resources for a namespace is set, then Kubernetes refuses to create pods that do not specify resource requests or resource limits for that compute resource.
> To use most templates and builders with a namespace restricted by quotas, the namespace must also contain a limit range resource that specifies default values for container resource requests.

## Applying Limit Ranges

A LimitRange resource, also called a limit, defines the default, minimum, and maximum values for compute resource requests, and the limits for a single pod or container defined inside the namespace. A resource request or limit for a pod is the sum of its containers.

To understand the difference between a limit range and a resource quota, consider that a limit range defines valid ranges and default values for a single pod, and a resource quota defines only top values for the sum of all pods in a namespace. A cluster administrator concerned about resource usage in a Kubernetes cluster usually defines both limits and quotas for a namespace.

A limit range resource can also define default, minimum, and maximum values for the storage capacity requested by an image, image stream, or persistent volume claim. If a resource that is added to a namespace does not provide a compute resource request, then it takes the default value provided by the limit ranges for the namespace. If a new resource provides compute resource requests or limits that are smaller than the minimum specified by the namespace limit ranges, then the resource is not created. Similarly, if a new resource provides compute resource requests or limits that are higher than the maximum specified by the namespace limit ranges, then the resource is not created.

The following listing shows a limit range defined using YAML syntax:

```yaml
apiVersion: "v1"
kind: "LimitRange"
metadata:
  name: "dev-limits"
spec:
  limits:
    - type: "Pod"
      max:  <1>
        cpu: "500m"
        memory: "750Mi"
      min:  <2>
        cpu: "10m"
        memory: "5Mi"
    - type: "Container"
      max:  <3>
        cpu: "500m"
        memory: "750Mi"
      min:  <4>
        cpu: "10m"
        memory: "5Mi"
      default:  <5>
        cpu: "100m"
        memory: "100Mi"
      defaultRequest:  <6>
        cpu: "20m"
        memory: "20Mi"
    - type: "PersistentVolumeClaim"  <7>
      min:
        storage: "1Gi"
      max:
        storage: "50Gi"
```

1. The maximum amount of CPU and memory that all containers within a pod can consume.
   A new pod that exceeds the maximum limits is not created.
   An existing pod that exceeds the maximum limits is restarted.

2. The minimum amount of CPU and memory consumed across all containers within a pod.
   A pod that does not satisfy the minimum requirements is not created.
   Because many pods only have one container, you might set the minimum pod values to the same values as the minimum container values.

3. The maximum amount of CPU and memory that an individual container within a pod can consume.
   A new container that exceeds the maximum limits does not create the associated pod.
   An existing container that exceeds the maximum limits restarts the entire pod.

4. The minimum amount of CPU and memory that an individual container within a pod can consume.
   A container that does not satisfy the minimum requirements prevents the associated pod from being created.

5. The default maximum amount of CPU and memory that an individual container can consume.
   This is used when a CPU resource limit or a memory limit is not defined for the container.

6. The default CPU and memory an individual container requests.
   This default is used when a CPU resource request or a memory request is not defined for the container.
   If CPU and memory quotas are enabled for a namespace, then configuring the defaultRequest section allows pods to start, even if the containers do not specify resource requests.

7. The minimum and maximum sizes allowed for a persistent volume claim.

Users can create a limit range resource in the same way as any other Kubernetes resource; that is, by passing a YAML or JSON resource definition file to the kubectl create command:

```bash
[user@host ~]$ kubectl create --save-config -f dev-limits.yml
```

Use the kubectl describe limitrange command to view the limit constraints enforced in a namespace:

```bash
[user@host ~]$ kubectl describe limitrange dev-limits
Name:       dev-limits
Namespace:  schedule-demo
Type                      Resource                 Min  Max    Default Request ...
----                      --------                 ---  ---    --------------- ...
Pod                       cpu                      10m  500m   -               ...
Pod                       memory                   5Mi  750Mi  -               ...
Container                 memory                   5Mi  750Mi  20Mi            ...
Container                 cpu                      10m  500m   20m             ...
PersistentVolumeClaim     storage                  1Gi  50Gi   -               ...
```

An active limit range can be deleted by name with the kubectl delete command:

```bash
[user@host ~]$ kubectl delete limitrange dev-limits
```

After a limit range is created in a namespace, all requests to create new resources are evaluated against each limit range resource in the namespace. If the new resource violates the minimum or maximum constraint enumerated by any limit range, then the resource is rejected. If the new resource does not set an explicit value, and the constraint supports a default value, then the default value is applied to the new resource as its usage value.

All resource update requests are also evaluated against each limit range resource in the namespace. If the updated resource violates any constraint, then the update is rejected.

> **IMPORTANT**:
>
> Avoid setting LimitRange constraints that are too high, or ResourceQuota constraints that are too low.
> A violation of LimitRange constraints prevents pod creation, resulting in error messages.
> A violation of ResourceQuota constraints prevents a pod from being scheduled to any node.
> The pod might be created but remain in the pending state.
