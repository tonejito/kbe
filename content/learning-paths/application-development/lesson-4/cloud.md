+++
description = ""
+++

<!-- https://kubebyexample.com/en/learning-paths/application-development-kubernetes/lesson-4-customize-deployments-application-4 -->

# Configuring Cloud Applications

## Objectives

After completing this section, you should be able to create Kubernetes resources holding application configuration and secrets, and how to make that configuration available to running applications.

## Externalizing Application Configuration in Kubernetes

Developers configure their applications through a combination of environment variables, command-line arguments, and configuration files. When deploying applications to Kubernetes, configuration management presents a challenge due to the immutable nature of containers. When running containerized applications, decoupling application and configuration code is of a higher priority than in traditional deployments.

The recommended approach for containerized applications is to decouple the static application binaries from the dynamic configuration data and to externalize the configuration. This separation ensures the portability of applications across many environments.

For example, you want to promote an application that is deployed to a Kubernetes cluster from a development environment to a production environment, with intermediate stages such as testing and user acceptance. You must use the same application container image in all stages and have the configuration details specific to each environment outside the container image.

## Using Secret and Configuration Map Resources

Kubernetes provides the secret and configuration map resource types to externalize and manage configuration for applications.

Secret resources are used to store sensitive information, such as passwords, keys, and tokens. As a developer, it is important to create secrets to avoid compromising credentials and other sensitive information in your application. There are different secret types that enforce usernames and keys in the secret object. Some of them are service-account-token, basic-auth, ssh-auth, tls, and opaque. The default type is opaque, which allows unstructured and unvalidated key:value pairs that can contain arbitrary values.

Configuration map resources are similar to secret resources, but they store nonsensitive data. A configuration map resource can be used to store fine-grained information, such as individual properties, or coarse-grained information, such as entire configuration files and JSON data.

You can create configuration map and secret resources using the kubectl command. You can then reference them in your pod specification and Kubernetes automatically injects the resource data into the container as environment variables, or as files mounted through volumes inside the application container.

You can also configure the deployment to reference configuration map and secret resources. Kubernetes then automatically redeploys the application and makes the data available to the container.

Data is stored inside a secret resource by using base64 encoding. When data from a secret is injected into a container, the data is decoded and either mounted as a file, or injected as environment variables inside the container.

> **Note**:
>
> Encoding any text in base64 does not add any layer of security except against casual snoop.

### Features of Secrets and Configuration Maps

Notice the following with respect to secrets and configuration maps:

- They can be referenced independently of their definition.

- For security reasons, mounted volumes for these resources are backed by temporary file storage facilities (tmpfs) and never stored on a node.

- They are scoped to a namespace.

## Creating and Managing Secrets and Configuration Maps
Secrets and configuration maps must be created before creating the pods that depend on them. Use the kubectl create command to create secrets and configuration map resources.

To create a new configuration map that stores string literals:

```bash
[user@host ~]$ kubectl create configmap config_map_name \
--from-literal key1=value1 \
--from-literal key2=value2
```

To create a new secret that stores string literals:

```bash
[user@host ~]$ kubectl create secret generic secret_name \
--from-literal username=user1 \
--from-literal password=mypa55w0rd
```

To create a new configuration map that stores the contents of a file or a directory containing a set of files:

```bash
[user@host ~]$ kubectl create configmap config_map_name \
--from-file /home/demo/conf.txt
```

When you create a configuration map from a file, the key name will be the name of the file by default and the value will be the contents of the file.

When you create a configuration map resource based on a directory, each file with a valid name key in the directory is stored in the configuration map. Subdirectories, symbolic links, device files, and pipes are ignored.

Run the kubectl create configmap --help command for more information.

<!-- FIXME -->

> **Note**:
>
> You can also abbreviate the configmap resource type argument as cm in the kubectl command-line interface. For example:
>
> ```bash
[user@host ~]$ kubectl create cm myconf --from-literal key1=value1
[user@host ~]$ kubectl get cm myconf
```

To create a new secret that stores the contents of a file or a directory containing a set of files:

```bash
[user@host ~]$ kubectl create secret generic secret_name \
--from-file /home/demo/mysecret.txt
```

When you create a secret from either a file or a directory, the key names are set the same way as configuration maps.

For more details, including storing TLS certificates and keys in secrets, run the kubectl create secret --help and the kubectl secret commands.

### Configuration Map and Secret Resource Definitions

Because configuration maps and secrets are regular Kubernetes resources, you can use either the kubectl create command to import these resource definition files in YAML or JSON format.

A sample configuration map resource definition in YAML format is shown below:

```yaml
apiVersion: v1
data:
    key1: value1 (1) (2)
    key2: value2 (3) (4)
kind: ConfigMap (5)
metadata:
    name: myconf (6)
```

1. The name of the first key. By default, an environment variable or a file the with same name as the key is injected into the container depending on whether the configuration map resource is injected as an environment variable or a file.

2. The value stored for the first key of the configuration map.

3. The name of the second key.

4. The value stored for the second key of the configuration map.

5. The Kubernetes resource type; in this case, a configuration map.

6. A unique name for this configuration map inside a project.

A sample secret resource in YAML format is shown below:

```yaml
apiVersion: v1
data:
    username: cm9vdAo= (1)(2)
    password: c2VjcmV0Cg== (3)(4)
kind: Secret (5)
metadata:
    name: mysecret (6)
    type: Opaque
```

1. The name of the first key. This provides the default name for either an environment variable or a file in a pod, just like the key names from a configuration map.

2. The value stored for the first key, in base64-encoded format.

3. The name of the second key.

4. The value stored for the second key, in base64-encoded format.

5. The Kubernetes resource type; in this case, a secret.

6. A unique name for this secret resource inside a project.

### Commands to Manipulate Configuration Maps

To view the details of a configuration map in JSON format, or to export a configuration map resource definition to a JSON file for offline creation:

```bash
[user@host ~]$ kubectl get configmap/myconf -o json
```

To delete a configuration map:

```bash
[user@host ~]$ kubectl delete configmap/myconf
```

To edit a configuration map, use the kubectl edit command. This command opens an inline editor, with the configuration map resource definition in YAML format:

```bash
[user@host ~]$ kubectl edit configmap/myconf
```

Use the kubectl patch command to edit a configuration map resource. This approach is non-interactive and is useful when you need to script the changes to a resource:

```bash
[user@host ~]$ kubectl patch configmap/myconf --patch '{"data":{"key1":"newvalue1"}}'
```

### Commands to Manipulate Secrets
The commands to manipulate secret resources are similar to those used for configuration map resources.

To view or export the details of a secret:

```bash
[user@host ~]$ kubectl get secret/mysecret -o json
```

To delete a secret:

```bash
[user@host ~]$ kubectl delete secret/mysecret
```

To edit a secret, first encode your data in base64 format, for example:

```bash
[user@host ~]$ echo 'newpassword' | base64
bmV3cGFzc3dvcmQK
```

Use the encoded value to update the secret resource using the kubectl edit command:

```bash
[user@host ~]$ kubectl edit secret/mysecret
```

You can also edit a secret resource using the kubectl patch command:

```bash
[user@host ~]$ kubectl patch secret/mysecret --patch \
'{"data":{"password":"bmV3cGFzc3dvcmQK"}}'
```

## Injecting Data from Secrets and Configuration Maps into Applications

Configuration maps and secrets can be mounted as data volumes, or exposed as environment variables, inside an application container.

To inject all values stored in a configuration map into environment variables for pods created from a deployment use the kubectl set env command:

```bash
[user@host ~]$ kubectl set env deployment/mydcname \
--from configmap/myconf
```

To mount all keys from a configuration map as files from a volume inside pods created from a deployment, use the kubectl set volume command:

```bash
[user@host ~]$ kubectl set volume deployment/mydcname --add \
-t configmap -m /path/to/mount/volume \
--name myvol --configmap-name myconf
```

To inject data inside a secret into pods created from a deployment, use the kubectl set env command:

```bash
[user@host ~]$ kubectl set env deployment/mydcname \
--from secret/mysecret
```

To mount data from a secret resource as a volume inside pods created from a deployment, use the kubectl set volume command:

```bash
[user@host ~]$ kubectl set volume deployment/mydcname --add \
-t secret -m /path/to/mount/volume \
--name myvol --secret-name mysecret
```

## Application Configuration Options

Use configuration maps to store configuration data in plain text and if the information is not sensitive. Use secrets if the information you are storing is sensitive.

If your application only has a few simple configuration variables that can be read from environment variables or passed on the command line, then use environment variables to inject data from configuration maps and secrets. Environment variables are the preferred approach over mounting volumes inside the container.

However, if your application has a large number of configuration variables, or if you are migrating a legacy application that makes extensive use of configuration files, then use the volume mount approach instead of creating an environment variable for each of the configuration variables. For example, if your application expects one or more configuration files from a specific location on your file system, then you should create secrets or configuration maps from the configuration files and mount them inside the container ephemeral file system at the location that the application expects.

For example, to create a secret pointing to the /home/student/configuration.properties file, use the following command:

```bash
[user@host ~]$ kubectl create secret generic security \
--from-file /home/student/configuration.properties
```

To inject the secret into the application, configure a volume that refers to the secret created in the previous command. The volume must point to an actual directory inside the application where the secret's file is stored.

In the following example, the configuration.properties file is stored in the /opt/app-root/secure directory. To bind the file to the application, configure the deployment configuration from the application:

```yaml
spec:
  template:
    spec:
      containers:
      - name: container
        image: repo.my/image-name
        volumeMounts:
          - mountPath: "/opt/app-root/secure"
            name: secure-volumen
            readOnly: true
      volumes:
        - name: secure-volumen
          secret:
            secretName: secret-name
```

To add the volume mount on a running application, you can use the kubectl patch command.

To create a configuration map, use the following command:

```bash
[user@host ~]$ kubectl create configmap properties \
--from-file /home/student/configuration.properties
```

To bind the application to the configuration map, update the deployment configuration from that application to use the configuration map:

```bash
[user@host ~]$ kubectl set env deployment/application \
--from configmap/properties
```
