provider "aws" {
  region = "us-east-1"
}

# aws intance
resource "aws_instance" "demo-server" {
  ami = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name = "k8s-hp"
  //security_groups = ["demo-sg"]
  vpc_security_group_ids = [ aws_security_group.demo-sg.id]
  subnet_id = aws_subnet.demo-public-snet-1.id
}

# aws security group
resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id = aws_vpc.demo-vpc-1.id

  ingress {
    description      = "for ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-port"
  }
}

resource "aws_vpc" "demo-vpc-1" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "demo-vpc-1"
  }
}

resource "aws_subnet" "demo-public-snet-1" {
  vpc_id = aws_vpc.demo-vpc-1.id
  cidr_block = "10.1.1.0/24"  
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    Name = "demo-public-snet-1"
  }
}

resource "aws_subnet" "demo-public-snet-2" {
  vpc_id = aws_vpc.demo-vpc-1.id
  cidr_block = "10.1.2.0/24"  
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    Name = "demo-public-snet-2"
  }
}

resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc-1.id
  tags = {
    Name = "demo-igw"
  }
}

resource "aws_route_table" "demo-public-rt" {
  vpc_id = aws_vpc.demo-vpc-1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }
}

resource "aws_route_table_association" "demo-rta-public-snet-1" { 
  subnet_id = aws_subnet.demo-public-snet-1.id
  route_table_id = aws_route_table.demo-public-rt.id
}

resource "aws_route_table_association" "demo-rta-public-snet-2" { 
  subnet_id = aws_subnet.demo-public-snet-2.id
  route_table_id = aws_route_table.demo-public-rt.id
}