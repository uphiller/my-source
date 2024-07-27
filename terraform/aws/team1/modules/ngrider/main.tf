module "global" {
  source = "../global"
}

data "aws_ami" "amzn_linux_2023_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

variable "vpc_id" {
  type = string
}

variable "subnet_public_1" {
  type = string
}

resource "aws_security_group" "load_test" {
  name        = "load_test"
  vpc_id = var.vpc_id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "load-test"
    },
    module.global.tags
  )
}

resource "aws_instance" "load_test" {
  ami           = data.aws_ami.amzn_linux_2023_ami.id
  instance_type = "t3.2xlarge"
  subnet_id     = var.subnet_public_1
  vpc_security_group_ids = [aws_security_group.load_test.id]

  key_name     = module.global.key_name
  user_data = file("script.sh")

  tags = merge(
    {
      Name = "load-test"
    },
    module.global.tags
  )
}