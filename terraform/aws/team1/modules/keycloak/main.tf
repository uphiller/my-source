module "global" {
  source = "../global"
}

variable "vpc_id" {
  type = string
}

variable "subnet_private_1" {
  type = string
}

variable "subnet_private_2" {
  type = string
}

variable "subnet_public_1" {
  type = string
}

variable "subnet_public_2" {
  type = string
}


resource "aws_iam_role" "elasticbeanstalk_service_role" {
  name = "aws-elasticbeanstalk-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_service_policy" {
  role       = aws_iam_role.elasticbeanstalk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_enhanced_health_policy" {
  role       = aws_iam_role.elasticbeanstalk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role" "elasticbeanstalk_ec2_role" {
  name = "aws-elasticbeanstalk-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_web_tier_policy" {
  role       = aws_iam_role.elasticbeanstalk_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_worker_tier_policy" {
  role       = aws_iam_role.elasticbeanstalk_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_multicontainer_docker_policy" {
  role       = aws_iam_role.elasticbeanstalk_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_container_registry_readonly" {
  role       = aws_iam_role.elasticbeanstalk_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "elasticbeanstalk_instance_profile" {
  name = "aws-elasticbeanstalk-ec2-role"
  role = aws_iam_role.elasticbeanstalk_ec2_role.name
}

resource "aws_elastic_beanstalk_application" "common" {
  name = "common-app"

  tags = merge(
    {
      Name = "common-app"
    },
    module.global.tags
  )
}

resource "aws_elastic_beanstalk_environment" "common-env" {
  name                = "auth-env"
  application         = aws_elastic_beanstalk_application.common.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.3.4 running Docker"
  tier                = "WebServer"

  tags = merge(
    {
      Name = "auth-env"
    },
    module.global.tags
  )

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", [var.subnet_private_1, var.subnet_private_2])
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", [var.subnet_public_1, var.subnet_public_2])
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
    value     = module.global.key_name
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