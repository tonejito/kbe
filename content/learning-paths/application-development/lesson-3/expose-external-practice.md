+++
description = ""
+++

<!-- https://kubebyexample.com/en/learning-paths/application-development-kubernetes/lesson-3-networking-kubernetes/guided-exercise-0 -->

# Guided Exercise: Exposing Applications for External Access

In this exercise you will provide external access to a service running inside your Kubernetes cluster.

## Outcomes

You should be able to:

- Verify that the service IP address and the associated pod IP addresses for an application are not accessible outside of the cluster.

- Create an ingress resource to provide external access to an application service.

- Confirm that the ingress redirects traffic to the service.

## Prerequisites

You need a working Kubernetes cluster with the following:

- Your kubectl command configured to communicate with the cluster.

- An ingress controller enabled in your cluster and the associated domain name mapping.

- Your Kubernetes context referring to your cluster and using the username-dev namespace.

Review [Guided Exercise: Contrasting Kubernetes Distributions]() for a comprehensive guide to install and enable ingress in your Kubernetes cluster.

## Instructions

1) Deploy a sample hello application. The hello app displays a greeting and its local IP address. When running under Kubernetes, this is the IP address assigned to its pod.

Create a new deployment named hello that uses the container image located at quay.io/redhattraining/do100-hello-ip:v1.0 in the username-dev namespace. Configure the deployment to use three pods.

1.1) Create the hello deployment with three replicas. Use the container image located at quay.io/redhattraining/do100-hello-ip:v1.0. This container image simply displays the IP address of its associated pod.

```bash
[user@host ~]$ kubectl create deployment hello --replicas 3 \
    --image quay.io/redhattraining/do100-hello-ip:v1.0
deployment.apps/hello created
```

Run the kubectl get pods -w command to verify that three pods are running. Press Ctrl+C to exit the kubectl command after all three hello pods display the Running status.

```bash
[user@host ~]$ kubectl get pods -w
NAME                     READY   STATUS              RESTARTS   ...
hello-5f87ddc987-76hxn   0/1     ContainerCreating   0          ...
hello-5f87ddc987-j8bbv   0/1     ContainerCreating   0          ...
hello-5f87ddc987-ndbk5   0/1     ContainerCreating   0          ...
hello-5f87ddc987-j8bbv   1/1     Running             0          ...
hello-5f87ddc987-ndbk5   1/1     Running             0          ...
hello-5f87ddc987-76hxn   1/1     Running             0          ...
```

1.2) Create a service for the hello deployment that redirects to pod port 8080.

Run the kubectl expose command to create a service that redirects to the hello deployment. Configure the service to listen on port 8080 and redirect to port 8080 within the pod.

```bash
[user@host ~]$ kubectl expose deployment/hello --port 8080
service/hello exposed
```

Verify that Kubernetes created the service:

```bash
[user@host ~]$ kubectl get service/hello
NAME    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    ...
hello   ClusterIP   10.103.208.46   <none>        8080/TCP   ...
```

Note that the IP associated to the service is private to the Kubernetes cluster, You can not access that IP directly.

2) Create an ingress resource that directs external traffic to the hello service.

2.1) Use a text editor to create a file in your current directory named ingress-hello.yml.

Create the ingress-hello.yml file with the following content. Ensure correct indentation (using spaces rather than tabs) and then save the file.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello
  labels:
    app: hello
spec:
  rules:
    - host: INGRESS-HOST
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: hello
                port:
                  number: 8080
```

Replace INGRESS-HOST by the host name associated to your Kubernetes cluster, such as hello.example.com or hello-username-dev.apps.sandbox.x8i5.p1.openshiftapps.com. If you are unsure of the host name to use then refer to Guided Exercise: Contrasting Kubernetes Distributions to find the appropriate value.

The file at https://github.com/RedHatTraining/DO100-apps/blob/main/network/ingress-hello.yml contains the correct content for the ingress-hello.yml file. You can download the file and use it for comparison.

2.2) Use the kubectl create command to create the ingress resource.

```bash
[user@host ~]$ kubectl create -f ingress-hello.yml
ingress.networking.k8s.io/hello created
```

2.3) Display information about the hello ingress. If the command does not display an IP address, then wait up to a minute and try running the command again.

```bash
[user@host ~]$ kubectl get ingress/hello
NAME    CLASS    HOSTS               ADDRESS        PORTS   ...
hello   <none>   hello.example.com   192.168.64.7   80      ...
```

The value in the HOST column matches the host line specified in your ingress-hello.yml file. Your IP address is likely different from the one displayed here.

3) Verify that the ingress resource successfully provides access to the hello service and the pods associated with the service.

3.1) Access the domain name specified by your ingress resource.

Use the curl command to access the domain name associated to your ingress controller. Repeat the same command multiple times and note the IP of the responding pod replica varies:

```bash
[user@host ~]$ curl hello.example.com
Hello from IP: 172.17.0.5

[user@host ~]$ curl hello.example.com
Hello from IP: 172.17.0.5

[user@host ~]$ curl hello.example.com
Hello from IP: 172.17.0.6

[user@host ~]$ curl hello.example.com
Hello from IP: 172.17.0.6

[user@host ~]$ curl hello.example.com
Hello from IP: 172.17.0.4

[user@host ~]$ curl hello.example.com
Hello from IP: 172.17.0.4
```

The hello ingress queries the hello service to identify the IP addresses of the pod endpoints. The hello ingress then uses round robin load balancing to spread the requests among the available pods, and each pod responds to the curl command with the pod IP address.

Optionally, open a web browser and navigate to the wildcard domain name. The web browser displays a message similar to the following.

```text
Hello from IP: 172.17.0.6
```

Refresh you browser window to repeat the request and see different responses.

Note

Because load balancers frequently create an association between a web client and a server (one of the hello pods in this case), reloading the web page is unlikely to display a different IP address. This association, sometimes referred to as a sticky session, does not apply to the curl command.

## Finish

Delete the created resources that have the app=hello label.

```bash
[user@host ~]$ kubectl delete deployment,service,ingress -l app=hello
deployment.apps "hello" deleted
service "hello" deleted
ingress.networking.k8s.io "hello" deleted
```

Verify that no resources with the app=hello label exist in the current namespace.

```bash
[user@host ~]$ kubectl get deployment,service,ingress -l app=hello
No resources found in username-dev namespace.
```

This concludes the guided exercise.
