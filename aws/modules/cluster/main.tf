#resource "aws_instance" "instances" {
resource "aws_launch_template" "template" {
  name = "${var.prefix}-template"
  #count                  = var.instance_count
  #ami                    = "ami-0d43f0bb92e485897"
  #subnet_id              = var.subnet_id
  image_id      = "ami-0d43f0bb92e485897"
  instance_type = "t3.micro"

  #vpc_security_group_ids = var.security_group_ids

  user_data = base64encode(var.user_data)

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_group_ids
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      #Name = "${var.prefix}-node-${count.index}"
      Name = "${var.prefix}-node"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.prefix}-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [aws_lb_target_group.app_lb_tg.arn]

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "${var.prefix}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.scale_in.scaling_adjustment
  cooldown               = var.scale_in.cooldown //default é 300
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_description   = "Monitors CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_in_policy.arn]
  alarm_name          = "${var.prefix}-scale-in-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = var.scale_in.threshold
  statistic           = "Average"
  evaluation_periods  = 3 //3x em 60 segundos de carga CPU a 20% = dispara alarme
  period              = 60

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.asg.name
  }

}

resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "${var.prefix}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.scale_out.scaling_adjustment
  cooldown               = var.scale_out.cooldown //60, default é 300
}

resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_description   = "Monitors CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_out_policy.arn]
  alarm_name          = "${var.prefix}-scale-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = var.scale_out.threshold
  statistic           = "Average"
  evaluation_periods  = 3 //3x em 60 segundos de carga CPU a 60% = dispara alarme
  period              = 60

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.asg.name
  }
}

resource "aws_lb" "app_lb" { // é um serviço caro, suba e destrua em seguida
  name               = "${var.prefix}-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.prefix}-app-lb"
  }
}

resource "aws_lb_target_group" "app_lb_tg" {
  name     = "${var.prefix}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name = "${var.prefix}-app-tg"
  }
}

resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_lb_tg.arn
  }
}



# resource "aws_eip" "example_eip" {
#   instance   = aws_instance.example_instance.id
#   depends_on = [aws_internet_gateway.example_igw]
# }

# resource "aws_ssm_parameter" "parameter" {
#   name  = "vm_ip"
#   type  = "String"
#   value = aws_eip.example_eip.public_ip
# }

