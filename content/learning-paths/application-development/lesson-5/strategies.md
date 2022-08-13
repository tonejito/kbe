+++
description = ""
+++

<!-- https://kubebyexample.com/en/learning-paths/application-development-kubernetes/lesson-5-implementing-cloud-deployment-strategies -->

# Implementing Cloud Deployment Strategies

## Deployment Strategies in Kubernetes

A deployment strategy is a method of changing or upgrading an application. The objective is to make changes or upgrades with minimal downtime and with reduced impact on end users.

Kubernetes provides several deployment strategies. These strategies are organized into two primary categories:

- By using the deployment strategy defined in the application deployment.

- By using the Kubernetes router to route traffic to specific application pods.

Strategies defined within the deployment impact all routes that use the application. Strategies that use router features affect individual routes.

The following are strategies that are defined in the application deployment:

**Rolling**
: The rolling strategy is the default strategy.

This strategy progressively replaces instances of the previous version of an application with instances of the new version of the application. It uses the configured readiness probe to determine when the new pod is ready. After the probe for the new pod succeeds, the deployment controller terminates an old pod.

If a significant issue occurs, the deployment controller aborts the rolling deployment.

Rolling deployments are a type of canary deployment. By using the readiness probe, Kubernetes tests a new version before replacing all of the old instances. If the readiness probe never succeeds, then Kubernetes removes the canary instance and rolls back the deployment.

Use a rolling deployment strategy when:

- You require no downtime during an application update.

- Your application supports running an older version and a newer version at the same time.

**Recreate**
: With this strategy, Kubernetes first stops all pods running the application and then creates pods with the new version. This strategy creates down time because there is a time period with no running instances of your application.

Use a recreate deployment strategy when:

- Your application does not support running multiple different versions simultaneously.

- Your application uses a persistent volume with ReadWriteOnce (RWO) access mode, which does not allow writes from multiple pods.

You can configure the strategy in the Deployment object, for example by using the YAML manifest file:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: hello
  name: hello
spec:
  replicas: 4
  selector:
    matchLabels:
      app: hello
  strategy:
    type: RollingUpdate(1)rollingUpdate:(2)maxSurge: 50%(3)maxUnavailable: 10%(4)
  template:
    metadata:
      labels:
        app: hello
    spec:
      containers:
      - image: quay.io/redhattraining/versioned-hello:v1.1
        name: versioned-hello
```

1. Defining the RollingUpdate strategy for the hello deployment.

2. The RollingUpdate strategy accepts the rollingUpdate object to configure further strategy parameters.

3. The maxSurge parameter sets the maximum number of pods that can be scheduled above the desired number of pods. This deployment configures 4 pods. Consequently, 2 new pods can be created at a time.

4. The maxUnavailable parameter sets the maximum number of pods that can be unavailable during the update. Kubernetes calculates the absolute number from the configured percentage by rounding down. Consequently, maxUnavailable is set to 0 with the current deployment parameters.

Use the kubectl describe command to view the details of a deployment strategy:

```bash
[user@host ~] kubectl describe deploy/hello
...output omitted...
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  10% max unavailable, 50% max surge
...output omitted...
```

## Implementing Advanced Deployment Strategies Using the Kubernetes Router

The following are advanced deployment strategies that use the Kubernetes router:

**Blue-green Deployment**
: With blue-green deployments, two identical environments run concurrently. Each environment is labeled either blue or green and runs a different version of the application.

For example, the Kubernetes router is used to direct traffic from the current version labeled green to the newer version labeled blue. During the next update, the current version is labeled blue and the new version is labeled green.

At any given point, the exposed route points to one of the services and can be swapped to point to a different service This allows you to test the new version of your application service before routing traffic to it. When your new application version is ready, simply swap the router to point to the updated service.

**A/B Deployment**
: The A/B deployment strategy allows you to deploy a new version of the application for a limited set of users. You can configure Kubernetes to route a percentage of requests between two different deployed versions of an application.

By controlling the portion of requests sent to each version, you can gradually increase the traffic sent to the new version. Once the new version receives all traffic, the old version is removed.
