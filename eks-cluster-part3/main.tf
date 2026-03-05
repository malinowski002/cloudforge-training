data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-private-vpc"
  cidr = var.vpc_cidr

  azs = var.azs
  public_subnets = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_dns_support = true
  enable_dns_hostnames = true

  create_igw = true
  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    project = "eks-private-cluster"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "minimal-eks-cluster"
  cluster_version = "1.30"

  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = false

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc

  eks_managed_node_groups = {
    default = {
      subnet_ids = module.vpc.private_subnets
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      instance_types = ["t3.medium"]
      ami_type       = "AL2023_x86_64_STANDARD"
    }
  }

  access_entries = {
    local_admin = {
      admin = {
        policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      }
    }
  }

  cluster_security_group_additional_rules = {
    bastion_to_k8s_api = {
      description = "Allow bastion host to access Kubernetes API"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [aws_security_group.bastion.id]
    }
  }
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_iam_policy_document" "bastion_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bastion" {
  name = "eks-bastion-role"
  assume_role_policy = data.aws_iam_policy_document.bastion_assume_role.json
}

resource "aws_iam_role_policy_attachment" "bastion_attach" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "bastion_eks_describe" {
  name = "eks-bastion-describe-cluster"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster", 
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_eks_describe_attach" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.bastion_eks_describe.arn
}

resource "aws_iam_instance_profile" "bastion" {
  name = "eks-bastion-instance-profile"
  role = aws_iam_role.bastion.name
}

resource "aws_security_group" "bastion" {
  name = "eks-bastion-sg"
  description = "Security group for EKS bastion host"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-bastion-sg"
  }
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.bastion_instance_type
  subnet_id     = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  associate_public_ip_address = false

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "eks-private-bastion"
  }
}