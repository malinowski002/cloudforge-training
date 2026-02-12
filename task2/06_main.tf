###################
# NETWORKING
###################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-subnet"
    Project = var.project_name
    Tier    = "public"
    Owner   = var.owner
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_2
  availability_zone       = var.az_2
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-subnet-2"
    Project = var.project_name
    Tier    = "public"
    Owner   = var.owner
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project_name}-public-route-table"
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

###################
# SECURITY GROUPS
###################
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "SG for EC2 allowing traffic from ALB"
  vpc_id      = aws_vpc.main.id

  # Ingress: allow traffic on port 80 from the ALB SG.
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Egress: allow outbound to the Internet (SSM agent needs this).
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-ec2-sg"
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "SG for ALB (allow HTTP from the Internet)"
  vpc_id      = aws_vpc.main.id

  # Ingress: allow HTTP from the Internet.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-alb-sg"
    Project = var.project_name
    Owner   = var.owner
  }
}

###################
# IAM FOR SSM
###################

resource "aws_iam_role" "ssm_role" {
  name = "${var.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-ssm-role"
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.project_name}-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

###################
# EC2 INSTANCE
###################
# resource "aws_instance" "nginx_app" {
#   ami                         = "ami-0a854fe96e0b45e4e"
#   instance_type               = var.instance_type
#   subnet_id                   = aws_subnet.public.id
#   associate_public_ip_address = true
#   vpc_security_group_ids      = [aws_security_group.ec2.id]

#   user_data = <<-EOF
#               #!/bin/bash
#               apt-get update -y
#               apt-get install nginx -y
#               systemctl start nginx
#               systemctl enable nginx
#               EOF

#   tags = {
#     Name    = "${var.project_name}-ec2"
#     Project = var.project_name
#     Owner   = var.owner
#   }
# }

###################
# AUTO SCALING GROUP
###################
resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = "ami-0a854fe96e0b45e4e"
  instance_type  = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install nginx -y
              systemctl start nginx
              systemctl enable nginx
              EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.project_name}-ec2"
      Project = var.project_name
      Owner   = var.owner
    }
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "${var.project_name}-asg"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 2
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
  vpc_zone_identifier       = [aws_subnet.public.id, aws_subnet.public_2.id]
  target_group_arns         = [aws_lb_target_group.app_tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
}

###################
# APPLICATION LOAD BALANCER
###################

resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public_2.id]

  tags = {
    Name    = "${var.project_name}-alb"
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }

  tags = {
    Name    = "${var.project_name}-tg"
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# resource "aws_lb_target_group_attachment" "app_tg_attachment" {
#   target_group_arn = aws_lb_target_group.app_tg.arn
#   target_id        = aws_instance.nginx_app.id
#   port             = 80

# }