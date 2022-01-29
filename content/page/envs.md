+++
title = "Environment Variables"
subtitle = "Kubernetes environment variables by example"
date = "2019-02-27"
url = "/envs/"
+++

You can set environment variables for containers running in a pod and in addition, Kubernetes exposes certain runtime infos via environment variables
automatically.

Let's launch a [pod](https://github.com/openshift-evangelists/kbe/blob/main/specs/envs/pod.yaml)
that we pass an environment variable `SIMPLE_SERVICE_VERSION` with the value `1.0`:

```bash
kubectl apply -f https://raw.githubusercontent.com/openshift-evangelists/kbe/main/specs/envs/pod.yaml
```

Now, let's verify from within the cluster if the application running in the pod
has picked up the environment variable `SIMPLE_SERVICE_VERSION`:

```bash
kubectl exec envs -t -- curl -s 127.0.0.1:9876/info
```
```cat
{"host": "127.0.0.1:9876", "version": "1.0", "from": "127.0.0.1"}
```

And indeed it has picked up the user-provided environment variable since the default response would be `"version": "0.5.0"`.

You can check what environment variables Kubernetes itself provides automatically
(from within the cluster, using a dedicated endpoint that the [app](https://github.com/openshift-labs/simpleservice)
exposes):
```bash
kubectl exec envs -t -- curl -s 127.0.0.1:9876/env
```
```cat
{"version": "1.0", "env": "{'HOSTNAME': 'envs', 'DOCKER_REGISTRY_SERVICE_PORT': '5000', 'KUBERNETES_PORT_443_TCP_ADDR': '172.30.0.1', 'ROUTER_PORT_80_TCP_PROTO': 'tcp', 'KUBERNETES_PORT_53_UDP_PROTO': 'udp', 'ROUTER_SERVICE_HOST': '172.30.246.127', 'ROUTER_PORT_1936_TCP_PROTO': 'tcp', 'KUBERNETES_SERVICE_PORT_DNS': '53', 'DOCKER_REGISTRY_PORT_5000_TCP_PORT': '5000', 'PATH': '/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin', 'ROUTER_SERVICE_PORT_443_TCP': '443', 'KUBERNETES_PORT_53_TCP': 'tcp://172.30.0.1:53', 'KUBERNETES_SERVICE_PORT': '443', 'ROUTER_PORT_80_TCP_ADDR': '172.30.246.127', 'LANG': 'C.UTF-8', 'KUBERNETES_PORT_53_TCP_ADDR': '172.30.0.1', 'PYTHON_VERSION': '2.7.13', 'KUBERNETES_SERVICE_HOST': '172.30.0.1', 'PYTHON_PIP_VERSION': '9.0.1', 'DOCKER_REGISTRY_PORT_5000_TCP_PROTO': 'tcp', 'REFRESHED_AT': '2017-04-24T13:50', 'ROUTER_PORT_1936_TCP': 'tcp://172.30.246.127:1936', 'KUBERNETES_PORT_53_TCP_PROTO': 'tcp', 'KUBERNETES_PORT_53_TCP_PORT': '53', 'HOME': '/root', 'DOCKER_REGISTRY_SERVICE_HOST': '172.30.1.1', 'GPG_KEY': 'C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF', 'ROUTER_SERVICE_PORT_80_TCP': '80', 'ROUTER_PORT_443_TCP_ADDR': '172.30.246.127', 'ROUTER_PORT_1936_TCP_ADDR': '172.30.246.127', 'ROUTER_SERVICE_PORT': '80', 'ROUTER_PORT_443_TCP_PORT': '443', 'KUBERNETES_SERVICE_PORT_DNS_TCP': '53', 'KUBERNETES_PORT_53_UDP_ADDR': '172.30.0.1', 'KUBERNETES_PORT_53_UDP': 'udp://172.30.0.1:53', 'KUBERNETES_PORT': 'tcp://172.30.0.1:443', 'ROUTER_PORT_1936_TCP_PORT': '1936', 'ROUTER_PORT_80_TCP': 'tcp://172.30.246.127:80', 'KUBERNETES_SERVICE_PORT_HTTPS': '443', 'KUBERNETES_PORT_53_UDP_PORT': '53', 'ROUTER_PORT_80_TCP_PORT': '80', 'ROUTER_PORT': 'tcp://172.30.246.127:80', 'ROUTER_PORT_443_TCP': 'tcp://172.30.246.127:443', 'SIMPLE_SERVICE_VERSION': '1.0', 'ROUTER_PORT_443_TCP_PROTO': 'tcp', 'KUBERNETES_PORT_443_TCP': 'tcp://172.30.0.1:443', 'DOCKER_REGISTRY_PORT_5000_TCP': 'tcp://172.30.1.1:5000', 'DOCKER_REGISTRY_PORT': 'tcp://172.30.1.1:5000', 'KUBERNETES_PORT_443_TCP_PORT': '443', 'ROUTER_SERVICE_PORT_1936_TCP': '1936', 'DOCKER_REGISTRY_PORT_5000_TCP_ADDR': '172.30.1.1', 'DOCKER_REGISTRY_SERVICE_PORT_5000_TCP': '5000', 'KUBERNETES_PORT_443_TCP_PROTO': 'tcp'}"}
```

Alternatively, you can also use `kubectl exec` to display the environment variables within the container:

```bash
kubectl exec envs -- printenv
```
```cat
PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=envs
SIMPLE_SERVICE_VERSION=1.0
KUBERNETES_PORT_53_UDP_ADDR=172.30.0.1
KUBERNETES_PORT_53_TCP_PORT=53
ROUTER_PORT_443_TCP_PROTO=tcp
DOCKER_REGISTRY_PORT_5000_TCP_ADDR=172.30.1.1
KUBERNETES_SERVICE_PORT_DNS_TCP=53
ROUTER_PORT=tcp://172.30.246.127:80
...
```

Remove the `env` pod with:

```bash
kubectl delete pod/envs
```

In addition to the above examples, you can also use `secrets`, volumes, or the [downward API](https://kubernetes.io/docs/user-guide/downward-api/) to inject additional information into your container environments.

[Previous](../healthz) | [Next](../ns)
