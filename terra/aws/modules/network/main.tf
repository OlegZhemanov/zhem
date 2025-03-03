provider "aws" {
  region = "ca-central-1" # Change to your desired region
}

data "aws_availability_zones" "available" {
}

# output "availability_zones" {
#   value = data.aws_availability_zones.available
# }

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-igw"
  }
}

# Create a Public Subnet (Subnet 1: Access to and from the internet)
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0] # Change to your desired AZ

  tags = {
    Name = "public-subnet"
  }
}

# Create a Route Table for the Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate the Public Subnet with the Public Route Table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a Private Subnet with Internet Access (Subnet 2: Only access to the internet)
resource "aws_subnet" "private_subnet_with_internet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1] # Change to your desired AZ

  tags = {
    Name = "private-subnet-with-internet"
  }
}

# Create an EIP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  tags = {
    Name = "nat-eip"
  }
}

# Create a NAT Gateway for the Private Subnet with Internet Access
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "my-nat-gateway"
  }
}

# Create a Route Table for the Private Subnet with Internet Access
resource "aws_route_table" "private_route_table_with_internet" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }

  tags = {
    Name = "private-route-table-with-internet"
  }
}

# Associate the Private Subnet with the Private Route Table
resource "aws_route_table_association" "private_subnet_with_internet_association" {
  subnet_id      = aws_subnet.private_subnet_with_internet.id
  route_table_id = aws_route_table.private_route_table_with_internet.id
}

# Create a Private Subnet without Internet Access (Subnet 3: No access to or from the internet)
resource "aws_subnet" "private_subnet_without_internet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[2] # Change to your desired AZ

  tags = {
    Name = "private-subnet-without-internet"
  }
}

# Create a Route Table for the Private Subnet without Internet Access
resource "aws_route_table" "private_route_table_without_internet" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "private-route-table-without-internet"
  }
}

# Associate the Private Subnet with the Private Route Table
resource "aws_route_table_association" "private_subnet_without_internet_association" {
  subnet_id      = aws_subnet.private_subnet_without_internet.id
  route_table_id = aws_route_table.private_route_table_without_internet.id
}

# Security Group to allow communication between subnets
resource "aws_security_group" "allow_internal" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.my_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.my_vpc.cidr_block]
  }

  tags = {
    Name = "allow-internal"
  }
}

# Output the VPC and Subnet IDs
output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_with_internet_id" {
  value = aws_subnet.private_subnet_with_internet.id
}

output "private_subnet_without_internet_id" {
  value = aws_subnet.private_subnet_without_internet.id
}