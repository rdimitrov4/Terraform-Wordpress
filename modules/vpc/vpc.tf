###############################
####         VPC           ####
###############################

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc"
  }

}

######################################
##### Public Subnets (one per AZ) ####
######################################

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs) # Creates one subnet per CIDR
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index] # Each subnet gets a unique CIDR from the list
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-public-${count.index + 1}"
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }

}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "rtb-public"
  }

}

# Associate Public rtb with each Public Subnet
resource "aws_route_table_association" "rtb_public_assoc" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.rtb_public.id

}

resource "aws_route" "rtb_public_igw" {
  route_table_id         = aws_route_table.rtb_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

}

######################################
## Web Server Subnets (one per AZ)  ##
######################################

resource "aws_subnet" "webserver_subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.webserver_subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
    Name = "subnet-webserver-${count.index + 1}"
  }

}

resource "aws_route_table" "rtb_webserver" {
  count  = length(aws_subnet.webserver_subnet)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "rtb-webserver-${count.index + 1}"
  }

}

# Associate each Webserver rtb with each Webserver Subnet
resource "aws_route_table_association" "rtb_webserver_assoc" {
  count          = length(aws_subnet.webserver_subnet)
  subnet_id      = aws_subnet.webserver_subnet[count.index].id
  route_table_id = aws_route_table.rtb_webserver[count.index].id

}

# Route each webserver subnet’s route table through its corresponding NAT Gateway
resource "aws_route" "rtb_webserver_nat" {
  count                  = length(aws_subnet.webserver_subnet)
  route_table_id         = aws_route_table.rtb_webserver[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[count.index].id

}

######################################
####        NAT Gateway           ####
######################################

# One Elastic IP per AZ for NAT Gateways
resource "aws_eip" "nat_eip" {
  count  = length(aws_subnet.public_subnet)
  domain = "vpc"

  tags = {
    Name = "eip-nat-${count.index + 1}"
  }

}

# NAT Gateway in each public subnet
resource "aws_nat_gateway" "nat_gw" {
  count         = length(aws_subnet.public_subnet)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "nat-gw-${count.index + 1}"
  }

}

######################################
#### Private Subnets (one per AZ) ####
######################################

resource "aws_subnet" "private_subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
    Name = "subnet-private-${count.index + 1}"
  }

}

resource "aws_route_table" "rtb_private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "rtb-private"
  }

}

# Associate Private rtb with each Private Subnet
resource "aws_route_table_association" "rtb_private_assoc" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.rtb_private.id

}

###############################
####    Security Groups    ####
###############################

resource "aws_security_group" "ec2_sg" {
  vpc_id      = aws_vpc.vpc.id

  # Allow HTTP from public subnets for the Load Balancers
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.public_subnet_cidrs
  }

  # Allow access form MySQL
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  # Security vulnerability. Best practice - use your personal IP address or corporate subnets or public IPs for SSH
  # Use SCPs to block access to Session Manager and Instance Connect with conditional keys like "aws:SourceIp" in IAM policies
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-ec2"
  }

}
