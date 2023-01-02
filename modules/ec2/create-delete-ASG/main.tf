
# Get yaml with configuration
locals {
  config  = yamldecode(file("${path.module}/yaml/${var.app_name}.yml"))
}

resource "aws_alb" "app_alb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = local.config[var.environment]["subnets"]

  tags = {
    Name = "${var.app_name}-alb"
  }
}

# Creating Security Group for ELB
resource "aws_security_group" "alb_sg" {
  name        = "${var.app_name}-alb-SG"
  description = "Security Group of the load balancer for ${var.app_name}"
  vpc_id      = "${local.config[var.environment]["vpc_id"]}"
# Inbound Rules
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = local.config[var.environment]["port"]
    to_port     = local.config[var.environment]["port"]
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating Security Group for ASG
resource "aws_security_group" "asg_sg" {
    name        = "${var.app_name}-SG"
    description = "Security Group of the ASG for ${var.app_name}-SG"
    vpc_id      = "${local.config[var.environment]["vpc_id"]}"
    # Inbound Rules
    # Prot access for the alb sg
    ingress {
        from_port   = local.config[var.environment]["port"]
        to_port     = local.config[var.environment]["port"]
        protocol    = "tcp"
        security_groups  = [aws_security_group.alb_sg.id]
    }
    # Outbound Rules
    # Internet access to anywhere
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Target group for the application
resource "aws_alb_target_group" "app_tg" {
  name       = "${var.app_name}-tg"
  port       = local.config[var.environment]["port"]
  protocol   = "HTTP"
  vpc_id     = local.config[var.environment]["vpc_id"]

  health_check {
    path                = "/"
    port                = local.config[var.environment]["port"]
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-499"
  }
}

# Listener for the laod balancer
resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.app_alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app_tg.id
    type             = "forward"
  }
}

# Launch template for the autoscaling group
resource "aws_launch_template" "app_lt" {
    name = "${var.app_name}-lt"

    block_device_mappings {
        device_name = "/dev/xvda"

        ebs {
            volume_type = "gp2"
            volume_size = local.config[var.environment]["volume_size"]
        }
    }
    key_name = local.config[var.environment]["key_name"]
    image_id = local.config[var.environment]["ami"]
    instance_initiated_shutdown_behavior = "terminate"
    instance_type = local.config[var.environment]["inst_type"]

    network_interfaces {
        associate_public_ip_address = true
        security_groups = [aws_security_group.asg_sg.id]
        subnet_id = "subnet-0da6c4c03bd47d552"
    }

    tag_specifications {
        resource_type = "instance"

        tags = {
        Name = "${var.app_name}"
        }
    }

    user_data = filebase64("${path.module}/bash/${var.app_name}.sh")
}

# Autoscaling group of the application
resource "aws_autoscaling_group" "app_asg" {
    name = "${var.app_name}-asg"
    min_size             = local.config[var.environment]["min_size"]
    desired_capacity     = local.config[var.environment]["desired_capacity"]
    max_size             = local.config[var.environment]["max_size"]
  
    health_check_type    = "ELB"
    #target_group_arns = [aws_alb_target_group.app_tg.arn]
    launch_template{
        id = aws_launch_template.app_lt.id
    }
    metrics_granularity = "1Minute"
    vpc_zone_identifier  = local.config[var.environment]["subnets"]
    # Required to redeploy without an outage.
    lifecycle {
        create_before_destroy = true
    }
    tag {
        key                 = "${var.app_name}"
        value               = "web"
        propagate_at_launch = true
    }
}
