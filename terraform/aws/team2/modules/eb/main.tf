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

resource "aws_elastic_beanstalk_application" "services" {
  name = "insw-services"
}

resource "aws_elastic_beanstalk_environment" "service1" {
  name                = "sign-square"
  application         = aws_elastic_beanstalk_application.services.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.3.4 running Docker"
  tier                = "WebServer"

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
    value     =  "false"
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
    value     = "t3.medium"
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
    value     = "internet facing"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "MatcherHTTPCode"
    value     = "200"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/health"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "younghokwak"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "8088"
  }


  # Enable instance log streaming to CloudWatch Logs
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

  tags = merge(
    module.global.tags
  )
}

data "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_elastic_beanstalk_environment.service1.load_balancers[0]
  port = 80
}

resource "aws_lb_listener_rule" "redirect_root_to_index" {
  listener_arn = data.aws_lb_listener.http_listener.arn
  priority     = 1

  action {
    type = "redirect"
    redirect {
      protocol = "HTTP"
      port     = "80"
      host     = "#{host}"
      path     = "/health"
      query    = "#{query}"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}






