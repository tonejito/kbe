+++
title = "API Server access"
subtitle = "Kubernetes API Server access by example"
date = "2019-03-23"
url = "/api/"
+++

Sometimes it's useful or necessary to directly [access the Kubernetes API server](https://kubernetes.io/docs/tasks/access-kubernetes-api/http-proxy-access-api/), for exploratory or testing purposes.

In order to do this, one option is to proxy the API to your local environment, using:

```bash
kubectl proxy --port=8080
```
```cat
Starting to serve on 127.0.0.1:8080

```

Now you can query the API (in a separate terminal session) like so:

```bash
curl http://localhost:8080/api/v1
```
```cat
{
  "kind": "APIResourceList",
  "groupVersion": "v1",
  "resources": [
    {
...
    {
      "name": "services/status",
      "singularName": "",
      "namespaced": true,
      "kind": "Service",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    }
  ]
}
```

Alternatively, without proxying, you can use `kubectl` directly as follows to achieve the same:

```bash
kubectl get --raw /api/v1
```

Further, if you want to explore the supported API versions and/or resources, you can use the following commands:

```bash
kubectl api-versions
```
```cat
admissionregistration.k8s.io/v1beta1
...
v1
```
```bash
kubectl api-resources
```
```cat
NAME                                  SHORTNAMES       APIGROUP         NAMESPACED   KIND
bindings         true         Binding
componentstatuses                     cs         false        ComponentStatus
configmaps                            cm         true         ConfigMap
...
```

[Previous](../nodes)
