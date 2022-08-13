+++
description = ""
+++

<!-- https://kubebyexample.com/en/learning-paths/application-development-kubernetes/lesson-4-customize-deployments-application-5 -->

# Guided Exercise: Configuring Cloud Applications

## Injecting Configuration Data into an Application

In this exercise, you will use configuration maps and secrets to externalize the configuration for a containerized application.

## Outcomes
You should be able to:

- Deploy a simple Node.js-based application that prints configuration details from environment variables and files.

- Inject configuration data into the container using configuration maps and secrets.

- Change the data in the configuration map and verify that the application picks up the changed values.

## Prerequisites

Ensure that:

- Minikube and kubectl are running on your machine

- You have cloned the DO100-apps repository

- You have executed the setup script located at DO100-apps/setup/operating-system/setup.sh

Make sure your kubectl context uses the namespace username-dev. This allows you to execute kubectl commands directly into that namespace.

```bash
[user@host ~]$ kubectl config set-context --current --namespace=username-dev
```

## Instructions

1) Review the application source code and deploy the application.

1.1) Enter your local clone of the DO100-apps Git repository.

```bash
[user@host ~]$ cd DO100-apps
```

1.2) Inspect the DO100-apps/app-config/app/app.js file.

The application reads the value of the APP_MSG environment variable and prints the contents of the /opt/app-root/secure/myapp.sec file:

```text
const response = Value in the APP_MSG env var is => ${process.env.APP_MSG}\n;
...output omitted...
// Read in the secret file
fs.readFile('/opt/app-root/secure/myapp.sec', 'utf8', function (secerr,secdata) {
...output omitted...
```

1.3) Create a new deployment called app-config using the DO100-apps/app-config/kubernetes/deployment.yml file.

```bash
[user@host DO100-apps]$ kubectl apply -f app-config/kubernetes/deployment.yml
deployment.apps/app-config created
```

2) Test the application.

2.1) Expose the deployment on port 8080:

```bash
[user@host DO100-apps]$ kubectl expose deployment/app-config --port 8080
service/app-config exposed
```

2.1) Modify the app-config/kubernetes/ingress.yml file to contain correct host value for your Kubernetes environment:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-config
  labels:
    app: app-config
spec:
  rules:
    - host: _INGRESS-HOST_
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app-config
                port:
                  number: 8080
```

Replace _INGRESS-HOST_ with the hostname associated with your Kubernetes cluster, such as hello.example.com or app-config-USER-dev.apps.sandbox.x8i5.p1.openshiftapps.com. If you are unsure of the hostname to use then refer to [Guided Exercise: Contrasting Kubernetes Distributions]() to find the appropriate value.

2.2) Create the ingress resource to be able to invoke the service just exposed:

```bash
[user@host DO100-apps]$ kubectl create -f app-config/kubernetes/ingress.yml
ingress.networking.k8s.io/app-config created
```

2.3) Invoke the host URL by using the curl command:

```bash
[user@host DO100-apps]$ curl hello.example.com
Value in the APP_MSG env var is => undefined
Error: ENOENT: no such file or directory, open '/opt/app-root/secure/myapp.sec'
```

The undefined value for the environment variable and the ENOENT: no such file or directory error are shown because neither the environment variable nor the file exists in the container.

3) Create the configuration map and secret resources.

3.1) Create a configuration map resource to hold configuration variables that store plain text data.

Create a new configuration map resource called appconfmap. Store a key called APP_MSG with the value Test Message in this configuration map:

> **Note**:
>
> This course uses the backslash character (`\`) to break long commands.
> On Linux and macOS, you can use the line breaks.
>
> On Windows, use the backtick character (<code>&#96;</code>) to break long commands.
>
> Alternatively, do not break long commands.

```bash
[user@host DO100-apps]$ kubectl create configmap appconfmap \
--from-literal APP_MSG="Test Message"
configmap/appconfmap created
```

3.2) Verify that the configuration map contains the configuration data:

```bash
[user@host DO100-apps]$ kubectl describe cm/appconfmap
Name:        appconfmap
...output omitted...
Data
====
APP_MSG:
---
Test Message
...output omitted...
```

3.3) Review the contents of the DO100-apps/app-config/app/myapp.sec file:

```text
username=user1
password=pass1
salt=xyz123
```

3.4) Create a new secret to store the contents of the myapp.sec file.

```bash
[user@host DO100-apps]$ kubectl create secret generic appconffilesec \
--from-file app-config/app/myapp.sec
secret/appconffilesec created
```

3.5) Verify the contents of the secret. Note that the contents are stored in base64-encoded format:

```bash
[user@host DO100-apps]$ kubectl get secret/appconffilesec -o json
{
    "apiVersion": "v1",
    "data": {
        "myapp.sec": "dXNlcm5hbWU9dXNlcjEKcGFzc3dvcmQ9cGFzczEKc2...
    },
    "kind": "Secret",
    "metadata": {
        ...output omitted...
        "name": "appconffilesec",
        ...output omitted...
    },
    "type": "Opaque"
}
```

4) Inject the configuration map and the secret into the application container.

4.1) Use the kubectl set env command to add the configuration map to the deployment configuration:

```bash
[user@host DO100-apps]$ kubectl set env deployment/app-config \
--from configmap/appconfmap
deployment.apps/app-config env updated
```

4.2) Use the kubectl patch command to add the secret to the deployment configuration:

Patch the app-config deployment using the following patch code. You can find this content in the DO100-apps/app-config/kubernetes/secret.yml file.

```bash
[user@host DO100-apps]$ kubectl patch deployment app-config \
--patch-file app-config/kubernetes/secret.yml
deployment.apps/app-config patched
```

5) Verify that the application is redeployed and uses the data from the configuration map and the secret.

5.1) Verify that the configuration map and secret were injected into the container. Retest the application using the route URL:

```bash
[user@host DO100-apps]$ curl hello.example.com
Value in the APP_MSG env var is => Test Message
The secret is => username=user1
password=pass1
salt=xyz123
```

Kubernetes injects the configuration map as an environment variable and mounts the secret as a file into the container. The application reads the environment variable and file and then displays its data.

## Finish

Delete the created resources to clean your cluster. Kubernetes automatically deletes the associated pods.

```bash
[user@host ~]$ kubectl delete all,ingress -l app=app-config
pod "app-config-5cb9674bc5-wktrj" deleted
service "app-config" deleted
deployment.apps "app-config" deleted
ingress.networking.k8s.io "app-config" deleted

[user@host ~]$ kubectl delete cm appconfmap
configmap "appconfmap" deleted

[user@host ~]$ kubectl delete secret appconffilesec
secret "appconffilesec" deleted
```
