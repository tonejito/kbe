+++
description = ""
+++

<!-- https://kubebyexample.com/en/learning-paths/application-development-kubernetes/lesson-3-networking-kubernetes/exposing-0 -->

# Exposing Applications for External Access

## Objectives

After completing this section, you should be able to expose service-backed applications to clients outside the Kubernetes cluster.

## Kubernetes Ingress

Kubernetes assigns IP addresses to pods and services. Pod and service IP addresses are not usually accessible outside of the cluster. Unless prevented by network policies, the Kubernetes cluster typically allows internal communication between pods and services. This internal communication allows application pods to interact with services that are not externally accessible, such as database services.

For a web application that should be accessible to external users,  you must create a Kubernetes ingress resource. An ingress maps a domain name, or potentially a URL, to an existing service. On its own, the ingress resource does not provide access to the specified host or path. The ingress resource interacts with a Kubernetes ingress controller to provide external access to a service over HTTP or HTTPS.

## Kubernetes Ingress Controller

Kubernetes ingress controllers act as load balancers for HTTP and HTTPS requests coming in to your cluster. Because ingress controllers can be specific to an environment, Kubernetes clusters are not configured to use an ingress controller by default.

As a developer, you cannot choose the ingress controller used by your environment you also cannot configure it.

Operations teams will install and configure an ingress controller appropriate to their environment. This includes configuring the ingress controller based on the networking characteristics of your environment. Most cloud providers and Kubernetes distributions implement their own ingress controllers, tailored for their products and network environments.

Local and self-managed Kubernetes distributions tend to use ingress controllers offered by open source projects, network vendors or sample ingress controllers provided by Kubernetes. Find a list of ingress controllers provided by upstream Kubernetes in the References section.

## Ingress Resource Configuration

One of the main things that you must specify in your ingress resource configuration is the host name used to access your application. This host name is part of the cluster configuration as it comes defined by factors external to the cluster, such as network characteristics and DNS services. The operations team must provide the cluster host name to developers.

Production deployments must have DNS records pointing to the Kubernetes cluster. Some Kubernetes distributions use wildcard DNS records to link a family of host names to the same Kubernetes cluster. A wildcard DNS record is a DNS record that, given a parent wildcard domain, maps all its subdomains to a single IP. For example, a wildcard DNS record might map the wildcard domain *.example.com to the IP 10.0.0.8. DNS requests for Subdomains such as hello.example.com or myapp.example.com will obtain 10.0.0.8 as a response.

Details for identifying the wildcard domain name used by your Kubernetes cluster can be found in the [Guided Exercise: Contrasting Kubernetes Distributions]().

The following is an example of an ingress resource.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello  <1>
spec:
  rules:
    - host: hello.example.com  <2>
      http:
        paths:
          - path: /  <3>
            pathType: Prefix  <4>
            backend:
              service:
                name: hello  <5>
                port:
                  number: 8080  <6>
```

1. The name of the ingress resource.

2. The host name used by external users to access your application.

3. This value is used in combination with pathType to determine if the URL request matches any of the accepted paths. A path value of / with the pathType value of Prefix is the equivalent of a wildcard that matches any path.

4. This value is used in combination with path to determine if the URL matches any of the accepted paths. A pathType of Prefix offers a bit more flexibility allowing for matches where the path and the requested URL can contain either a trailing / or not. A pathType of Exact requires the requested URL to exactly match the path value.

5. The name of the service to which requests are redirected.

6. The port number on which the service listens.

Testing Your Ingress
If you have an application already running in your Kubernetes cluster, then you can test the ingress resource by verifying the external access to the application. The test checks that the ingress resource successfully configures with the ingress controller to redirect the HTTP or HTTPS request.

After using either the kubectl create command or the kubectl apply command to create an ingress resource, use a web browser to access your application URL. Browse to the host name and the path defined in the ingress resource and verify that the request is forwarded to the application and the browser get the response:

![](https://kubebyexample.com/sites/default/files/2021-06/firefox-hello-world.png)

Image
Hello world from nginx screenshot
Optionally you can use the curl command to perform simple tests.

```bash
[user@host ~]$ curl hello.example.com
<html>
  <body>
      <h1>Hello, world from nginx!</h1>
  </body>
</html>
```

If the browser does not obtain the expected response then verify that:

- The host name and paths are the ones used in the ingress resource.

- Your system can translate the host name to the IP address for the ingress controller (via your hosts file or a DNS entry).

- The ingress resource is available and its information is correct.

- If applicable, verify that the ingress controller is installed and running in your cluster.

--------------------------------------------------------------------------------

## References

- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)

- [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
