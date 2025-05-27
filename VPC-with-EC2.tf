provider "aws" {
    region = var.region
}

resource "aws_instance" "jay-server" {
    ami = "ami-0afc7fe9be84307e4"
    key_name = "jay-keypair"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.jay-subnet.id
    vpc_security_group_ids = [ aws_security_group.jay-sec-group.id ]
  
}

resource "aws_vpc" "jay-vpc" {
    cidr_block = "10.10.0.0/16"
  
}

resource "aws_subnet" "jay-subnet" {
    vpc_id = aws_vpc.jay-vpc.id
    cidr_block = "10.10.1.0/24"

    tags = {
      Name = "jay-subnet"
    }
  
}

resource "aws_internet_gateway" "jay-igw" {
    vpc_id = aws_vpc.jay-vpc.id

    tags = {
        Name = "jay-igw"
    }
  
}

resource "aws_route_table" "jay-route" {
  vpc_id = aws_vpc.jay-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jay-igw.id
  }

tags = {
    Name = "jay-route"
}


}

resource "aws_route_table_association" "jay-rt-assoc" {
    subnet_id = aws_subnet.jay-subnet.id
    route_table_id = aws_route_table.jay-route.id
  
}

resource "aws_security_group" "jay-sec-group" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id = aws_vpc.jay-vpc.id

  tags = {
    Name = "allow_tls"
  }


ingress {
  ipv6_cidr_blocks = ["::/0"]
  cidr_blocks = ["0.0.0.0/0"]
  from_port         = 22
  protocol       = "tcp"
  to_port           = 22
}

egress {
  ipv6_cidr_blocks = ["::/0"]
  cidr_blocks = ["0.0.0.0/0"]
  from_port         = 0
  protocol       = "-1"
  to_port           = 0
}

}