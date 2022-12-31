
resource "aws_lb" "test" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = {
    Name = "${var.app_name}-alb"
  }
}

resource "aws_lb_target_group" "alg_tg" {
  name        = "${var.app_name}-tg"
  target_type = "alb"
  port        = 3000
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
}

resource "aws_autoscaling_group" "app_asg" {
  name = "${var.app_name}-asg"
  min_size             = 1
  desired_capacity     = 1
  max_size             = 2
  
  health_check_type    = "ELB"
  load_balancers = [
    "${aws_elb.web_elb.id}"
  ]
launch_configuration = "${aws_launch_configuration.web.name}"
enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
metrics_granularity = "1Minute"
vpc_zone_identifier  = [
    "${aws_subnet.demosubnet.id}",
    "${aws_subnet.demosubnet1.id}"
  ]
# Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }
tag {
    key                 = "var.app_name"
    value               = "web"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.app_asg.id
  lb_target_group_arn    = aws_lb_target_group.alg_tgc.arn
}