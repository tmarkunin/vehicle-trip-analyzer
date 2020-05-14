# Naming convention module.
## For tags propagation and generation id by predefined pattern

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional\_tags | Additional tags for appending to each tag map. | map(string) | `{}` | no |
| allowed\_chars\_regex | Allowed chars. By default only letters, digits and hyphens are allowed, all other chars will be removed. | string | `"/[^a-zA-Z0-9-]/"` | no |
| application\_name | Application name & Build Version | string | `""` | no |
| attribute | Additional attribute | string | `""` | no |
| context | Context for passing between modules. | object | `{ "additional_tag_map": [ {} ], "allowed_chars_regex": "", "application_name": "", "attribute": "", "customer": "", "delimiter": "", "enabled": true, "environment": "", "inspector_target": "", "instance_name": "", "label_order": [], "owner": "", "product_name": "", "resource_name": "", "root_domain": "", "security_domain": "", "sub_domain": "", "tags": [ {} ] }` | no |
| create\_hostname | \(Optional\) Whether to generate a hostname | bool | `"false"` | no |
| customer | \(Optional\) Customer name | string | `""` | no |
| delimiter | Delimiter to be used between naming parts. | string | `"-"` | no |
| enabled | \(Optional\) Set to false to prevent the module from creating any resources. | bool | `"true"` | no |
| environment | \(Required\) Environment name \("dev", "qa", "prod", etc\). Used for billing | string | `""` | no |
| inspector\_target | \(Required\) Tag for AWS Inspector service \(see Security section\) | string | `"ALL"` | no |
| instance\_name | The name of the instance of the product: qa1, devint7, mybranch4. Used for automation | string | `""` | no |
| label\_order | The order of labels by naming convention | list(string) | `[]` | no |
| owner | \(Required\) Owner. Individual: e.g. DBA Lead name, Product Arch/Lead name or Team / Business Unit | string | `""` | no |
| placeholder | \(Optional\) Placeholder | string | `"[:PLACEHOLDER:]"` | no |
| product\_name | \(Required\) Product name. Used for billing and automation. | string | `""` | no |
| product\_name\_short | Shortening version of product name | map(string) | `{}` | no |
| region | \(Optional\) AWS region to use. | string | `""` | no |
| region\_short | \(Optional\) Shortening version of aws region | map(string) | `{ "ap-south-1": "as1", "ap-southeast-1": "ase1", "ap-southeast-2": "ase2", "ca-central-1": "cc1", "eu-central-1": "ec1", "eu-west-1": "ew1", "us-east-1": "ue1", "us-east-2": "ue2", "us-west-1": "uw1", "us-west-2": "uw2" }` | no |
| resource\_name | \(Optional\) AWS Resource name, e.g. "ec2" or "vpc" | string | `""` | no |
| root\_domain | \(Optional\) Domain root 'awsnp' for non-prod. Domain root 'awspr' for prod | string | `"awsnp"` | no |
| security\_domain | \(Optional\) Identifier for compliance \(HIPAA, etc\) | string | `""` | no |
| sub\_domain | \(Optional\) Subdomain. By default it is an id of current AWS account | string | `""` | no |
| tags | General tags | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| application\_name |  |
| attribute |  |
| context | Context of current module to pass to child naming modules. |
| customer |  |
| environment | Normalized environment name. |
| hostname |  |
| id | Normalized id by naming convention |
| inspector\_target |  |
| instance\_name |  |
| owner |  |
| placeholder |  |
| product\_name |  |
| resource\_name |  |
| security\_domain |  |
| tags | Normalized tag map |
| tags\_as\_list\_of\_map | Tag as list of maps include additioal tags map. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->