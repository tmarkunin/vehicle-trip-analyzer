# vehicle-trip-analyzer
## Description
This endpoints gets a list of data points from a vehicle. the whole list represents a trip from one location to another with several stops to refuel or just to eat some cookies.

```
### Test
```bash
$ helm template . -x templates/deployment.yaml -f <CLUSTER>.yaml -n vehicle-trip-analyzer.<NAMESPACE> --namespace <NAMESPACE>
```

### Install
```bash
$ helm install --name vehicle-trip-analyzer . -f <CLUSTER>.yaml
$ helm install --name vehicle-trip-analyzer.<NAMESPACE> . -f <CLUSTER>.yaml --namespace <NAMESPACE>
```
### Upgrade
```bash
$ helm upgrade vehicle-trip-analyzer . -f <CLUSTER>.yaml
$ helm upgrade vehicle-trip-analyzer.<NAMESPACE> . --namespace <NAMESPACE> -f <CLUSTER>.yaml
```

### Delete
```bash
$ helm del --purge vehicle-trip-analyzer.<NAMESPACE>
```
### Readiness/liveness probes

* `initialDelaySeconds` is a delay before liveness probe is initiated
initialDelaySeconds: 30

* `periodSeconds` decides how often to perform the probe
periodSeconds: 10

* `timeoutSeconds` decides when the probe times out
timeoutSeconds: 3

* `successThreshold` is the minimum consecutive successes for the probe to be considered successful after having failed
successThreshold: 2

* `failureThreshold` is the minimum consecutive failures for the probe to be considered failed after having succeeded
failureThreshold: 5
