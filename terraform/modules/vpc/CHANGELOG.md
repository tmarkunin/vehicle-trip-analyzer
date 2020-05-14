## 2.22.0
- feature: Added possibility to order the additional public and private subnets during creation

## 2.21.0
- fix: switched to NAT GW per AZ instead of subnet and corrected of resource naming related to standalone NATs 

## 2.19.0
- feature: ACOUSDG2-1338. Added an option to deploy separate set of nat gateways for required subnet set. 
Split NAT gateways per subnet type. From this version a special
 resource tag `"StandaloneNat"` is added to all subnets, even then already deployed.

## 2.3.0
- enhancement: provided a mechanism to create additional public subents


## 0.2.15
- fix: corrected an order of merge of resources tags to get a required value of tag `Name`


## 0.2.6
- enhancement: amount of all types subnets in the VPC was provided to outputs


## 0.2.0
- feature: added a way to add new subnets by type 


## 0.1.3
- enhancement: `terraform fmt`
- enhancement: corrected a counting, az choosing and naming of subents 


## 0.1.0
NOTES:

Module was added