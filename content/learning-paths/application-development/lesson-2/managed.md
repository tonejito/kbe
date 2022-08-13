+++
description = ""
+++

<!-- https://kubebyexample.com/en/learning-paths/application-development-kubernetes/lesson-2-deploying-managed-applications/deploying -->

# Deploying Managed Applications

## Objectives

After completing this section, you should be able to use Kubernetes container management capabilities to deploy containerized applications in a declarative way.

## Managing Containers

One of the most significant features of Kubernetes is that it enables developers to use a declarative approach for automatic container life cycle management.
_Declarative_ approach means developers declare **what** should be the status of the application, and Kubernetes will update the containers to reach that state.

Some basic values a developer must declare are:

- The container images used by the application.
- The number of instances (replicas) of the application that Kubernetes must run simultaneously.
- The strategy for updating the replicas when a new version of the application is available.

With this information, Kubernetes deploys the application, keeps the number of replicas, and terminates or redeploys application containers when the state of the application does not match the declared configuration.
Kubernetes continuously revisits this information and updates the state of the application accordingly.

This behavior enables important features of Kubernetes as a container management platform:

**Automatic deployment**

- Kubernetes deploys the configured application without manual intervention.

**Automatic scaling**

- Kubernetes creates as many replicas of the application as requested.
- If the number of replicas requested increases or decreases, then Kubernetes automatically creates new containers (scale-up) or terminates exceeding containers (scale-down) to match the requested number.

**Automatic restart**

- If a replica terminates unexpectedly or becomes unresponsive, then Kubernetes deletes the associated container and automatically spins up a new one to match the expected replica count.

**Automatic rollout**

- When a new version of the application is detected, or a new configuration applies, Kubernetes automatically updates the existing replicas.
- Kubernetes monitors this rollout process to make sure the application retains the declared number of active replicas.

## Creating a Deployment

A **deployment** resource contains all the information Kubernetes needs to manage the life cycle of the application's containers.

The simplest way to create a `deployment` resource is by using the `kubectl create deployment` command.

```bash
[user@host ~]$ kubectl create deployment deployment-name --replicas=3 --image image
deployment.apps/deployment-name created
```

This command creates a deployment resource named `deployment-name`.
This deployment instructs Kubernetes to deploy _three_ replicas of the application pod, and to use the `image` container image.

Use the `kubectl get deployment deployment-name` command to retrieve the deployment resource from Kubernetes.

Use the `--output yaml` parameter to get detailed information about the resource in the YAML format.
Alternatively, you can use the short `-o yaml` version.

```bash
[user@host ~]$ kubectl get deployment deployment-name -o yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: deployment-name
  name: deployment-name
...output omitted...
spec:
...output omitted...
  replicas: 3
...output omitted...
  selector:
    matchLabels:
      app: deployment-name
  template:
    metadata:
...output omitted...
      labels:
        app: deployment-name
    spec:
      containers:
      - image: image
...output omitted...
```

> **Note**:
>
> Review `kubectl get` options and adapt the output to your needs.
>
> For example, use the `--show-managed-fields=false` to skip the `metadata.managedFields` section of the deployment.
> Use different values for the `-o` option for formatting or filtering the output.
> Find more details in the links in the _References_ section.

The Kubernetes declarative deployment approach enables you to use the _GitOps_ principles.
GitOps focuses on a versioned repository, such as `git`, which stores your deployment configuration.

Following GitOps principles, you can store the deployment manifest in **YAML** or **JSON** format in your application repository.
Then, after the appropriate changes, you can create the deployment manually or programmatically by using the `kubectl apply -f deployment-file` command.

You can also edit `deployment` resource manifests directly from the command line.
The `kubectl edit deployment deployment-name` command retrieves the deployment resource and opens it in a local text editor (the exact editor depends on your system and local configuration).
When the editor closes, the `kubectl edit` command applies any changes to the manifest.

> **Note**:
> 
> The `kubectl get deployment deployment-name -o yaml` command contains run time information about the deployment.
> 
> For example, the output contains current deployment status, creation timestamps, and similar information.
> Deployment YAML files with run time information might not be reusable across namespaces and projects.
> 
> Deployment YAML files that you want to check-in to your version control system, such as git, should not contain any run time information.
> Kubernetes generates this information at as needed.

## Understanding the Schema of a Deployment Resource

Before updating a deployment resource, it is important to know the schema of the resource and the meaning of the most significant parts.

The following depicts the main entries in a deployment manifest:

```yaml
apiVersion: apps/v1
kind: Deployment  <1>
metadata:  <2>
...output omitted...
  labels:
    app: versioned-hello
  name: versioned-hello
...output omitted...
spec:  <3>
...output omitted...
  replicas: 3  <4>
...output omitted...
  selector:
    matchLabels:
      app: versioned-hello
  strategy:type: RollingUpdate  <5>
...output omitted...
  template:
    metadata:
      labels:
        app: versioned-hello
...output omitted...
    spec:  <6>
      containers:
      - image: quay.io/redhattraining/versioned-hello:v1.1  <7>
        name: versioned-hello
...output omitted...
status:  <8>
...output omitted...
  replicas: 3  <9>
...output omitted...
```

1. Manifest kind identifies the resource type.

2. Manifest metadata.
   Include deployment name and labels.

3. Deployment specification contains deployment configuration.

4. Number of desired replicas of the container.

5. Deployment strategy to use when updating pods.

6. Includes a list of pod definitions for each new container created by the deployment as well as other fields to control container management.

7. Container image used to create new containers.

8. Current status of the deployment.
   This section is automatically generated and updated by Kubernetes.

9. The current number of replicas currently deployed.

## Replicas

The `replicas` field under the `spec` section (also denoted as the `spec.replicas` section) declares the number of _expected_ replicas that Kubernetes should keep running.
Kubernetes will continuously review the number of replicas that are running and responsive, and scale accordingly.

## Deployment Strategy

When the application changes due to an image change or a configuration change, Kubernetes replaces the old running containers with updated ones.
However, just redeploying all replicas at once can lead to problems with the application, such as:

- Leaving the application with too few running replicas.

- Creating too many replicas and leading to an overcommitment of resources.

- Rendering the application unavailable if the new version is faulty.

To avoid these issues, Kubernetes defines two strategies:

`RollingUpdate`
: Kubernetes terminates and deploys pods progressively.
: This strategy defines a maximum amount of pods unavailable anytime.
: It defines the difference between the available pods and the desired available replicas.
: The RollingUpdate strategy also defines an amount of pods deployed at any time over the number of desired replicas.
: Both values default to 25% of the desired replicas.

| <video controls="controls" width="100%" height="auto"><source type="video/mp4" src="https://kubebyexample.com//sites/default/files/2021-06/Deployment-Strategy.mp4"></video>
|:--------:|
| Deployment strategy

`Recreate`
: This strategy means that no issues are expected to impact the application, so Kubernetes terminates all replicas and recreates them on a best effort basis.

> **Note**:
>
> Different distributions of Kubernetes include other deployment strategies.
> Refer to the documentation of the distribution for details.

## Template

When Kubernetes deploys new pods, it needs the exact manifest to create the pod.
The `spec.template.spec` section holds exactly the same structure as a `Pod` manifest.
Kubernetes uses this section to create new pods as needed.

The following entries in the template deserve special attention:

- The `spec.template.spec.containers.image` entry declares the image (or images) Kubernetes will deploy in the pods managed by this deployment.

- Kubernetes uses the `spec.template.spec.containers.name` entry as a _prefix_ for the names of the pods it creates.

## Labels

Labels are key-value pairs assigned in resource manifests.
Both developers and Kubernetes use labels to identify sets of grouped resources, such as all resources belonging to the same application or environment.
Depending on the position inside the Deployment, labels have a different meaning:

`metadata.labels`
: Labels applied directly to the manifest, in this case the deployment resource.
  You can find objects matching these labels with the `kubectl get kind --selector="key=value"`.
: For example, `kubectl get deployment --selector="app=myapp"` returns all deployments with a label `app=myapp` in the `metadata.labels` section.

<br/>

`spec.selector.matchLabels.selector`
: Determine what pods are under the control of the deployment resource.
: Even if some pods in the cluster are not deployed via this deployment, if they match the labels in this section then they will count as replicas and follow the rules defined in this deployment manifest.

<br/>

`spec.template.metadata.labels`
: Like the rest of the template, it defines how Kubernetes creates new pods using this deployment.
  Kubernetes will label all the pods created by this deployment resource with these values.
