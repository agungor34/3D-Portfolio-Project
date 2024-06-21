terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "default"
#  region  = "us-east-1"
  region  = var.myRegion
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# locals {
#   # change here, optional
#   name = "clarusway"
#   keyname = "clarus"
#   instancetype = "t3a.medium"
#   ami = "ami-0c7217cdde317cfec"
# }

resource "aws_spot_instance_request" "trid-pfolio" { #resource "aws_instance" "master" {
  ami                  = var.myAmi
  spot_price           = "0.0270"
  instance_type        = var.myInstancetype
  availability_zone = var.myAZs
  wait_for_fulfillment = true
  key_name             = var.myKey
  iam_instance_profile = aws_iam_instance_profile.ec2connectprofile.name
#  security_groups      = ["${var.myTag}-k8s-master-sec-gr"]
  user_data            = file("trid-pfolio.sh")
  vpc_security_group_ids = [aws_security_group.tf-trid-pfolio-sec-gr.id]
  # tags = {
  #   Name = "${var.myTag}-kube-master"
  # }
}

resource "aws_iam_instance_profile" "ec2connectprofile" {
  name = "ec2connectprofile-${var.myTag}"
  role = aws_iam_role.ec2connectcli.name
}

resource "aws_iam_role" "ec2connectcli" {
  name = "ec2connectcli-${var.myTag}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "my_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : "ec2-instance-connect:SendSSHPublicKey",
          "Resource" : "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/*",
          "Condition" : {
            "StringEquals" : {
              "ec2:osuser" : "ubuntu"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : "ec2:DescribeInstances",
          "Resource" : "*"
        }
      ]
    })
  }
}

resource "aws_security_group" "tf-trid-pfolio-sec-gr" {
  name = "${var.myTag}-trid-pfolio-sec-gr"
  tags = {
    Name = "${var.myTag}-trid-pfolio-sec-gr"
  }

  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self = true
  }

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

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ec2_tag" "example" {
  resource_id = aws_spot_instance_request.trid-pfolio.spot_instance_id
  key = "Name"
  value = "${var.myTag}-trid-pfolio"
}

output "trid-pfolio_public_dns" {
  value = aws_spot_instance_request.trid-pfolio.public_dns
}

output "trid-pfolio_private_dns" {
  value = aws_spot_instance_request.trid-pfolio.private_dns
}

