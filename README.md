# tfawslib-alb  
Terraform module implementing an Application Load-Balancer on AWS  
Designed to work together with the VPC module tfawslib-vpc  
  
## Required Inputs:  
+ variable "costcenter" { type="string" }  
+ variable "nameprefix" { type="string" }  
+ variable "vpc" { type = "string" }  
+ variable "lb_security_groups" { type = "list" } - List of security groups to associate with the ALB, both ingress and egress rules  
+ variable "lb_subnets" { type = "list" } - List of subnets to deploy the ALB in  
  
## Optional Inputs:  
+ variable "port" { default = "80" type = "string" }  
+ variable "sslport" { default = "443" type = "string" }  
+ variable "target_port" { default = "80" type = "string" }  
+ variable "cert" { default="" type = "string" } - If you don't supply a cert ARN, then there will not be a listener on the sslport  
+ variable "internal" { default="false" type = "string" }  
  
## Outputs:  
+ "target_sg" - Security group to assign to instances receiving traffic from ALB  
+ "target_group" - Target group to use when creating AutoScaling Groups or attaching instances/containers to  
+ "id" { value = "${aws_alb.alb.id}" } - ID of ALB  
+ "arn" { value = "${aws_alb.alb.arn}" } - ARN of ALB  
+ "dns_name" { value = "${aws_alb.alb.dns_name}" } - Hosted FQDN of ALB, use with zone_id when creating Route53 record  
+ "zone_id" { value = "${aws_alb.alb.zone_id}" } - Hosted Zone ID of ALB, use with dns_name when creating Route53 record  

## Example:  
(Assumes the usage of the VPC example or similar)  
```hcl
module "alb" {
    source = "git@github.com:basefarm/tfawslib-alb?ref=0.2"
    costcenter = "${var.costcenter}"
    nameprefix = "${var.nameprefix}"
    cert = "${var.labcert["${module.vpc.region}"]}"
    vpc = "${module.vpc.vpcid}"
    lb_security_groups = ["${module.vpc.secgroup_inbound_http_https}"]
    lb_subnets = "${module.vpc.dmznets}"
}

resource "aws_route53_record" "alb" {
    zone_id = "${var.awslab_route53_zoneid}"
    name = "${lower(var.nameprefix)}-${lower(var.costcenter)}.${data.aws_route53_zone.awslab.name}"
    type = "A"
    alias {
        name = "${module.alb.dns_name}"
        zone_id = "${module.alb.zone_id}"
        evaluate_target_health = true
    }
}

variable "awslab_route53_zoneid" { default="Z30QO3RA61PK3W" }
data "aws_route53_zone" "awslab" {
    zone_id = "${var.awslab_route53_zoneid}"
}
variable "labcert" {
    type = "map"
    default = {
        us-east-1 = "arn:aws:acm:us-east-1:552687213402:certificate/71db5f6c-b56b-4390-9112-6bd53a595179"
        us-west-1 = "arn:aws:acm:us-west-1:552687213402:certificate/7de30ca2-8cf0-460a-a87d-5535a0724b85"
        us-west-2 = "arn:aws:acm:us-west-2:552687213402:certificate/04f28e3c-916c-4b02-95a9-39e5e3eb5ada"
        eu-west-1 = "arn:aws:acm:eu-west-1:552687213402:certificate/5d014e75-7ee9-4946-9825-0c789b7afd04"
        eu-central-1 = "arn:aws:acm:eu-central-1:552687213402:certificate/7c769ba4-7761-4792-bae1-a0c91ed4fe5d"
    }
}
```