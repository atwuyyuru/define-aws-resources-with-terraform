# Terraform AWS Provider
provider "aws" {
  region = "us-east-1"  # Change as needed
}

# Create Key Pair
resource "aws_key_pair" "my_key" {
  key_name   = "my-key-pair"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create Security Group
resource "aws_security_group" "my_sg" {
  name        = "my-security-group"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id  # Make sure this is explicitly specified

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create GP3 Volume
resource "aws_ebs_volume" "gp3_volume" {
  availability_zone = "us-east-1a"
  size             = 20
  type             = "gp3"
}

# Create Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Allocate Elastic IP
resource "aws_eip" "elastic_ip" {}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Launch EC2 Instance
resource "aws_instance" "my_instance" {
  ami                    = "ami-xxxxxxxxxxxx"  # Change as needed "aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query 'Images[*].[ImageId,Name]' --output table"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  subnet_id              = aws_subnet.my_subnet.id
}

# Attach Elastic IP to EC2 Instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.my_instance.id
  allocation_id = aws_eip.elastic_ip.id
}

# More resources for IAM, RDS, S3, and VPC will be added here...

output "instance_ip" {
  value = aws_instance.my_instance.public_ip
}
