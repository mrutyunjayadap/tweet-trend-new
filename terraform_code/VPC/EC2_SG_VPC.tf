provider "aws" {
  region = "us-east-1"
}

#VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}

#public subnet 1 in AZ-1
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "public-subnet-1"
  }
}

#public subnet 1 in AZ-2
resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "public-subnet-2"
  }
}

#internet gateway
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "my-igw"
  }
}

#route table for traffic inflow from outside to igw
resource "aws_route_table" "my-rt" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
  tags = {
    Name = "my-rt"
  }
}

#route table association with public subnet 1
resource "aws_route_table_association" "my-rta-public-subnet-1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.my-rt.id
}

#route table association with public subnet 2
resource "aws_route_table_association" "my-rta-public-subnet-2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.my-rt.id
}



#security group resource
resource "aws_security_group" "my-SG" {
  name        = "security group for EC2"
  description = "security group for EC2"
  vpc_id      = aws_vpc.my-vpc.id

  tags = {
    Name = "allow_tls"
  }

}
#security group ingress rule
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.my-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "SSH"
}
resource "aws_vpc_security_group_ingress_rule" "allow_8080" {
  security_group_id = aws_security_group.my-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
  description       = "Jenkins"
}

resource "aws_vpc_security_group_ingress_rule" "allow_8000" {
  security_group_id = aws_security_group.my-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8000
  ip_protocol       = "tcp"
  to_port           = 8000
  description       = "appication port"
}
#security group egress rule
resource "aws_vpc_security_group_egress_rule" "allow_outbound" {
  security_group_id = aws_security_group.my-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

#EC2 instance resource
resource "aws_instance" "my-ec2-1" {
  ami             = "ami-04b70fa74e45c3917"
  instance_type   = "t2.micro"
  key_name        = "dpp"
  //security_groups = [aws_security_group.my-SG.name]
  vpc_security_group_ids = [ aws_security_group.my-SG.id ]
  subnet_id       = aws_subnet.public-subnet-1.id

  for_each = toset(["Jenkins-master", "Build-slave","Ansible"])
   tags = {
     Name = "${each.key}"
   }
}

module "sgs" {
       source = "../sg_eks"
       vpc_id = aws_vpc.my-vpc.id
    }

     module "eks" {
          source = "../eks"
          vpc_id = aws_vpc.my-vpc.id
          subnet_ids = [aws_subnet.public-subnet-1.id,aws_subnet.public-subnet-2.id]
          sg_ids = module.sgs.security_group_public
    }