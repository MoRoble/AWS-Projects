#### ---- LoadBalance/main.tf

resource "aws_lb" "arday-lb" {
  name            = "arday-loadbalancer"
  subnets         = var.lb_pub_sn
  security_groups = var.lb_sg
  idle_timeout    = 400
}

resource "aws_lb_target_group" "arday-tg" {
  name     = "arday-lb-tg-${substr(uuid(), 0, 2)}"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  lifecycle {
    # use lifecycle to ignore name changes to avoid unstable deployment for our infrastructure
    ignore_changes = [name]
    # to avoid hunging up in destruction when listner changes,
    # if new target group is not complete yet, there's no where this listner to go, so use:
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.elb_healthy_threshold
    unhealthy_threshold = var.elb_unhealthy_threshold
    timeout             = var.elb_timeout
    interval            = var.elb_interval
  }
}

resource "aws_lb_listener" "arday-lb-listener" {
  load_balancer_arn = aws_lb.arday-lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.arday-tg.arn
  }
}