####Creation of VPC######
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "CustomVPC"
  }
}

####Creation of Public Subnets######
resource "aws_subnet" "sub-a" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "subnet-1a"
  }
}

resource "aws_subnet" "sub-b" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "subnet-1b"
  }
}

####Creation of Private Subnet######
resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.myvpc.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.3.0/24"

  tags = {
    Name = "private-subnet-1a"
  }
}

####Creation of Internet Gateway######
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "MyIGW"
  }
}

####Creation of Public route table######
resource "aws_route_table" "my-rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    gateway_id = aws_internet_gateway.my-igw.id
    cidr_block = "0.0.0.0/0"
  }
}

####Assosciating public subnets with public route table######
resource "aws_route_table_association" "rta-1" {
  subnet_id      = aws_subnet.sub-a.id
  route_table_id = aws_route_table.my-rt.id
}

resource "aws_route_table_association" "rta-2" {
  subnet_id      = aws_subnet.sub-b.id
  route_table_id = aws_route_table.my-rt.id
}

####Creation of Elastic IP for NAT Gateway######
resource "aws_eip" "elastic-ip" {
  domain = "vpc"
}

####Creation of NAT Gateway######
resource "aws_nat_gateway" "my-nat" {
  allocation_id = aws_eip.elastic-ip.id
  subnet_id     = aws_subnet.sub-a.id

  tags = {
    Name = "NATGateway"
  }
}

####Creation of Private route table######
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my-nat.id
  }
}

####Associating private subnet with private route table######
resource "aws_route_table_association" "private-route" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet.id
}

####Creation of Security Group######
resource "aws_security_group" "my-sg" {
  vpc_id = aws_vpc.myvpc.id
  name   = "my-sg1"

  ####Defining inbound rules######
  ingress {
    description = "Allows http traffic"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows https traffic"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows ssh traffic"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ####Defining outbound rules######
  egress {
    description = "Allows all traffic"
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "public-instance" {
  ami             = var.ami-id
  instance_type   = var.instance-type
  subnet_id       = aws_subnet.sub-a.id
  vpc_security_group_ids = [ aws_security_group.my-sg.id ]
  key_name        = "login"
  user_data       = file("script.sh")

  tags = {
    Name = "Public-Instance"
  }
}
