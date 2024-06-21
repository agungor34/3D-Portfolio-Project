#! /bin/bash
yum update -y
hostnamectl set-hostname project-portfolio-server
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
yum install git -y

# pip icin ekstra ayarlamalar
sudo yum install python3 python3-pip -y
sudo pip install Flask
sudo pip install Flask-Mail