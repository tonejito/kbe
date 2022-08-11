+++
description = ""
+++

<!-- https://kubebyexample.com/en/concept/environment-variables -->

# Environment Variables

You can set environment variables for containers running in a pod.
Additionally, Kubernetes automatically exposes certain runtime information via environment variables.

Let's launch a [pod][pod] that we pass an environment variable `SIMPLE_SERVICE_VERSION` with the value `1.0`:

```bash
$ kubectl apply -f https://github.com/openshift-evangelists/kbe/raw/main/specs/envs/pod.yaml
```

Now, let's verify from within the cluster if the application running in the pod has picked up the environment variable:

```bash
$ kubectl exec envs -t -- curl -s 127.0.0.1:9876/info
```

The output reflects the value that was set for the environment variable (the default, unless overridden by the variable, is `0.5.0`):

```json
{"host": "127.0.0.1:9876", "version": "1.0", "from": "127.0.0.1"}
```

You can check what environment variables Kubernetes itself provides automatically using a REST endpoint in the sample application:

```bash
$ kubectl exec envs -t -- curl -s 127.0.0.1:9876/env
```

Your results will vary slightly depending on you cluster configuration, but an example output is included below:

```json
{
  "version": "1.0",
  "env": "{
    'GPG_KEY': 'FBC59DD261FEBA08C40D6991B8E4DFA780EE0021',
    'HOSTNAME': 'envs',
    'HOME': '/root',
    'LANG': 'C.UTF-8',
    'PATH': '/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    'PYTHON_PIP_VERSION': '9.0.1',
    'PYTHON_VERSION': '2.7.13',
    'REFRESHED_AT': '2017-04-24T13:50',
    'DOCKER_REGISTRY_PORT': 'tcp://172.30.1.1:5000',
    'DOCKER_REGISTRY_PORT_5000_TCP': 'tcp://172.30.1.1:5000',
    'DOCKER_REGISTRY_PORT_5000_TCP_ADDR': '172.30.1.1',
    'DOCKER_REGISTRY_PORT_5000_TCP_PORT': '5000',
    'DOCKER_REGISTRY_PORT_5000_TCP_PROTO': 'tcp',
    'DOCKER_REGISTRY_SERVICE_HOST': '172.30.1.1',
    'DOCKER_REGISTRY_SERVICE_PORT': '5000',
    'DOCKER_REGISTRY_SERVICE_PORT_5000_TCP': '5000',
    'KUBERNETES_PORT': 'tcp://172.30.0.1:443',
    'KUBERNETES_PORT_53_UDP': 'udp://172.30.0.1:53',
    'KUBERNETES_PORT_53_UDP_ADDR': '172.30.0.1',
    'KUBERNETES_PORT_53_UDP_PORT': '53',
    'KUBERNETES_PORT_53_UDP_PROTO': 'udp',
    'KUBERNETES_PORT_53_TCP': 'tcp://172.30.0.1:53',
    'KUBERNETES_PORT_53_TCP_ADDR': '172.30.0.1',
    'KUBERNETES_PORT_53_TCP_PORT': '53',
    'KUBERNETES_PORT_53_TCP_PROTO': 'tcp',
    'KUBERNETES_PORT_443_TCP': 'tcp://172.30.0.1:443',
    'KUBERNETES_PORT_443_TCP_ADDR': '172.30.0.1',
    'KUBERNETES_PORT_443_TCP_PORT': '443',
    'KUBERNETES_PORT_443_TCP_PROTO': 'tcp',
    'KUBERNETES_SERVICE_HOST': '172.30.0.1',
    'KUBERNETES_SERVICE_PORT': '443',
    'KUBERNETES_SERVICE_PORT_DNS': '53',
    'KUBERNETES_SERVICE_PORT_DNS_TCP': '53',
    'KUBERNETES_SERVICE_PORT_HTTPS': '443',
    'ROUTER_PORT': 'tcp://172.30.246.127:80',
    'ROUTER_PORT_80_TCP': 'tcp://172.30.246.127:80',
    'ROUTER_PORT_80_TCP_ADDR': '172.30.246.127',
    'ROUTER_PORT_80_TCP_PORT': '80',
    'ROUTER_PORT_80_TCP_PROTO': 'tcp',
    'ROUTER_PORT_443_TCP': 'tcp://172.30.246.127:443',
    'ROUTER_PORT_443_TCP_ADDR': '172.30.246.127',
    'ROUTER_PORT_443_TCP_PORT': '443',
    'ROUTER_PORT_443_TCP_PROTO': 'tcp',
    'ROUTER_PORT_1936_TCP': 'tcp://172.30.246.127:1936',
    'ROUTER_PORT_1936_TCP_ADDR': '172.30.246.127',
    'ROUTER_PORT_1936_TCP_PORT': '1936',
    'ROUTER_PORT_1936_TCP_PROTO': 'tcp',
    'ROUTER_SERVICE_HOST': '172.30.246.127',
    'ROUTER_SERVICE_PORT': '80',
    'ROUTER_SERVICE_PORT_80_TCP': '80',
    'ROUTER_SERVICE_PORT_1936_TCP': '1936',
    'ROUTER_SERVICE_PORT_443_TCP': '443',
    'SIMPLE_SERVICE_VERSION': '1.0'
  }"
}
```

Alternatively, you can also use the exec subcommand to display the environment variables within the pod:

```bash
$ kubectl exec envs -- printenv
```

Remove the sample pod with:

```bash
$ kubectl delete pod/envs
```

In addition to the above examples, you can also use secrets, volumes, or the [downward API][downward-api] to inject additional information into your container environments.

--------------------------------------------------------------------------------

[pod]: https://github.com/openshift-evangelists/kbe/raw/main/specs/envs/pod.yaml
[downward-api]: https://kubernetes.io/docs/user-guide/downward-api
