# VPC module

## How to apply fix altering subnets in vpc module 

1. Replace previous version of vpc-eks module to `2.7.5-vpc-eks-rework` version

    ```hcl
    source = "git@github.com:aipoweredmarketer/shared-terraform-modules.git//vpc-eks?ref=2.22.0"
    ```

2. Run `terraform init`, `terraform apply`

    In this step the new subnet type tag will be added to every used subnet.

3. Make required changes in the subnets: rename/add new to the end of subnets list/change cidr/remove unnecessary from the tail of the subnets list

    * If new type of public/private subnets will be added or subnet will be renamed then related parameters `private_lex_order`/`public_lex_order` must be set to `false` and special order prefix should be add to the type of subnet:
    
    For example, before this fix you have deployed something like:

    ```hcl
      private_subnets = {
        private = {
          subnets = ["10.119.12.0/22", "10.119.16.0/22"]
          tags    = module.base_naming.tags
        }
        
        eks = {
          subnets = ["10.119.74.0/24", "10.119.78.0/24"]
          tags    = module.base_naming.tags
        }
      }
    ```
   
   Then after update this part should be like:
   
   ```hcl
    private_subnets = {
        z001_private = {
          subnets = ["10.119.12.0/22", "10.119.16.0/22"]
          tags    = module.base_naming.tags
        }
    
        z000_eks = {
            subnets = ["10.119.74.0/24", "10.119.78.0/24"]
            tags    = module.base_naming.tags
        }
    }
   
    private_lex_order = false
    ```
    `z000`, `z001` - is a subnet order prefix to save initial order. By default terraform applying desc items order. The first - `eks`, the second - `private`
    
### Special attention!
  To remove subnet from the beginning or from the middle of subnets list, you need **manually edit the terraform state**. 
  To remove eks subnet from previous example of private subnets you need to remove eks subnet related items from the `instances` json arrays of 
  
  1) ```hcl
         "type": "aws_route_table_association",
         "name": "private",
     ```

  2) ```hcl
         "type": "aws_subnet",
         "name": "private",
     ```
   
or properly resort values of`"index_key"` elements.
    
## Public subnets additional example
### Parameters set up
```hcl
module "vpc_public_test" {
  source = "../../../terraform-modules/vpc-eks"

  cidr           = "10.119.0.0/16"
  public_subnets = ["10.119.0.0/22", "10.119.4.0/22", "10.119.8.0/22"]
  
  public_subnets_additional = {
    public = {
      subnets = ["10.119.12.0/22", "10.119.16.0/22", "10.119.20.0/22"]
      tags    = { "public_specific_tag" = "public_specific_value" }
    }
    public_more = {
      subnets = ["10.119.24.0/22", "10.119.28.0/22", "10.119.32.0/22"]
      tags    = { "other_specific_tag" = "other_specific_value" }
    }
  }
  
  name               = "acousdg2-vpc-rich-type-subn-test"
}
```
## Private subnets example
### Parameters set up
```hcl
module "vpc_eks_test" {
  source = "../../../terraform-modules/vpc-eks"

  cidr           = "10.119.0.0/16"
  public_subnets = ["10.119.0.0/22", "10.119.4.0/22", "10.119.8.0/22"]
  
  private_subnets = {
    private = {
      subnets = ["10.119.12.0/22", "10.119.16.0/22", "10.119.20.0/22"]
      tags    = { "private_specific_tag" = "private_specific_value" }
    }
    eks = {
      subnets = ["10.119.24.0/22", "10.119.28.0/22", "10.119.32.0/22"]
      standalone_nat = true
      tags    = { "eks_specific_tag" = "eks_specific_value" }
    }
  }
  
  name               = "acousdg2-vpc-rich-type-subn-test"
  single_nat_gateway = false
}
```

### Get subnets ids

```hcl
locals {
  private_subnets_ids    = module.vpc_eks_test.private_subnets_compound["private"][*]["ids"]
  eks_subnets_ids        = module.vpc_eks_test.private_subnets_compound["eks"][*]["ids"]
}
```

```hcl
Outputs:

eks_subnets_ids = [
  "subnet-050530ad0c44aa186",
  "subnet-024d88f2f57b333e2",
  "subnet-0f52e705baa01e3ea",
]
private_subnets_ids = [
  "subnet-02691f791e334d6dc",
  "subnet-0a6f0c6c2530d0c32",
  "subnet-00ba2cffb249eda34",
]
```

## Parameters
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK --> 
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| apigw\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for API GW endpoint | bool | `"false"` | no |
| apigw\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for API GW  endpoint | list(string) | `[]` | no |
| apigw\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for API GW endpoint. Only a single subnet within an AZ is supported. If omitted, private EKS subnets will be used. | list(string) | `[]` | no |
| azs | A list of availability zones in the region | list(string) | `[]` | no |
| cidr | The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden | string | `"0.0.0.0/0"` | no |
| create\_vpc | Create VPC or deploy to existing one | bool | `"true"` | no |
| dhcp\_options\_domain\_name | Specifies DNS name for DHCP options set \(requires enable\_dhcp\_options set to true\) | string | `""` | no |
| dhcp\_options\_domain\_name\_servers | Specify a list of DNS server addresses for DHCP options set, default to AWS provided \(requires enable\_dhcp\_options set to true\) | list(string) | `[ "AmazonProvidedDNS" ]` | no |
| dhcp\_options\_netbios\_name\_servers | Specify a list of netbios servers for DHCP options set \(requires enable\_dhcp\_options set to true\) | list(string) | `[]` | no |
| dhcp\_options\_netbios\_node\_type | Specify netbios node\_type for DHCP options set \(requires enable\_dhcp\_options set to true\) | string | `""` | no |
| dhcp\_options\_ntp\_servers | Specify a list of NTP servers for DHCP options set \(requires enable\_dhcp\_options set to true\) | list(string) | `[]` | no |
| dhcp\_options\_tags | Additional tags for the DHCP option set \(requires enable\_dhcp\_options set to true\) | map(string) | `{}` | no |
| enable\_apigw\_endpoint | Should be true if you want to provision an api gateway endpoint to the VPC | bool | `"false"` | no |
| enable\_dhcp\_options | Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type | bool | `"false"` | no |
| enable\_dns\_hostnames | Should be true to enable DNS hostnames in the VPC | bool | `"false"` | no |
| enable\_dns\_support | Should be true to enable DNS support in the VPC | bool | `"true"` | no |
| enable\_s3\_endpoint | Should be true if you want to provision an S3 endpoint to the VPC | bool | `"false"` | no |
| igw\_tags | Additional tags for the internet gateway | map(string) | `{}` | no |
| name | Name to be used on all the resources as identifier | string | `""` | no |
| nat\_eip\_tags | Additional tags for the NAT EIP | map(string) | `{}` | no |
| nat\_gateway\_tags | Additional tags for the NAT gateways | map(string) | `{}` | no |
| order\_prefex\_regex | Regex for prefix contains serial number, which wiil be removed if \*\_lex\_order=false | string | `"^z[[:digit:]]+_"` | no |
| private\_lex\_order | Order the private subnets during creation | bool | `"true"` | no |
| private\_route\_table\_tags | Additional tags for the private route tables | map(string) | `{}` | no |
| private\_subnet\_suffix | Suffix to append to private subnets name | string | `"private"` | no |
| private\_subnet\_tags | Additional tags for the private subnets | map(string) | `{}` | no |
| private\_subnets | \(Optional\) A list of private subnets inside the VPC | any | `{ "eks": [ { "standalone_nat": false, "subnets": [], "tags": [ {} ] } ], "emr": [ { "standalone_nat": false, "subnets": [], "tags": [ {} ] } ], "es": [ { "standalone_nat": false, "subnets": [], "tags": [ {} ] } ], "msk": [ { "standalone_nat": false, "subnets": [], "tags": [ {} ] } ], "private": [ { "standalone_nat": false, "subnets": [], "tags": [ {} ] } ], "storage": [ { "standalone_nat": false, "subnets": [], "tags": [ {} ] } ] }` | no |
| public\_lex\_order | Order the additionals public subnets during creation | bool | `"true"` | no |
| public\_route\_table\_additional\_tags | Additional tags for the public route tables additional | map(string) | `{}` | no |
| public\_route\_table\_tags | Additional tags for the public route tables | map(string) | `{}` | no |
| public\_subnet\_additional\_suffix | Suffix to append to public subnets additional name | string | `"public"` | no |
| public\_subnet\_additional\_tags | Additional tags for the public subnets additional | map(string) | `{}` | no |
| public\_subnet\_suffix | Suffix to append to public subnets name | string | `"public"` | no |
| public\_subnet\_tags | Additional tags for the public subnets | map(string) | `{}` | no |
| public\_subnets | A list of public subnets inside the VPC | list(string) | `[]` | no |
| public\_subnets\_additional | \(Optional\) A list of public subnets additional inside the VPC | object | `{ "public": [ { "subnets": [], "tags": [ {} ] } ] }` | no |
| public\_subnets\_additional\_own\_rt | Use exist RT or create own for public subnets additional | bool | `"false"` | no |
| secondary\_cidr\_blocks | List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool | list(string) | `[]` | no |
| single\_nat\_gateway | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | bool | `"false"` | no |
| subnet\_type\_tag\_name | \(Optional\) The name of special tag to add type of subnet | string | `"SubnetType"` | no |
| tags | A map of tags to add to all resources | map(string) | `{}` | no |
| vpc\_endpoint\_tags | Additional tags for the VPC Endpoints | map(string) | `{}` | no |
| vpc\_id | ID of existing VPC | string | `""` | no |
| vpc\_tags | Additional tags for the VPC | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| azs | A list of availability zones specified as argument to this module |
| default\_network\_acl\_id | The ID of the default network ACL |
| default\_route\_table\_id | The ID of the default route table |
| default\_security\_group\_id | The ID of the security group created by default on VPC creation |
| igw\_id | The ID of the Internet Gateway |
| name | The name of the VPC specified as argument to this module |
| nat\_ids | List of allocation ID of Elastic IPs created for AWS NAT Gateway |
| nat\_public\_ips | List of public Elastic IPs created for AWS NAT Gateway |
| natgw\_ids | List of NAT Gateway IDs |
| private\_route\_table\_ids | List of IDs of private route tables |
| private\_subnet\_arns | List of ARNs of ALL private subnets |
| private\_subnets | List of IDs of ALL private subnets |
| private\_subnets\_cidr\_blocks | List of cidr\_blocks of ALL private subnets |
| private\_subnets\_compound | Compound output of private subnets by private subnets types |
| public\_route\_table\_ids | List of IDs of public route tables |
| public\_route\_table\_ids\_additional | List of IDs of public route tables additional |
| public\_subnet\_arns | List of ARNs of public subnets |
| public\_subnets | List of IDs of public subnets |
| public\_subnets\_additional | List of IDs of ALL public subnets additional |
| public\_subnets\_additional\_arns | List of ARNs of ALL public subnets additional |
| public\_subnets\_additional\_cidr\_blocks | List of cidr\_blocks of ALL public subnets additional |
| public\_subnets\_cidr\_blocks | List of cidr\_blocks of public subnets |
| public\_subnets\_compound | Compound output of public subnets by public subnets types |
| subnets\_amount | Amount of all types subnets in this VPC |
| vpc\_arn | The ARN of the VPC |
| vpc\_cidr\_block | The CIDR block of the VPC |
| vpc\_enable\_dns\_hostnames | Whether or not the VPC has DNS hostname support |
| vpc\_enable\_dns\_support | Whether or not the VPC has DNS support |
| vpc\_endpoint\_apigw\_dns\_entry | The DNS entries for the VPC Endpoint for APIGW. |
| vpc\_endpoint\_apigw\_id | The ID of VPC endpoint for APIGW |
| vpc\_endpoint\_apigw\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for APIGW. |
| vpc\_endpoint\_s3\_id | The ID of VPC endpoint for S3 |
| vpc\_endpoint\_s3\_pl\_id | The prefix list for the S3 VPC endpoint. |
| vpc\_id | The ID of the VPC |
| vpc\_instance\_tenancy | Tenancy of instances spin up within VPC |
| vpc\_main\_route\_table\_id | The ID of the main route table associated with this VPC |
| vpc\_secondary\_cidr\_blocks | List of secondary CIDR blocks of the VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->