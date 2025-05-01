data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = merge(var.common_tags, {Name = "${var.env}-vpc", Environment = "${var.env}" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.common_tags, {Name = "${var.env}-igw", Environment = "${var.env}" })
}

#Public Subnets and Routing
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidr, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = merge(var.common_tags, {Name = "${var.env}-public-${count.index + 1}", Environment = "${var.env}" })
}


resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(var.common_tags, {Name = "${var.env}-route-public-subnets", Environment = "${var.env}" })
}

resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
}

#NAT Gateways with Elastic IPs
resource "aws_eip" "nat" {
  count   = length(var.private_subnet_cidr_eip)
  domain = "vpc"
  tags = merge(var.common_tags, {Name = "${var.env}-nat-gw-${count.index + 1}", Environment = "${var.env}" })
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.private_subnet_cidr_eip)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)
  tags = merge(var.common_tags, {Name = "${var.env}-nat-gw-${count.index + 1}", Environment = "${var.env}" })
}

#Private Subnets and Routing
resource "aws_subnet" "private_subnets_eip" {
  count             = length(var.private_subnet_cidr_eip)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidr_eip, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(var.common_tags, {Name = "${var.env}-private-eip-${count.index + 1}", Environment = "${var.env}" })
}

resource "aws_route_table" "private_subnets_eip" {
  count  = length(var.private_subnet_cidr_eip)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = merge(var.common_tags, {Name = "${var.env}-route-private-subnet-eip-${count.index + 1}", Environment = "${var.env}" })
}

resource "aws_route_table_association" "private_routes" {
  count          = length(aws_subnet.private_subnets_eip[*].id)
  route_table_id = aws_route_table.private_subnets_eip[count.index].id
  subnet_id      = element(aws_subnet.private_subnets_eip[*].id, count.index)
}

#Private Subnets and Routing without Elastic IPs
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(var.common_tags, {Name = "${var.env}-private-${count.index + 1}", Environment = "${var.env}" })
}

resource "aws_route_table" "private_subnets" {
  count  = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(var.common_tags, {Name = "${var.env}-route-private-subnet-${count.index + 1}", Environment = "${var.env}" })
}

resource "aws_route_table_association" "private_routes_without_eip" {
  count          = length(aws_subnet.private_subnets[*].id)
  route_table_id = aws_route_table.private_subnets[count.index].id
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
}

#Database Subnets and Routing 
resource "aws_subnet" "database_subnets" {
  count             = length(var.database_subnets_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.database_subnets_cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(var.common_tags, {Name = "${var.env}-database-${count.index + 1}", Environment = "${var.env}" })
}

resource "aws_route_table" "database_subnets" {
  count  = length(var.database_subnets_cidr)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(var.common_tags, {Name = "${var.env}-route-database-subnet-${count.index + 1}", Environment = "${var.env}" })
}

resource "aws_route_table_association" "database_routes" {
  count          = length(aws_subnet.database_subnets[*].id)
  route_table_id = aws_route_table.database_subnets[count.index].id
  subnet_id      = element(aws_subnet.database_subnets[*].id, count.index)
}