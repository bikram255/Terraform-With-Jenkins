# -----------------------------
# Provider
# -----------------------------
provider "aws" {
  region = "ap-south-1"   # change if needed
}

# -----------------------------
# VPC
# -----------------------------
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "k8s_vpc"
  }
}

# -----------------------------
# Subnet
# -----------------------------
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "my-subnet"
  }
}

# -----------------------------
# Internet Gateway
# -----------------------------
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "my-igw"
  }
}

# -----------------------------
# Route Table
# -----------------------------
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my-rt"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "my_rta" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_rt.id
}

# -----------------------------
# Security Group
# -----------------------------
resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.k8s_vpc.id
  name   = "allow_ssh_http"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
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
    Name = "my-sg"
  }
}

# -----------------------------
# EC2 Instance
# -----------------------------
resource "aws_instance" "my_ec2" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (update for your region)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  associate_public_ip_address = true
  key_name      = "my-key"  # <-- replace with your existing key pair name

  tags = {
    Name = "my-ec2"
  }
}
