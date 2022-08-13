+++
description = ""
+++

<!-- https://kubebyexample.com/en/learning-paths/application-development-kubernetes/lesson-1-running-containerized-applications-1 -->

# Contrasting Kubernetes Distributions

## Objectives

After completing this section, you should be able to see the differences between several Kubernetes implementations, and understand how to prepare different Kubernetes flavors for this course.

## Kubernetes Distributions

Kubernetes has historically been a general solution for container management and orchestration.
With this versatility, Kubernetes can solve the same problems in different ways depending on needs and opinions.
Because of this Kubernetes has evolved into different opinionated distributions based on:

The target size of the cluster: From small single-node clusters to large-scale clusters of hundreds of thousands of nodes.

The location of the nodes: Either locally on the developer workstation, on premises (such as a private data center), on the cloud, or a hybrid solution of those two.

The ownership of the management: Self-managed clusters versus Kubernetes-as-a-Service.

The following table shows a classification for some of the most popular Kubernetes distributions:

| Management              | Environment          | Big Scale                                                | Small Scale
|:-----------------------:|:--------------------:|:--------------------------------------------------------:|:-----------:
| Self-Managed            | Local                | --                                                       | minikube, CodeReady Containers, Microk8s, Docker Kubernetes
| Self-Managed            | On Premises / Hybrid | Red Hat OpenShift, VMWare Tanzu, Rancher                 | --
| Kubernetes-as-a-Service | On Cloud             | OpenShift Dedicated, Google Container Engine, Amazon EKS | Developer Sandbox

> **Note**
> This course supports `minikube` (version `1.20.0`) for local development and **Developer Sandbox** for remote development.
> Instructions and exercises have been tested in the following operating systems:
>
> * Fedora Linux 33 and 34
> * Red Hat Enterprise Linux 8
> * Windows 10 Pro and Enterprise
> * MacOS Big Sur (11.3.1)

Visit the links in the references section below for a comprehensive list of Kubernetes certified distributions.

## Kubernetes Extensions

Kubernetes is highly extendable for adding more services to the platform.
Each distribution provides different approaches (or none) for adding capabilities to Kubernetes:

### DNS

DNS allows internal name resolution inside the cluster, so pods and services can refer to others by using a fixed name.

Both `minikube` and OpenShift include a **CoreDNS** controller that provides this feature.

### Dashboard

The dashboard provides a graphical user interface to Kubernetes.

`minikube` provides an add-on and utility commands for using the general-purpose **Dashboard** open source application.
OpenShift includes the **Console**, a dedicated application that integrates most of the Kubernetes extensions provided by OpenShift.

### Ingress

The ingress extension allows traffic to get into the cluster network, redirecting requests from managed domains to services and pods.
Ingress enables services and applications inside the cluster to expose ports and features to the public.

`minikube` uses an ingress add-on based on the `ingress-nginx` controller.

> **Note**
> You must install the ingress add-on for minikube for some exercises.
> Refer to the [Guided Exercise: Contrasting Kubernetes Distributions](../kubernetes-distributions-practice) for instructions.

OpenShift deploys an ingress controller based on `HAProxy` and controlled by a **Ingress Operator**.
OpenShift also introduces the `route` resource.
A `route` extends the `ingress` manifest to ease controlling ingress traffic.

### Storage

The storage extension allows pods to use persistent storage and nodes to distribute and share the storage contents.

OpenShift bases its storage strategy on **Red Hat OpenShift Data Foundation**, a storage provider supporting multiple storage strategies across nodes and hybrid clouds.
`minikube` provides out-of-the-box storage by using the underlying storage infrastructure (either local the file system or the virtual machine's file-system).
This feature is provided by the `storage-provisioner` add-on.
`minikube` also provides a `storage-provisioner-gluster` add-on that allows Kubernetes to use **Gluster** as shared persistent storage.

### Authentication and authorization

Kubernetes embeds a certificate authority (CA) and considers anyone that presents a certificate issued by that CA as a valid user.

`minikube` provides the user with an administrator `minikube` account, so users have total control over the cluster.

Different OpenShift implementations differ on authentication features, but all of them agree on avoiding the use of administration accounts.
Developer Sandbox provides limited access to the user, restricting them to the `username-dev` and `username-stage` namespaces.

Authorization in Kubernetes is role based.
Authorized users or administrators can assign predefined roles to users on each resource.
For example, administrators can grant read-only access to auditor users to application namespaces.

### Operators

Operators are a core feature of most Kubernetes distributions.
Operators allow automated management of applications and Kubernetes services, by using a declarative approach.

`minikube` requires the `olm` add-on to be installed to enable operators in the cluster.

OpenShift distributions enable operators by default, despite the fact that Kubernetes-as-a-Service platforms usually restrict user-deployed operators.
Developer Sandbox does not allow users to install operators, but comes with the **RHOAS-Operator** and the **Service Binding Operator** by default.

Table 1.
Comparison summary of Kubernetes features

| Feature            | `minikube`                  | Developer Sandbox
|:-------------------|:----------------------------|:------------------
| **DNS**            | CoreDNS                     | CoreDNS
| **Dashboard**      | Dashboard add-on            | OpenShift Console
| **Ingress**        | NGINX Ingress add-on        | Operator-controlled HAProxy
| **Storage**        | Local or Gluster add-ons    | Red Hat OpenShift Data Foundation
| **Authentication** | Administrator minikube user | Developer used restricted to 2 namespaces
| **Operators**      | OLM add-on. No restrictions | Limited to RHOAS and Service Binding

--------------------------------------------------------------------------------

## References

- [minikube documentation](https://minikube.sigs.k8s.io/docs/)
- [Developer Sandbox](https://developers.redhat.com/developer-sandbox)
- [CNCF Cloud Native Interactive Landscape - Certified Kubernetes Platforms](https://landscape.cncf.io/card-mode?category=certified-kubernetes-distribution,certified-kubernetes-hosted,certified-kubernetes-installer&grouping=category)
- [Certificate Signing Requests](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user)
