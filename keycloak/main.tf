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

resource "aws_elastic_beanstalk_application" "common" {
  name = "common-app"

  tags = merge(
    {
      Name = "common-app"
    },
  )
}

resource "aws_elastic_beanstalk_environment" "common-env" {
  name                = "auth-env"
  application         = aws_elastic_beanstalk_application.common.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.2.2 running Docker"
  tier                = "WebServer"

  tags = merge(
    {
      Name = "auth-env"
    },
  )

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = module.network.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", [module.network.subnet_private_1_id, module.network.subnet_private_2_id])
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", [module.network.subnet_public_1_id, module.network.subnet_public_2_id])
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     =  false
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.small"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "aws-elasticbeanstalk-service-role"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "internet-facing"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "8080"
  }

  //** 대상그룹에 고정켜기
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/health"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "MatcherHTTPCode"
    value     = "200"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "{EC2KeyName}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "2"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "2"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "Rolling"
  }

  setting {
   namespace = "aws:elasticbeanstalk:command"
   name      = "BatchSizeType"
   value     = "Percentage"
  }

  setting {
   namespace = "aws:elasticbeanstalk:command"
   name      = "BatchSize"
   value     = "50"
  }

  setting {
   name = "Unit"
   namespace = "aws:autoscaling:trigger"
   value = "Percent"
  }
  setting {
   name = "MeasureName"
   namespace = "aws:autoscaling:trigger"
   value = "CPUUtilization"
  }
  setting {
   name = "LowerThreshold"
   namespace = "aws:autoscaling:trigger"
   value = "70"
  }
  setting {
   name = "UpperThreshold"
   namespace = "aws:autoscaling:trigger"
   value = "90"
  }
  setting {
   name = "Period"
   namespace = "aws:autoscaling:trigger"
   value = "5"
  }
  setting {
   name = "UpperBreachScaleIncrement"
   namespace = "aws:autoscaling:trigger"
   value = "1"
  }
  setting {
   name = "LowerBreachScaleIncrement"
   namespace = "aws:autoscaling:trigger"
   value = "-1"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteOnTerminate"
    value     = "false"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = "7"
  }

  //** settings
  //https://docs.aws.amazon.com/ko_kr/elasticbeanstalk/latest/dg/command-options-general.html

  //** cloudwatch
  //eb-current-app/stdouterr.log

  //add port 7800
}