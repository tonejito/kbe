+++
description = ""
+++

<!-- https://kubebyexample.com/en/concept/jobs -->

# Jobs

A [job][job] in Kubernetes is a supervisor for pods that run for a certain time to completion, for example a calculation or a backup operation.

Let's create a [job named `countdown`][countdown] that supervises a pod counting from 9 down to 1:

```bash
$ kubectl apply -f https://github.com/openshift-evangelists/kbe/raw/main/specs/jobs/job.yaml
```

The job definition is listed under the resource type `job`:

```bash
$ kubectl get jobs
```

A job is executed as a pod.
Unlike most pods, however, the pod spawned by a job does not continue to run, but will instead reach a `Completed` state.
Below is an example output of the `kubectl get pods` command after a job has run.

```text
NAME              READY   STATUS      RESTARTS   AGE
countdown-dzrz8   0/1     Completed   0          55s
```

Further details of the job can be seen in the `describe` subcommand:

```text
Name:           countdown
Namespace:      default
Selector:       controller-uid=e5024398-6795-4583-8e74-431f57f54a3d
Labels:         controller-uid=e5024398-6795-4583-8e74-431f57f54a3d
                job-name=countdown
Annotations:    <none>
Parallelism:    1
Completions:    1
Start Time:     Sat, 05 Jun 2021 15:21:34 -0400
Completed At:   Sat, 05 Jun 2021 15:21:39 -0400
Duration:       5s
Pods Statuses:  0 Running / 1 Succeeded / 0 Failed
Pod Template:
  Labels:  controller-uid=e5024398-6795-4583-8e74-431f57f54a3d
           job-name=countdown
  Containers:
   counter:
    Image:      centos:7
    Port:       <none>
    Host Port:  <none>
    Command:
      bin/bash
      -c
      for i in 9 8 7 6 5 4 3 2 1 ; do echo $i ; done
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age    From            Message
  ----    ------            ----   ----            -------
  Normal  SuccessfulCreate  2m34s  job-controller  Created pod: countdown-dzrz8
  Normal  Completed         2m30s  job-controller  Job completed
```

Since the job ran as a pod, the logs subcommand will show any output during its execution (the name of the pod is included in the events list as seen above).

**Note**: You'll need to replace `${POD_NAME}` with the generated name of one of your pods.

```bash
$ kubectl logs ${POD_NAME}
```

To clean up, use the `delete` verb on the job object which will remove all the supervised pods:

```bash
$ kubectl delete job countdown
```

Note that there are also more advanced ways to use jobs, for example, by utilizing a [work queue][work-queue] or scheduling the execution at a certain time through [cron jobs][cron-jobs].

--------------------------------------------------------------------------------

[job]: https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/
[countdown]: https://github.com/openshift-evangelists/kbe/raw/main/specs/jobs/job.yaml
[work-queue]: https://kubernetes.io/docs/tasks/job/coarse-parallel-processing-work-queue/
[cron-jobs]: https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
