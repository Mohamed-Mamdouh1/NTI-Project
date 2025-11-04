# -------------------------
# Security Group for ALB
# -------------------------
resource "aws_security_group" "alb_sg" {
  name        = "nti-alb-sg"
  description = "Allow HTTP to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # (Optional) allow HTTPS 443 if you plan TLS later
  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "nti-alb-sg" }
}

# -------------------------
# Security Group for App Instances (ASG)
# -------------------------
resource "aws_security_group" "app_sg" {
  name        = "nti-app-sg"
  description = "Allow traffic from ALB to instances"
  vpc_id      = aws_vpc.main.id

  # Allow ALB -> Instance on port 80
  ingress {
    description      = "Allow ALB to reach app"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  # SSH from your IP only (replace with your IP if desired)
  ingress {
    description = "SSH from anywhere (change to your IP!)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "nti-app-sg" }
}

# -------------------------
# ALB
# -------------------------
resource "aws_lb" "nti_alb" {
  name               = "nti-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.elb_logs.bucket
    enabled = true
  }

  tags = { Name = "nti-alb" }
}

# -------------------------
# Target Group
# -------------------------
resource "aws_lb_target_group" "nti_tg" {
  name     = "nti-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200-399"
  }

  tags = { Name = "nti-target-group" }
}

# -------------------------
# Listener
# -------------------------
resource "aws_lb_listener" "nti_listener" {
  load_balancer_arn = aws_lb.nti_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nti_tg.arn
  }
}