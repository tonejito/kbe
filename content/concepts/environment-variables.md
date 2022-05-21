+++
description = ""
+++

<!-- https://kubebyexample.com/en/concept/environment-variables -->

# Environment Variables

You can set environment variables for containers running in a pod.
Additionally, Kubernetes automatically exposes certain runtime information via environment variables.

Create a pod of the [simple service application][simple-service-app] using the container image on the `quay.io` registry.

```bash
$ kubectl run envs --image=quay.io/openshiftlabs/simpleservice:0.5.0 --port=9876

$ kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE
envs   1/1     Running   0          20s
```

View the environment variables defined in the pod.

```bash
$ kubectl describe pod envs | grep 'Environment:'
    Environment:    <none>
```

Access the application and display the service version.
The default value `0.5.0` is displayed.

```bash
$ kubectl exec -it pod/envs -- curl -s localhost:9876/info | jq .
{
  "host": "localhost:9876",
  "version": "0.5.0",  # <= The default version value is shown
  "from": "127.0.0.1"
}
```

Delete the pod that was created with the `kubectl run` command.

```bash
$ kubectl delete pod envs
pod "envs" deleted
```

Launch a new pod using a YAML resource manifest where the `SIMPLE_SERVICE_VERSION` environment variable is provided.
The [simple service application][simple-service-app] can override the **version** to the value specified in the `SIMPLE_SERVICE_VERSION` environment variable.

```bash
$ kubectl apply -f https://github.com/openshift-evangelists/kbe/raw/main/specs/envs/pod.yaml
```

Verify that the `envs` pod is running.

```bash
$ kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE
envs   1/1     Running   0          30s
```

Inspect the pod description to view the environment variables.

```bash
$ kubectl describe pod envs | grep -A 1 'Environment:'
    Environment:
      SIMPLE_SERVICE_VERSION:  1.0
```

<!--
```bash
$ kubectl get pod envs -o jsonpath='{.spec.containers[0].env}{"\n"}'
[{"name":"SIMPLE_SERVICE_VERSION","value":"1.0"}]
```
-->

Verify that the `version` value is overridden with the value from the environment variable.

```bash
$ kubectl exec -it pod/envs -- curl -s localhost:9876/info | jq .
{
  "host": "localhost:9876",
  "version": "1.0",  # <= The version value is overridden from the environment variable
  "from": "127.0.0.1"
}
```

You can check what environment variables Kubernetes itself provides automatically using a REST endpoint in the sample application.

```bash
$ kubectl exec -it envs -- curl -s 127.0.0.1:9876/env
```

Your results will vary slightly depending on you cluster configuration, but an example output is included below.

```json
{
  "version": "1.0",
  "env": "{
    'GPG_KEY': 'FBC59DD261FEBA08C40D6991B8E4DFA780EE0021',
    'HOSTNAME': 'envs',
    'LANG': 'C.UTF-8',
    'HOME': '/root',
    'PATH': '/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    'PYTHON_VERSION': '2.7.13',
    'PYTHON_PIP_VERSION': '9.0.1',
    'KUBERNETES_PORT': 'tcp://10.96.0.1:443',
    'KUBERNETES_PORT_443_TCP': 'tcp://10.96.0.1:443',
    'KUBERNETES_PORT_443_TCP_ADDR': '10.96.0.1',
    'KUBERNETES_PORT_443_TCP_PORT': '443',
    'KUBERNETES_PORT_443_TCP_PROTO': 'tcp',
    'KUBERNETES_SERVICE_HOST': '10.96.0.1',
    'KUBERNETES_SERVICE_PORT': '443',
    'KUBERNETES_SERVICE_PORT_HTTPS': '443',
    'REFRESHED_AT': '2017-04-24T13:50',
    'SIMPLE_SERVICE_VERSION': '1.0'
  }"
} 
```

<!--
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
-->

Alternatively, you can also use the `exec` subcommand to display the environment variables within the pod.

```bash
$ kubectl exec -it pod/envs -- printenv
GPG_KEY=FBC59DD261FEBA08C40D6991B8E4DFA780EE0021
HOSTNAME=envs
LANG=C.UTF-8
HOME=/root
PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
PYTHON_VERSION=2.7.13
PYTHON_PIP_VERSION=9.0.1
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_PORT_HTTPS=443
SIMPLE_SERVICE_VERSION=1.0
REFRESHED_AT=2017-04-24T13:50
TERM=xterm
```

Remove the pod to clean up the environment.

```bash
$ kubectl delete pod envs
```

In addition to the above examples, you can also use secrets, volumes, or the [downward API][downward-api] to inject additional information into your container environments.

--------------------------------------------------------------------------------

[downward-api]: https://kubernetes.io/docs/user-guide/downward-api/
[simple-service-app]: https://github.com/openshift-labs/simpleservice
[simple-service-container]: https://quay.io/repository/openshiftlabs/simpleservice
