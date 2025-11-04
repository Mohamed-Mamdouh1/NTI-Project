# -------------------------
# Use a data source to pick a recent Amazon Linux 2 AMI in eu-west-1
# -------------------------
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# -------------------------
# Launch Template
# -------------------------
resource "aws_launch_template" "nti_app_template" {
  name_prefix   = "nti-app-template-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.small"
  key_name      = "nti-key"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "nti-app-instance"
    }
  }
}

# -------------------------
# Auto Scaling Group
# -------------------------
resource "aws_autoscaling_group" "nti_asg" {
  name_prefix         = "nti-asg-"
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.public1.id, aws_subnet.public2.id]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.nti_app_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.nti_tg.arn]

  tag {
    key                 = "Name"
    value               = "nti-asg-instance"
    propagate_at_launch = true
  }

  # ensure instances are replaced cleanly on update
  lifecycle {
    create_before_destroy = true
  }
}
