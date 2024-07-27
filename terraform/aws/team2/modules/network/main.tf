module "global" {
  source = "../global"
}

resource "aws_vpc" "main" {
  cidr_block = "172.33.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "${module.global.team_name}-vpc"
    },
    module.global.tags
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${module.global.team_name}-igw"
    },
    module.global.tags
  )
}


resource "aws_route" "public" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.33.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${module.global.team_name}-subnet-public_1"
    },
    module.global.tags
  )
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.33.2.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${module.global.team_name}-subnet-public_2"
    },
    module.global.tags
  )
}

resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.33.3.0/24"
  availability_zone = "ap-northeast-2a"

  tags = merge(
    {
      Name = "${module.global.team_name}-subnet-private_1"
    },
    module.global.tags
  )
}

resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.33.4.0/24"
  availability_zone = "ap-northeast-2b"

  tags = merge(
    {
      Name = "${module.global.team_name}-subnet-private_2"
    },
    module.global.tags
  )
}

resource "aws_eip" "nat" {

  tags = merge(
    {
      Name = "${module.global.team_name}-nat-eip"
    },
    module.global.tags
  )
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  tags = merge(
    {
      Name = "${module.global.team_name}-nat"
    },
    module.global.tags
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    {
      Name = "${module.global.team_name}-rtb-private"
    },
    module.global.tags
  )
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_public_1_id" {
  value = aws_subnet.public_1.id
}

output "subnet_public_2_id" {
  value = aws_subnet.public_2.id
}

output "subnet_private_1_id" {
  value = aws_subnet.private_1.id
}

output "subnet_private_2_id" {
  value = aws_subnet.private_2.id
}