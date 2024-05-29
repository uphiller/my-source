resource "aws_vpc" "main" {
  cidr_block = "172.30.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "vpc"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "igw"
    }
  )
}


resource "aws_route" "public" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.30.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "subnet-public_1"
    }
  )
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.30.2.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "subnet-public_2"
    }
  )
}

resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.30.3.0/24"
  availability_zone = "ap-northeast-2a"

  tags = merge(
    {
      Name = "subnet-private_1"
    },
  )
}

resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.30.4.0/24"
  availability_zone = "ap-northeast-2b"

  tags = merge(
    {
      Name = "subnet-private_2"
    },
  )
}

resource "aws_eip" "nat" {

  tags = merge(
    {
      Name = "nat-eip"
    },
  )
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  tags = merge(
    {
      Name = "nat"
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
      Name = "rtb-private"
    },
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
data "aws_ami" "amzn_linux_2023_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "aws_ami" "amzn_linux_2023_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_security_group" "scouter" {
  name        = "scouter"
  vpc_id = data.terraform_remote_state.vpc.outputs.common_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8079
    to_port     = 8079
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8085
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9991
    to_port     = 9996
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9991
    to_port     = 9996
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "load-test-apm"
    },
  )
}

resource "aws_instance" "load_test_apm" {
  ami           = data.aws_ami.amzn_linux_2023_ami.id
  instance_type = "t3.large"
  subnet_id     = data.terraform_remote_state.vpc.outputs.common_public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.load_test_apm.id]

  root_block_device {
    volume_size           = 50
  }

  key_name     = "${keyname}"
  user_data = file("script.sh")

  tags = merge(
    {
      Name = "load-test-apm"
    },
  )
}