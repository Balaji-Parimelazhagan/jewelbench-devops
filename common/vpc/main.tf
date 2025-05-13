############################################ Create VPC ####################################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

########################################### Create Public Subnet ##########################################

resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidr)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
  }
}

########################################### Create Private Subnet ########################################

resource "aws_subnet" "private" {
  count = length(var.private_subnets_cidr)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}


############################################ Public Subnets and internat gatway connection ###################################################

# Create internat gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.this.id 

  tags = {
    Name = "${var.environment}-internet-gateway"
  }
}

# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id 

  tags = {
    Name = "${var.environment}-public-route-table"
  }
}

#Public Route Table - Default Route to IGW (Routes)
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# Associate Public Route Table with Public Subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

######################################### Private Subnet and NAt gatway connection ###################################################################

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.environment}-nat-eip"
  }
}

# NAT Gateway for Private Subnets
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.environment}-nat-gateway"
  }
}


# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.environment}-private-route-table"
  }
}


# Private Route Table - Route Through NAT Gateway
resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}


# Associate Private Route Table with Private Subnets
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
