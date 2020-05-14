# Vehicle Trip Analyzer

## Task description
* Implement the specified REST Endpoint
* Protect the API with BasicAuth
* Use Docker to run your application
* Use one of the following languages: Go, Java, Python, C++
* Automate the infrastructure rollout
* Use an external service to determine the city name for depature and destination
* Upload your solution to a private GitHub repository
* Provide a link to the secured hosted instance of your solution
* Provide the following files together with your code:
```
    * Dockerfile
    * Build-Script
    * Deployment-Script
    * Kubernetes deployment YAML (if Kubernetes is used)
    * Infrastructure automation scripts
    * README.md with documentation how to deploy the infrastructure and the application
    * Authorize
```

## Up and running
### Deploy EKS using terraform
See configuration and modules examples to deploy EKS at `terraform` directory.

### Create docker image
```bash
$ cd docker
$ docker login
$ docker build -t cyberjohn00/vehicle-trip-analyzer:1.0.0 .
$ docker push cyberjohn00/vehicle-trip-analyzer:1.0.0
```
### Deploy application in your namespace
```bash
$ helm template . -x templates/deployment.yaml -f nonprod.yaml -n vehicle-trip-analyzer
$ helm install --name vehicle-trip-analyzer . -f nonprod.yaml
```
or upgrade
```bash
$ helm upgrade vehicle-trip-analyzer . -f nonprod.yaml
$ helm upgrade vehicle-trip-analyzer . -f nonprod.yaml --set env.PASSWORD=bar --set env.APIKEY=xxxx
```
### Test your application
```bash
$ curl -kv https://foo:bar@vta.paraselenae.com/
$ curl -i -H "Content-Type: application/json" -X POST -d '{"vin":"WDD1671591Z000999","breakThreshold":"1800","gasTankSize":"80","data":[{"timestamp":"1559142001","odometer":"7200","fuelLevel":52,"positionLat":"48.771990","positionLong":"12.172787"},{"timestamp":"1559137025","odometer":"7200","fuelLevel":52,"positionLat":"48.771990","positionLong":"12.172787"},{"timestamp":"1559137024","odometer":"7200","fuelLevel":2,"positionLat":"49.771990","positionLong":"11.172787"},{"timestamp":"1559137023","odometer":"7200","fuelLevel":2,"positionLat":"49.771990","positionLong":"11.172787"},{"timestamp":"1559137022","odometer":"7200","fuelLevel":15,"positionLat":"50.771990","positionLong":"10.172787"},{"timestamp":"1559137020","odometer":"7200","fuelLevel":20,"positionLat":"50.771990","positionLong":"9.172787"},{"timestamp":"1559137019","odometer":"7200","fuelLevel":52,"positionLat":"52.520008","positionLong":"13.404954"}]}' https://foo:bar@vta.paraselenae.com/trip
```
### Install jenkins and run job
```bash
PROJECT_NAME=jenkins CLUSTER=nonprod NAMESPACE=default RELEASE=jenkins TEMPLATE=nonprod.yaml.j2 JENKINS_ADMIN_PASSWORD=xxx GITLAB_API_TOKEN=xxx sh -x files/jobs/rollout.sh
```
After jenkins is installer you can login as admin and run job -> rolloutProject
