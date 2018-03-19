#!/bin/bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates  curl software-properties-common  openjdk-8-jre make sshpass

sudo echo "ubuntu:ubuntu" | sudo chpasswd
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/'  /etc/ssh/sshd_config
sudo sed -i 's/#   StrictHostKeyChecking ask/    StrictHostKeyChecking no/'  /etc/ssh/ssh_config
sudo systemctl restart sshd

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"

sudo apt-get update
sudo apt-get install -y docker-ce

sudo usermod -aG docker vagrant
sudo usermod -aG docker ubuntu
sudo service docker start
docker info

sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
