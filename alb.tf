resource "aws_alb" "alb" {
    tags {
        CostCenter = "${var.costcenter}"
        name            = "${var.nameprefix}"
    }
    internal        = false
    security_groups = ["${var.lb_security_groups}","${aws_security_group.alb.id}"]
    subnets         = ["${var.lb_subnets}"]
    enable_deletion_protection = false
}
resource "aws_security_group" "alb" {
    tags {
        CostCenter = "${var.costcenter}"
        name            = "${var.nameprefix}"
    }
    vpc_id = "${var.vpc}"
}
resource "aws_security_group_rule" "alb_egress_01" {
  security_group_id = "${aws_security_group.alb.id}"
  type            = "egress"
  from_port       = "${var.target_port}"
  to_port         = "${var.target_port}"
  protocol        = "tcp"
  source_security_group_id = "${aws_security_group.alb.id}"
}
resource "aws_security_group_rule" "alb_ingress_01" {
  security_group_id = "${aws_security_group.alb.id}"
  type            = "ingress"
  from_port       = "${var.target_port}"
  to_port         = "${var.target_port}"
  protocol        = "tcp"
  source_security_group_id = "${aws_security_group.alb.id}"
}
resource "aws_alb_target_group" "alb" {
    name     = "${var.nameprefix}-alb-tg"
    port     = "${var.target_port}"
    protocol = "HTTP"
    vpc_id   = "${var.vpc}"
    health_check {
        interval = "10"
        healthy_threshold = "3"
        matcher = "200-399"
    }
}
resource "aws_alb_listener" "alb" {

   load_balancer_arn = "${aws_alb.alb.arn}"
   port = "80"
   protocol = "HTTP"
   default_action {
     target_group_arn = "${aws_alb_target_group.alb.arn}"
     type = "forward"
   }
}
resource "aws_alb_listener" "ssl-alb" {
   load_balancer_arn = "${aws_alb.alb.arn}"
   port = "443"
   protocol = "HTTPS"
   certificate_arn = "${var.cert}"
   default_action {
     target_group_arn = "${aws_alb_target_group.alb.arn}"
     type = "forward"
   }
}
output "target_sg" { value = "${aws_security_group.alb.id}" }
output "target_group" { value = "${aws_alb_target_group.alb.id}" }
