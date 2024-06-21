provider "aws" {
  region  = "us-east-1"
}

resource "aws_instance" "Project-Portfolio" {
  ami           = "ami-00beae93a2d981137"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.tf-PP-sg.name]
  key_name      = local_file.PPkey.filename  
  user_data = "${file("userdata.sh")}"

  tags = {
    "Name" = "Project-Portfolio"
  }
  provisioner "local-exec" {
    command = "chmod 400 ${local_file.PPkey.filename}"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_key_pair" "PPkey" {
  key_name   = "PPkey.pem"
  public_key = tls_private_key.PPrsa.public_key_openssh
  
}

resource "tls_private_key" "PPrsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "PPkey" {
  content  = tls_private_key.PPrsa.private_key_pem
  filename = "PPkey.pem"
}

resource "aws_security_group" "tf-PP-sg" {
  name = "tf-PP-sg"
  description = "terraform Project security group"
  tags = {
    Name = "tf-PP-sg"
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "Project-Portfolio-SSH-connect" {
  value = "ssh ec2-user@${aws_instance.Project-Portfolio.public_ip} -i ${local_file.PPkey.filename}"
}

output "Docker-Run-Conteiner-Project" {
  value = "docker run --name 3D-Portolio-Project -d -p 80:8080 --rm herraksoy/projects:3D-Portfolio-Website"
}


