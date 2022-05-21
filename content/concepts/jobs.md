+++
description = "Kubernetes jobs are supervised pods that run only once"
+++

<!-- https://kubebyexample.com/en/concept/jobs -->

# Jobs

A [job][job] in Kubernetes is a supervisor for pods that run for a certain time to completion, for example a calculation or a backup operation.

Let's create a job named `countdown` that supervises a pod counting from 9 down to 1.

```bash
$ $ kubectl apply -f https://github.com/openshift-evangelists/kbe/raw/main/specs/jobs/job.yaml
job.batch/countdown created
```

The job definition is listed under the resource type `job`.


```bash
$ kubectl get jobs
NAME        COMPLETIONS   DURATION   AGE
countdown   1/1           1s         10s
```

A job is executed as a pod.
Unlike most pods, however, the pod spawned by a job does not continue to run, but will instead reach a `Completed` state.
Below is an example output of the `kubectl get pods` command after a job has run, the `-L` option displays a column with the value associated with the `job-name` label.


```bash
$ kubectl get pods -L job-name
NAME                 READY   STATUS      RESTARTS   AGE   JOB-NAME
countdown--1-s2h9r   0/1     Completed   0          20s   countdown
```

Further details of the job can be seen in the `describe` subcommand.

```bash
$ kubectl describe job countdown
Name:             countdown
Namespace:        default
Selector:         controller-uid=acad8b1e-a930-406f-8b75-6a5f92717936
Labels:           controller-uid=acad8b1e-a930-406f-8b75-6a5f92717936
                  job-name=countdown
Annotations:      <none>
Parallelism:      1
Completions:      1
Completion Mode:  NonIndexed
Start Time:       Fri, 20 May 2022 20:28:58 -0500
Completed At:     Fri, 20 May 2022 20:28:59 -0500
Duration:         1s
Pods Statuses:    0 Running / 1 Succeeded / 0 Failed
Pod Template:
  Labels:  controller-uid=acad8b1e-a930-406f-8b75-6a5f92717936
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
  Type    Reason            Age   From            Message
  ----    ------            ----  ----            -------
  Normal  SuccessfulCreate  90s   job-controller  Created pod: countdown--1-s2h9r
  Normal  Completed         89s   job-controller  Job completed
```

View the logs of the job, you can also consult the logs of the pod.

```bash
$ kubectl logs job countdown
9
8
7
6
5
4
3
2
1
```

To clean up, use the `delete` verb on the job object which will remove all the supervised pods.

```bash
$ kubectl delete job countdown
```

Note that there are also more advanced ways to use jobs, for example, by utilizing a [work queue][work-queue] or scheduling the execution at a certain time through [cron jobs][cron-jobs].

--------------------------------------------------------------------------------

[job]: https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/
[work-queue]: https://kubernetes.io/docs/tasks/job/coarse-parallel-processing-work-queue/
[cron-jobs]: https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
