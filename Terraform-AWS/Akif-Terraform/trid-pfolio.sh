#! /bin/bash
apt-get update -y
apt-get upgrade -y
hostnamectl set-hostname trid-pfolio
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu
newgrp docker
yum install git -y
git clone https://github.com/Herr-Aksoy/3D-Portfolio-Project.git