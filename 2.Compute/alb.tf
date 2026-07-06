# Public facing ALB
resource "aws_lb" "external_alb" {
  name               = "andrew-prod-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.network.outputs.alb_sg_id]
  subnets            = data.terraform_remote_state.network.outputs.public_subnet_ids

  drop_invalid_header_fields = true 
  enable_deletion_protection = false

  tags = { Name = "andrew-prod-web-alb" }
}

# Target Group 
resource "aws_lb_target_group" "app_tg" {
  name        = "andrew-prod-app-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = { Name = "andrew-prod-app-tg" }
}

# ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
