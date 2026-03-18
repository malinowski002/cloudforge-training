resource "aws_security_group" "postgres_vm" {
    name = "payments-postgres-vm-sg"
    description = "Allow PostgreSQL from EKS nodes"
    vpc_id = var.vpc_id

    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = [var.eks_node_security_group_id]
        description = "PostgreSQL from EKS nodes"
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "payments-postgres-data" }
}

resource "aws_ebs_volume" "postgres_data" {
    availability_zone = data.aws_subnet.selected.availability_zone
    size = 20
    type = "gp3"
    encrypted = true

    tags = {
        Name = "payments-postgres-data"
    }
}

data "aws_subnet" "selected" {
    id = var.subnet_id
}

resource "aws_instance" "postgres_vm" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type
    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.postgres_vm.id]

    iam_instance_profile = aws_iam_instance_profile.ssm.name

    user_data = templatefile("${path.module}/user_data.sh", {
      db_password = var.db_password
    })

    tags = {
        Name = "payments-postgres-vm"
    }
}

resource "aws_volume_attachment" "postgres_data" {
    device_name = "/dev/xvdf"
    volume_id = aws_ebs_volume.postgres_data.id
    instance_id = aws_instance.postgres_vm.id
    force_detach = true
}

data "aws_ami" "amazon_linux" {
    most_recent = true
    owners = ["amazon"]
    filter {
      name = "name"
      values = ["al2023-ami-*-x86_64"]
    }
}

# IAM for SSM Session Manager
resource "aws_iam_role" "ssm" {
    name = "payments-postgres-vm-role"
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }]
    })
}

resource "aws_iam_role_policy_attachment" "ssm" {
    role = aws_iam_role.ssm.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
    name = "payments-postgres-vm-profile"
    role = aws_iam_role.ssm.name
}