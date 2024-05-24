############################### Target Group Creation ###################

resource "aws_lb_target_group" "alb-target-group" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}


############################## Listener Creation ###################################

resource "aws_lb_listener" "front_end_443" {
  load_balancer_arn = aws_lb.frontend-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn    = data.aws_acm_certificate.alb_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-group.arn
  }
depends_on = [aws_lb.frontend-alb, aws_lb_target_group.alb-target-group, aws_acm_certificate.certificate]
}

resource "aws_lb_listener" "front_end_80" {
  load_balancer_arn = aws_lb.frontend-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

################ Target group Association #######################

resource "aws_lb_target_group_attachment" "alb-target-group-attachment" {
  # covert a list of instance objects to a map with instance ID as the key, and an instance
  # object as the value.
  for_each = {
    for k, v in module.ec2_instance :
    k => v
  }

  target_group_arn = aws_lb_target_group.alb-target-group.arn
  target_id        = each.value.id
  port             = 80
}

########################## ALB Creation #########################################


resource "aws_lb" "frontend-alb" {
  name               = "frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-security-group.id]
  #count              = length(module.vpc.public_subnets)
  subnets            = [module.vpc.public_subnets[0],module.vpc.public_subnets[1],module.vpc.public_subnets[2]]
  enable_deletion_protection = false

  depends_on = [aws_security_group.alb-security-group]
}


###################### ALB Secuirty group ####################################


resource "aws_security_group" "alb-security-group" {
  name        = "alb-security-group"
  description = "Allow communication with the msk cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "http"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description = "Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}