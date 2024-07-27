#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo usermod -a -G docker ec2-user
sudo systemctl start docker.service
sudo curl -SL https://github.com/docker/compose/releases/download/v2.26.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose