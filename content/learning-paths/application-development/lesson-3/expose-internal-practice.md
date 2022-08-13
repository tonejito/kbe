+++
description = ""
+++

<!-- https://kubebyexample.com/en/learning-paths/application-development-kubernetes/lesson-3-networking-kubernetes/guided-exercise -->

# **Guided Exercise**: Exposing Applications for Internal Access

In this exercise you will deploy two apps in different namespaces. They communicate by using the built-in Kubernetes DNS resolution system.

## Outcomes

You should be able to:

- Create a service using kubectl expose
- Create a service using a manifest
- Use DNS resolution for service communication

## Prerequisites

Ensure that:

- Minikube and kubectl are running on your machine
- You have cloned the DO100-apps repository
- You have executed the setup script

## Instructions

To illustrate how communication is handled in Kubernetes, you use two applications.

- The name-generator app produces random names that can be consumed in the /random-name endpoint.

- The email-generator app produces random emails that can be consumed in the /random-email endpoint.

- The email-generator app consumes name-generator to include a random name in the emails that it generates.

Make sure your kubectl context uses the namespace username-dev. This allows you to execute kubectl commands directly into that namespace.

```bash
[user@host DO100-apps]$ kubectl config set-context \
    --current --namespace=username-dev
```

1) Deploy the name-generator app in the username-dev namespace.

1.1) Open a command-line terminal. In the DO100-apps repository, navigate to the name-generator folder.

1.2) Use the kubectl apply command to create a Deployment from the manifest located in the kubernetes directory. It creates three replicas of the name-generator app by using the quay.io/redhattraining/do100-name-generator:v1.0 image.

```bash
[user@host name-generator]$ kubectl apply -f kubernetes/deployment.yml
deployment.apps/name-generator created
```

1.3) List the deployments to verify it has been created successfully. Use the command kubectl get deployment.

```bash
[user@host name-generator]$ kubectl get deployment
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
name-generator   3/3     3            3           90m
```

2) Create a Service for the deployment of the name-generator app by using the kubectl expose command.

2.1) Using the deployment name, expose the service at port number 80. The following command creates a service that forwards requests on port 80 for the DNS name name-generator.namespace.local-domain to containers created by the name-generator deployment on port 8080.

```bash
[user@host name-generator]$ kubectl expose deployment name-generator --port 80 --target-port=8080
service/name-generator exposed
```

2.2) List the services to verify that the name-generator service has been created successfully. Use the command kubectl get service.

```bash
[user@host name-generator]$ kubectl get service
NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
name-generator   ClusterIP   10.98.55.248   <none>        80/TCP    31s
```

3) Review the code of the email-generator to see how the request to the name-generator is made. Deploy the app in the username-dev namespace.

3.1) In the DO100-apps repository, navigate to the email-generator folder.

3.2) In the app directory, open the server.js file. The server.js file is a NodeJS application, which exposes the endpoint /random-email on the 8081 port.

3.3) In the same folder, open the generate-email.js file. The generateEmail method generates a random email by making an HTTP request to the name-generator service.

3.4) The getNameFromExternalService method performs the actual HTTP request. The host, which is the name-generator service name, is defined in the NAME_GENERATOR_URL variable.

3.5) On the command line, return to the email-generator folder.

3.6) Apply the Deployment manifest in the username-dev namespace. It is located in the kubernetes folder and creates three replicas of the email-generator app by using the quay.io/redhattraining/do100-email-generator:v1.0 image.

```bash
[user@host email-generator]$ kubectl apply -f kubernetes/deployment.yml
deployment.apps/email-generator created
```

3.7) List the deployments in the namespace to verify it has been created successfully. Use the command kubectl get deployment.

```bash
[user@host email-generator]$ kubectl get deployment
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
email-generator   3/3     3            3           5s
name-generator    3/3     3            3           66m
```

4) Create a service for the deployment of the email-generator app by using a manifest.

4.1) Apply the Service manifest in the username-dev namespace. It is located in the kubernetes folder. Use the kubectl apply command.

This command exposes the service in the 80 port and targets port 8081, which is where the email-generator app serves.

```bash
[user@host email-generator]$ kubectl apply -f kubernetes/service.yml
service/email-generator created
```

4.2) List the services to verify that the email-generator service has been created successfully. Use the command kubectl get service.

```bash
[user@host email-generator]$ kubectl get service
NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
email-generator   ClusterIP   10.108.68.139   <none>        80/TCP     3s
name-generator    ClusterIP   10.109.14.167   <none>        80/TCP     68m
```

5) Verify that everything works properly by making an HTTP request to the email-generator app from the username-stage namespace. The result should contain a name plus some numbers at the end.

5.1) To make a request to the email-generator app from another namespace, you use the Kubernetes DNS resolution pattern service-name.namespace. In this case, the host is email-generator.username-dev.

5.2) Create a temporary pod that enables you to make a request to the email-generator application. Run the following command, which provides you with a terminal to execute curl.

```bash
[user@host email-generator]$ kubectl run -n username-stage \
    curl -it --rm --image=registry.access.redhat.com/ubi8/ubi-minimal -- sh
```

Note that:

- The command creates a pod named curl in the username-stage namespace.

- The pod contains one container that uses the registry.access.redhat.com/ubi8/ubi-minimal container image.

- After Kubernetes creates the pod, you create an interactive remote shell session into the pod.

- When you exit out of the interactive session, Kubernetes terminates the pod.

The command might take some time to execute. If you see the message If you don't see a command prompt, try pressing enter., then press Enter on your keyboard and the terminal opens.

5.3) In the terminal, make an HTTP request to the email-generator service by using curl. Because the service runs on the default HTTP port (80), you do not need to specify the port. You can also omit the local DNS domain.

```bash
$ curl http://email-generator.username-dev/random-email
```

You should see a response in JSON format similar to this:

```json
{"email":"username@host.tld"}
```

5.4) Type exit to exit the terminal. The pod used to make the request is automatically deleted.

## Finish

Remove all resources used in this exercise.

You can delete all resources in the namespace with the following command:

```bash
[user@host email-generator]$ kubectl delete all --all
pod "email-generator-ff5fdf658-bz8v2" deleted
pod "email-generator-ff5fdf658-k6ln6" deleted
pod "email-generator-ff5fdf658-pn466" deleted
pod "name-generator-9744675d-4kmp9" deleted
pod "name-generator-9744675d-grw9g" deleted
pod "name-generator-9744675d-tlpz9" deleted
service "email-generator" deleted
service "name-generator" deleted
deployment.apps "email-generator" deleted
deployment.apps "name-generator" deleted
```

Alternatively, you can delete the resources individually. Delete both the email-generator and name-generator services:

```bash
[user@host email-generator]$ kubectl delete service email-generator
service "email-generator" deleted

[user@host email-generator]$ kubectl delete service name-generator
service "name-generator" deleted
```

Delete both the email-generator and name-generator deployments:

```bash
[user@host email-generator]$ kubectl delete deployment email-generator
deployment.apps "email-generator" deleted

[user@host email-generator]$ kubectl delete deployment name-generator
deployment.apps "name-generator" deleted
```

This concludes the guided exercise.
