# jenkins

### Install or upgrade
```bash
PROJECT_NAME=jenkins CLUSTER=nonprod NAMESPACE=default RELEASE=jenkins TEMPLATE=nonprod.yaml.j2 JENKINS_ADMIN_PASSWORD=xxx GITLAB_API_TOKEN=xxx sh -x files/jobs/rollout.sh
```

### Delete
```bash
$ helm del --purge vehicle-trip-analyzer.<NAMESPACE>
```
