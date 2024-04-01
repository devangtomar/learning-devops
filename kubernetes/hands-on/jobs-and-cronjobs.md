# Job, Cronjob

## Job object

- "A Job creates one or more Pods and will continue to retry execution of the Pods until a specified number of them successfully terminate". If the container is not successfully completed, it will recreated again.
- "When a specified number of successful completions is reached, the task (ie, Job) is complete."
- After finishing a job, pods are not deleted. Logs in the pods can be viewed.
- Job is used for the task that runs once (e.g. maintanence scripts, scripts that are used for creating DB)
- Job is also used for processing tasks that are stored in queue or bucket.


For creating it in short.. : `kubectl create job my-job --dry-run=client -o yaml --image=busybox;`

```yml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  parallelism: 2 # each step how many pods start in parallel at a time
  completions: 10 # number of pods that run and complete job at the end of the time
  backoffLimit: 5 # to tolerate fail number of job, after 5 times of failure, not try to continue job, fail the job
  activeDeadlineSeconds: 100 # if this job is not completed in 100 seconds, fail the job
  template:
    spec:
      containers:
        - name: pi
          image: perl # image is perl from docker
          command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"] # it calculates the first 2000 digits of pi number
      restartPolicy: Never
```


## Cronjobs

For creating it in short.. : `kubectl create cronjob my-cron --image=nginx --dry-run=client -o yaml --schedule='0 * * * *'`