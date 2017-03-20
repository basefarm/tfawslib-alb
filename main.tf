#ALB
#variable "" { default="" type = "string" }
variable "costcenter" { type="string" }
variable "nameprefix" { type="string" }
variable "vpc" { type = "string" }
variable "lb_security_groups" { type = "list" }
variable "lb_subnets" { type = "list" }
variable "target_port" { default = "80" type = "string" }
variable "cert" { default="" type = "string" }
