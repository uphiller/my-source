resource "aws_lightsail_instance" "ngrider" {
  name              = "ngrider"
  availability_zone = "ap-northeast-2a"
  blueprint_id      = "amazon_linux_2023"
  bundle_id         = "4xlarge_3_0"
  key_pair_name = "id_rsa"
  user_data = "sudo yum update -y && sudo yum install docker -y && sudo usermod -a -G docker ec2-user && sudo systemctl start docker.service && sudo curl -SL https://github.com/docker/compose/releases/download/v2.26.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose"
}

resource "aws_lightsail_instance_public_ports" "ngrider_ports" {
  instance_name = aws_lightsail_instance.ngrider.name

  port_info {
    from_port   = 80        # HTTP 포트
    to_port     = 80
    protocol    = "tcp"
  }

  port_info {
    from_port   = 22        # SSH 포트
    to_port     = 22
    protocol    = "tcp"
  }
}

output "lightsail_ip" {
  value = aws_lightsail_instance.ngrider.public_ip_address
}