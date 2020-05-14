variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "public_subnets_additional" {
  description = "(Optional) A list of public subnets additional inside the VPC"
  type = map(object({
    subnets = list(string)
    tags    = map(string)
  }))
  default = {
    public = {
      subnets = []
      tags    = {}
    }
  }
}

variable "private_subnets" {
  description = "(Optional) A list of private subnets inside the VPC"
  type        = any
  default = {
    private = {
      subnets      = []
      standalone_nat = false
      tags         = {}
    }
    eks = {
      subnets      = []
      standalone_nat = false
      tags         = {}
    }
    msk = {
      subnets      = []
      standalone_nat = false
      tags         = {}
    }
    emr = {
      subnets      = []
      standalone_nat = false
      tags         = {}
    }
    es = {
      subnets      = []
      standalone_nat = false
      tags         = {}
    }
    storage = {
      subnets      = []
      standalone_nat = false
      tags         = {}
    }
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_endpoint_tags" {
  description = "Additional tags for the VPC Endpoints"
  type        = map(string)
  default     = {}
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = []
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "0.0.0.0/0"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

variable "enable_dhcp_options" {
  description = "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
  type        = bool
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

variable "dhcp_options_tags" {
  description = "Additional tags for the DHCP option set (requires enable_dhcp_options set to true)"
  type        = map(string)
  default     = {}
}

variable "secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
  type        = list(string)
  default     = []
}

variable "igw_tags" {
  description = "Additional tags for the internet gateway"
  type        = map(string)
  default     = {}
}

variable "public_subnet_suffix" {
  description = "Suffix to append to public subnets name"
  type        = string
  default     = "public"
}

variable "public_subnet_additional_suffix" {
  description = "Suffix to append to public subnets additional name"
  type        = string
  default     = "public"
}

variable "public_route_table_tags" {
  description = "Additional tags for the public route tables"
  type        = map(string)
  default     = {}
}

variable "public_route_table_additional_tags" {
  description = "Additional tags for the public route tables additional"
  type        = map(string)
  default     = {}
}

variable "private_subnet_suffix" {
  description = "Suffix to append to private subnets name"
  type        = string
  default     = "private"
}

variable "private_route_table_tags" {
  description = "Additional tags for the private route tables"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnet_additional_tags" {
  description = "Additional tags for the public subnets additional"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}


variable "nat_eip_tags" {
  description = "Additional tags for the NAT EIP"
  type        = map(string)
  default     = {}
}

variable "enable_s3_endpoint" {
  description = "Should be true if you want to provision an S3 endpoint to the VPC"
  type        = bool
  default     = false
}

variable "enable_apigw_endpoint" {
  description = "Should be true if you want to provision an api gateway endpoint to the VPC"
  type        = bool
  default     = false
}

variable "nat_gateway_tags" {
  description = "Additional tags for the NAT gateways"
  type        = map(string)
  default     = {}
}

variable "apigw_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for API GW  endpoint"
  type        = list(string)
  default     = []
}

variable "apigw_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for API GW endpoint. Only a single subnet within an AZ is supported. If omitted, private EKS subnets will be used."
  type        = list(string)
  default     = []
}

variable "apigw_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for API GW endpoint"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "create_vpc" {
  description = "Create VPC or deploy to existing one"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of existing VPC"
  type        = string
  default     = ""
}

variable "public_subnets_additional_own_rt" {
  description = "Use exist RT or create own for public subnets additional"
  type        = bool
  default     = false
}

variable "public_lex_order" {
  description = "Order the additionals public subnets during creation"
  type        = bool
  default     = true
}

variable "private_lex_order" {
  description = "Order the private subnets during creation"
  type        = bool
  default     = true
}

variable "order_prefex_regex" {
  description = "Regex for prefix contains serial number, which wiil be removed if *_lex_order=false"
  type        = string
  default     = "^z[[:digit:]]+_" #z01_my_subnet, z02_my_subnet, etc
}

variable "subnet_type_tag_name" {
  description = "(Optional) The name of special tag to add type of subnet"
  type        = string
  default     = "SubnetType"
}