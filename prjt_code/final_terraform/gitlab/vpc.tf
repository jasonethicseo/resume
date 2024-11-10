provider "aws" {
  region = "ca-central-1"
  }

variable "vpc_main_cidr" {
  description = "VPC main CIDR block"
  default = "10.0.0.0/24"

}

resource "aws_vpc" "gitlab_vpc" {
  cidr_block = var.vpc_main_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "gitlab-vpc-970728"
  }
}

resource "aws_subnet" "pub_sub_1" {
  vpc_id = aws_vpc.gitlab_vpc.id
  cidr_block = cidrsubnet(aws_vpc.gitlab_vpc.cidr_block, 3, 0)
  availability_zone = "ca-central-1a"
  map_public_ip_on_launch = true
    tags = {
    Name = "gitlab-pub_sub_1"
  }
}

resource "aws_subnet" "prv_sub_1" {
  vpc_id = aws_vpc.gitlab_vpc.id
  cidr_block = cidrsubnet(aws_vpc.gitlab_vpc.cidr_block, 3, 1)
  availability_zone = "ca-central-1a"
      tags = {
    Name = "gitlab-prv_sub_1"
  }
}

resource "aws_subnet" "pub_sub_2" {
  vpc_id = aws_vpc.gitlab_vpc.id
  cidr_block = cidrsubnet(aws_vpc.gitlab_vpc.cidr_block, 3, 2)
  availability_zone = "ca-central-1b"
  map_public_ip_on_launch = true  
  tags = {
    Name = "gitlab-pub_sub_2"
  }
}


resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.gitlab_vpc.id
  tags = {
    Name = "IGW-970728"
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.gitlab_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "gitlab-rtb_pub-970728"
  }
}

resource "aws_route_table" "prv_rt1" {
  vpc_id = aws_vpc.gitlab_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1.id
  }
  tags = {
    Name = "gitlab-rtb_natprv1-a-970728"
  }  
}

resource "aws_route_table_association" "pub_rt_asso" {
  subnet_id = aws_subnet.pub_sub_1.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pub_rt_asso2" {
  subnet_id = aws_subnet.pub_sub_2.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "prv_rt1_asso" {
  subnet_id = aws_subnet.prv_sub_1.id
  route_table_id = aws_route_table.prv_rt1.id
}


#eip 할당

resource "aws_eip" "nat_eip1" {
  domain = "vpc"
}

# #natgw eip 할당

resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id = aws_subnet.pub_sub_1.id
  tags = {
    Name = "gitlab-natgw1-a-970728"
  }

  depends_on = [ aws_internet_gateway.my_igw ]
}
