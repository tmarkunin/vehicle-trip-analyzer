variable "env" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type        = string
}

variable "worker_groups" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Configurations."
  type        = any
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "cluster_enabled_log_types" {
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
}
variable "cluster_log_kms_key_id" {
  default     = ""
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
}
variable "cluster_log_retention_in_days" {
  default     = 90
  description = "Number of days to retain log events. Default retention - 90 days."
  type        = number
}


variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
  default     = "1.14"
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
}

variable "worker_additional_security_group_ids" {
  description = "A list of additional security group ids to attach to worker instances"
  type        = list(string)
  default     = []
}

variable "cluster_create_timeout" {
  description = "Timeout value when creating the EKS cluster."
  type        = string
  default     = "15m"
}

variable "cluster_delete_timeout" {
  description = "Timeout value when deleting the EKS cluster."
  type        = string
  default     = "15m"
}


variable "iam_path" {
  description = "If provided, all IAM roles will be created on this path."
  type        = string
  default     = "/"
}

variable "cluster_role_name" {
  description = "EKS Cluster IAM Role name"
  type        = string
  default     = ""
}

variable "worker_role_name" {
  description = "EKS Worker IAM Role name"
  type        = string
  default     = ""
}

variable "cluster_sg_name" {
  description = "EKS Cluster security group name"
  type        = string
  default     = ""
}

variable "worker_sg_name" {
  description = "EKS Worker security group name"
  type        = string
  default     = ""
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "worker_ami_name_filter" {
  description = "Additional name filter for AWS EKS worker AMI. Default behaviour will get latest for the cluster_version but could be set to a release from amazon-eks-ami, e.g. \"v20190220\""
  type        = string
  default     = "v*"
}

variable "region" {
  type        = string
  description = "Region to deploy to"
}

variable "workers_additional_policies" {
  description = "Additional policies to be added to workers"
  type        = list(string)
  default     = []
}

variable "istio_version" {
  type        = string
  description = "Istio version"
  default     = "1.4.2"
}

variable "enable_istio" {
  type        = bool
  description = "Enabled istio charts deployment"
  default     = true
}

variable "enable_efs" {
  type        = bool
  description = "Use efs with EKS. Deploy chart for provisioner"
  default     = false
}

variable "efs_sg" {
  type        = string
  default     = ""
  description = "EFS security group to add rule to"
}

variable "efs_id" {
  type        = string
  default     = ""
  description = "EFS ID"
}

variable "enable_elasticsearch-fluentd" {
  type        = bool
  description = "Use elasticsearch-fluentd to stream logs to Elasticsearch"
  default     = false
}

variable "elasticsearch_host" {
  type        = string
  description = "Elasticsearch host for logs"
  default     = ""
}

variable "es_sg" {
  type        = string
  description = "ES security group to add rule to"
  default     = ""
}

# KUBE2IAM

variable "enable_kube2iam" {
  type        = bool
  description = "Enabled kube2iam charts deployment"
  default     = false
}

variable "path_to_values_kube2iam" {
  type        = string
  description = "Path to vales.yaml file"
  default     = null
}

# EXTERNAL DNS

variable "enable_external_dns" {
  type        = bool
  description = "Enabled external dns charts deployment"
  default     = false
}

variable "path_to_values_external_dns" {
  type        = string
  description = "Path to vales.yaml file"
  default     = null
}

# EXTERNAL DNS

variable "enable_kubernetes_dashboard" {
  type        = bool
  description = "Enabled external kubernetes dashboard charts deployment"
  default     = false
}

variable "path_to_values_kubernetes_dashboard" {
  type        = string
  description = "Path to vales.yaml file"
  default     = null
}

## CUSTOM HELM

variable "custom_name" {
  type        = list
  description = "List of names"
  default     = []
}

variable "custom_namespace" {
  type        = list
  description = "List of namespaces"
  default     = []
}

variable "custom_chart" {
  type        = list
  description = "List of charts"
  default     = []
}

variable "custom_path" {
  type        = list
  description = "List of paths"
  default     = []
}

## SPOT INSTANCES

variable "enable_spot_instances" {
  type        = bool
  description = "Enable spot instances"
  default     = false
}

variable "additional_sgs" {
  type        = list(string)
  description = "Additional Security Groups"
  default     = []
}

variable "cni_configuration" {
  description = "list of environment variables to pass to aws vpc cni plugin"
  type        = map(string)
  default = {
    AWS_VPC_K8S_CNI_LOGLEVEL = "DEBUG"
  }
}
