## 2.14.0
- fix: dependence on `kubernetes_cluster_role_binding.tiller` was removed from the different resources
- fix: `repository` parameter was set for `metrics_server`
- enhancement: `terraform fmt`


## 2.9.1
- fix: added required IAM policy for ALB Ingress. Attached a policy to workers IAM role
- fix: switched to required version of amazon-k8s-cni image


## 2.8.0
- enhancement: added a way to pass required variables to the AWS vpc cni plugin
- fix: added required tags to workers `aws_autoscaling_group`
- fix: corrected a condition in the IAM policy for workers autoscaling

## 1.0.7
- fix: added a delay for autoscaler deploying 
- fix: corrected determination of cluster and workers sg names, its `Name` tags and the names of cluster and
workers AWS IAM roles. Added required naming variables.
- enhancement: added a way to attach additional security groups to the cluster

## 0.2.21
- fix: added a delay for creation of `aws_auth` config map
- fix: added required value to the `helm_release` of istio
- fix: added to the tiller's `kubernetes_service_account` a dependence on `aws_auth` config map


## 0.2.16
- fix: disabled sg rule that allowed egress access of cluster to internet
- fix: replaced determination of used tags for `aws_autoscaling_group` to getting them from related worker group
- enhancement: Fixed terraform 0.12 deprecation warnings

## 0.2.6
- feature: added a way to deploy `custom_helm` and enable of spot instances using

## 0.1.2
Notes:
- module was added