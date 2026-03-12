resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnets"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name}-db-subnet-group"
  }
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "RDS access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
}

resource "aws_db_instance" "this" {
  identifier        = var.name
  engine            = "postgres"
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  db_name           = var.db_name
  username          = var.db_username

  manage_master_user_password   = true
  master_user_secret_kms_key_id = var.kms_key_id

  multi_az                = var.multi_az
  publicly_accessible     = false
  storage_encrypted       = true
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection

  vpc_security_group_ids = [aws_security_group.this.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  tags = {
    Name = var.name
  }
}