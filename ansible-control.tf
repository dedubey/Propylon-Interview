locals {
    ssh_user = "ubuntu"
}

resource "aws_iam_role" "ansible-role" {
  name = "ansible-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

#resource "aws_iam_role_policy_attachment" "s3-full-access" {
 # role       = aws_iam_role.ansible-role.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
#}

resource "aws_iam_instance_profile" "ansible-profile" {
  name = "ansible-profile"
  role = aws_iam_role.ansible-role.name
}

resource "aws_instance" "ansible-control" {
  ##name                   = "ansible-instance"
  instance_type          = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ansible-profile.name
  ami                    = "ami-0cf2b4e024cdb6960"
  key_name               = aws_key_pair.generated_key.key_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.ansible-security-group.id]
  subnet_id              = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  
  provisioner "remote-exec" {
    inline = [
      "echo 'wait untill ssh is ready'",
      "sudo apt update",
      "sudo apt-add-repository -y ppa:ansible/ansible",
      "sudo apt-get -y install ansible",
      "sudo apt update",
      "sudo apt -y install python3-boto3",
      "mkdir ansible && cd ansible",
      
    ]     
    connection {
        type = "ssh"
        user = local.ssh_user
        private_key = tls_private_key.ec2_key.private_key_pem
        host = aws_instance.ansible-control.public_ip
    }
  }
   provisioner "file" {
    source = "./ansible/"
    destination = "/home/ubuntu/ansible/" 
    connection {
        type = "ssh"
        user = local.ssh_user
        private_key = tls_private_key.ec2_key.private_key_pem
        host = aws_instance.ansible-control.public_ip
    }
  }

  provisioner "file" {
    source = "./.ssh/user2.pem"
    destination = "/home/ubuntu/ansible/user2.pem" 
    connection {
        type = "ssh"
        user = local.ssh_user
        private_key = tls_private_key.ec2_key.private_key_pem
        host = aws_instance.ansible-control.public_ip
    }
  }
  
  provisioner "remote-exec" {
    inline = [
      "cd /home/ubuntu/ansible",
      "chmod 400 user2.pem",
      "ansible-playbook ansible-playbook.yaml"
      
    ]     
    connection {
        type = "ssh"
        user = local.ssh_user
        private_key = tls_private_key.ec2_key.private_key_pem
        host = aws_instance.ansible-control.public_ip
    }
  }
  
  tags = {
    Terraform   = "true"
  }
depends_on = [aws_security_group.ansible-security-group,aws_iam_instance_profile.ansible-profile,module.vpc]
}

resource "aws_security_group" "ansible-security-group" {
  name        = "ec2-ansible-group"
  description = "Allow communication with the msk cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}