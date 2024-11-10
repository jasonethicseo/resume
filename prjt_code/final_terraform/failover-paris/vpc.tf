provider "aws" {
  region = "eu-west-3"
  }


variable "vpc_main_cidr" {
  description = "VPC main CIDR block"
  default = "10.0.10.0/24"

}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_main_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc-970728"
  }
}

resource "aws_subnet" "pub_sub_1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 4, 0)
  availability_zone = "eu-west-3a"
  map_public_ip_on_launch = true
    tags = {
    Name = "pub_sub_1"
  }
}

resource "aws_subnet" "prv_sub_1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 4, 1)
  availability_zone = "eu-west-3a"
      tags = {
    Name = "prv_sub_1"
  }
}

resource "aws_subnet" "pub_sub_2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 4, 2)
  availability_zone = "eu-west-3b"
  map_public_ip_on_launch = true  
  tags = {
    Name = "pub_sub_2"
  }
}

resource "aws_subnet" "prv_sub_2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 4, 3)
  availability_zone = "eu-west-3b"
  tags = {
    Name = "prv_sub_2"
  }
}

resource "aws_subnet" "prv_sub_3" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 4, 4)
  availability_zone = "eu-west-3a"
  tags = {
    Name = "prv_sub_3"
  }  
}

resource "aws_subnet" "prv_sub_4" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 4, 5)
  availability_zone = "eu-west-3b"
  tags = {
    Name = "prv_sub_4"
  }
}

##### tgw용 서브넷
resource "aws_subnet" "tgw_sub" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 4, 6)
  availability_zone = "eu-west-3a"
  tags = {
    Name = "server_tgw_sub"
  }
}


resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "prjt-IGW-970728"
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "rtb_pub-970728"
  }
}

resource "aws_route_table" "prv_rt1" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1.id
  }
  tags = {
    Name = "rtb_natprv1-a-970728"
  }  
}

resource "aws_route_table" "prv_rt2" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block  = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_2.id
  }
  tags = {
    Name = "rtb_natprv2-b-970728"
  }    
}

# 세 번째 프라이빗 라우트 테이블 선언
resource "aws_route_table" "prv_rt3" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "rtb_prv3-a-970728"
  }  
}

# 네 번째 프라이빗 라우트 테이블 선언
resource "aws_route_table" "prv_rt4" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "rtb_prv4-b-970728"
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

resource "aws_route_table_association" "prv_rt2_asso2" {
  subnet_id = aws_subnet.prv_sub_2.id
  route_table_id = aws_route_table.prv_rt2.id
}

##tgw 때문에 추가
resource "aws_route_table_association" "prv_rt3_asso3" {
  subnet_id = aws_subnet.prv_sub_3.id
  route_table_id = aws_route_table.prv_rt3.id
}

resource "aws_route_table_association" "prv_rt4_asso4" {
  subnet_id = aws_subnet.prv_sub_4.id
  route_table_id = aws_route_table.prv_rt4.id
}




#eip 할당

resource "aws_eip" "nat_eip1" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip2" {
  domain = "vpc"
}

# resource "aws_eip" "openvpn_eip" {
#   instance = aws_instance.openvpn.id
# }

# #natgw eip 할당

resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id = aws_subnet.pub_sub_1.id
  tags = {
    Name = "natgw1-a-970728"
  }

  depends_on = [ aws_internet_gateway.my_igw ]
}

resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id = aws_subnet.pub_sub_2.id
  tags = {
    Name = "natgw2-b-970728"
  }

  depends_on = [ aws_internet_gateway.my_igw ]
}
