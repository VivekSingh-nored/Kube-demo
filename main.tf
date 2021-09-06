provider "aws" {
  region = "us-east-1"
  
}

terraform {
backend "s3" {
encrypt = true
bucket = "terrastateupgrad"
#dynamodb_table = "terraform-state-lock-dynamo"
region = "us-east-1"
key = "terraform.tfstate"
}
}

resource "aws_vpc" "TerraVPC" {
  cidr_block       = "10.0.0.0/26"
  instance_tenancy = "default"

  tags = {
    Name = "TerraVPC"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.TerraVPC.id

  tags = {
    Name = "IGW"
  }
}

#SUBNETS

resource "aws_subnet" "Subnet_pub_AZ-a" {
  vpc_id     = aws_vpc.TerraVPC.id
  cidr_block = "10.0.0.0/28"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Subnet_pub_AZ-a"
  }
}

resource "aws_subnet" "Subnet_pub_AZ-b" {
  vpc_id     = aws_vpc.TerraVPC.id
  cidr_block = "10.0.0.16/28"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Subnet_pub_AZ-b"
  }
}

resource "aws_subnet" "Subnet_pvt_AZ-a" {
  vpc_id     = aws_vpc.TerraVPC.id
  cidr_block = "10.0.0.32/28"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Subnet_pvt_AZ-a"
  }
}

resource "aws_subnet" "Subnet_pvt_AZ-b" {
  vpc_id     = aws_vpc.TerraVPC.id
  cidr_block = "10.0.0.48/28"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Subnet_pvt_AZ-b"
  }
}

#NAT gateway

resource "aws_nat_gateway" "NAT_tera" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.Subnet_pub_AZ-a.id
}

#ROUTE TABLE

resource "aws_route_table" "Route_Table_Pub" {
  vpc_id = aws_vpc.TerraVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
    }


  tags = {
    Name = "Route_Table_Pub"
  }
}

resource "aws_route_table" "Route_Table_Pvt" {
  vpc_id = aws_vpc.TerraVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT_tera.id
    }

  tags = {
    Name = "Route_Table_Pvt"
  }
}

#Route table association 

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.Subnet_pub_AZ-a.id
  route_table_id = aws_route_table.Route_Table_Pub.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.Subnet_pub_AZ-b.id
  route_table_id = aws_route_table.Route_Table_Pub.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.Subnet_pvt_AZ-b.id
  route_table_id = aws_route_table.Route_Table_Pub.id
}

resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.Subnet_pvt_AZ-a.id
  route_table_id = aws_route_table.Route_Table_Pub.id
}


#Security Groups
/*
data "http" "myip"{
    url = "https://ipv4.icanhazip.com"
    }
    
resource "aws_security_group" "Bastian_SG" {
  name        = "Bastian_SG"
  vpc_id      = aws_vpc.TerraVPC.id

  ingress {
    description      = "SSH to bastian"
    from_port        = 0
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "Bastian_SG"
  }
}

resource "aws_security_group" "Jenkins_SG" {
  name        = "Jenkins_SG"
  vpc_id      = aws_vpc.TerraVPC.id

  ingress {
    
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "Jenkins_SG"
  }
}

resource "aws_security_group" "Web_SG" {
  name        = "Web_SG"
  vpc_id      = aws_vpc.TerraVPC.id

  ingress {
    
    from_port        = 0
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "Web_SG"
  }
}

*/