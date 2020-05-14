## EKS

### Spot instances
Before using spot instances please read [this](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional\_sgs | Additional Security Groups | list(string) | `[]` | no |
| cluster\_create\_timeout | Timeout value when creating the EKS cluster. | string | `"15m"` | no |
| cluster\_delete\_timeout | Timeout value when deleting the EKS cluster. | string | `"15m"` | no |
| cluster\_enabled\_log\_types | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation \(https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html\) | list(string) | `[]` | no |
| cluster\_endpoint\_private\_access | Indicates whether or not the Amazon EKS private API server endpoint is enabled. | bool | `"false"` | no |
| cluster\_endpoint\_public\_access | Indicates whether or not the Amazon EKS public API server endpoint is enabled. | bool | `"true"` | no |
| cluster\_log\_kms\_key\_id | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy \(https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html\) | string | `""` | no |
| cluster\_log\_retention\_in\_days | Number of days to retain log events. Default retention - 90 days. | number | `"90"` | no |
| cluster\_name | Name of the EKS cluster. Also used as a prefix in names of related resources. | string | n/a | yes |
| cluster\_role\_name | EKS Cluster IAM Role name | string | `""` | no |
| cluster\_sg\_name | EKS Cluster security group name | string | `""` | no |
| cluster\_version | Kubernetes version to use for the EKS cluster. | string | `"1.14"` | no |
| cni\_configuration | list of environment variables to pass to aws vpc cni plugin | map(string) | `{ "AWS_VPC_K8S_CNI_LOGLEVEL": "DEBUG" }` | no |
| custom\_chart | List of charts | list | `[]` | no |
| custom\_name | List of names | list | `[]` | no |
| custom\_namespace | List of namespaces | list | `[]` | no |
| custom\_path | List of paths | list | `[]` | no |
| efs\_id | EFS ID | string | `""` | no |
| efs\_sg | EFS security group to add rule to | string | `""` | no |
| elasticsearch\_host | Elasticsearch host for logs | string | `""` | no |
| enable\_efs | Use efs with EKS. Deploy chart for provisioner | bool | `"false"` | no |
| enable\_elasticsearch-fluentd | Use elasticsearch-fluentd to stream logs to Elasticsearch | bool | `"false"` | no |
| enable\_external\_dns | Enabled external dns charts deployment | bool | `"false"` | no |
| enable\_istio | Enabled istio charts deployment | bool | `"true"` | no |
| enable\_kube2iam | Enabled kube2iam charts deployment | bool | `"false"` | no |
| enable\_kubernetes\_dashboard | Enabled external kubernetes dashboard charts deployment | bool | `"false"` | no |
| enable\_spot\_instances | Enable spot instances | bool | `"false"` | no |
| env | Environment name | string | n/a | yes |
| es\_sg | ES security group to add rule to | string | `""` | no |
| iam\_path | If provided, all IAM roles will be created on this path. | string | `"/"` | no |
| istio\_version | Istio version | string | `"1.4.2"` | no |
| map\_accounts | Additional AWS account numbers to add to the aws-auth configmap. See examples/basic/variables.tf for example format. | list(string) | `[]` | no |
| map\_roles | Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format. | object | `[]` | no |
| map\_users | Additional IAM users to add to the aws-auth configmap. See examples/basic/variables.tf for example format. | object | `[]` | no |
| path\_to\_values\_external\_dns | Path to vales.yaml file | string | `"null"` | no |
| path\_to\_values\_kube2iam | Path to vales.yaml file | string | `"null"` | no |
| path\_to\_values\_kubernetes\_dashboard | Path to vales.yaml file | string | `"null"` | no |
| region | Region to deploy to | string | n/a | yes |
| subnets | A list of subnets to place the EKS cluster and workers within. | list(string) | n/a | yes |
| tags | A map of tags to add to all resources. | map(string) | `{}` | no |
| vpc\_id | VPC where the cluster and workers will be deployed. | string | n/a | yes |
| worker\_additional\_security\_group\_ids | A list of additional security group ids to attach to worker instances | list(string) | `[]` | no |
| worker\_ami\_name\_filter | Additional name filter for AWS EKS worker AMI. Default behaviour will get latest for the cluster\_version but could be set to a release from amazon-eks-ami, e.g. "v20190220" | string | `"v*"` | no |
| worker\_groups | A list of maps defining worker group configurations to be defined using AWS Launch Configurations. | any | `[]` | no |
| worker\_role\_name | EKS Worker IAM Role name | string | `""` | no |
| worker\_sg\_name | EKS Worker security group name | string | `""` | no |
| workers\_additional\_policies | Additional policies to be added to workers | list(string) | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudwatch\_log\_group\_name | Name of cloudwatch log group created |
| cluster\_arn | The Amazon Resource Name \(ARN\) of the cluster. |
| cluster\_certificate\_authority\_data | Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster. |
| cluster\_endpoint | The endpoint for your EKS Kubernetes API. |
| cluster\_iam\_role\_arn | IAM role ARN of the EKS cluster. |
| cluster\_iam\_role\_name | IAM role name of the EKS cluster. |
| cluster\_id | The name/id of the EKS cluster. |
| cluster\_security\_group\_id | Security group ID attached to the EKS cluster. |
| cluster\_version | The Kubernetes server version for the EKS cluster. |
| worker\_iam\_instance\_profile\_arns | default IAM instance profile ARN for EKS worker groups |
| worker\_iam\_instance\_profile\_names | default IAM instance profile name for EKS worker groups |
| worker\_iam\_role\_arn | default IAM role ARN for EKS worker groups |
| worker\_iam\_role\_name | default IAM role name for EKS worker groups |
| worker\_security\_group\_id | Security group ID attached to the EKS workers. |
| workers\_asg\_arns | IDs of the autoscaling groups containing workers. |
| workers\_asg\_names | Names of the autoscaling groups containing workers. |
| workers\_default\_ami\_id | ID of the default worker group AMI |
| workers\_user\_data | User data of worker groups |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->