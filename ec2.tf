resource "aws_security_group" "ec2-security-group" {
  name        = "ec2-security-group"
  description = "Allow communication with the msk cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "http "
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.my_vpc.cidr_block]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.my_vpc.cidr_block]
  }


  egress {
    description = "Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_iam_role" "ec2-role" {
  name = "ec2-role"

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

resource "aws_iam_role_policy_attachment" "s3-full-access" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2-role.name
}

##################################################################################################

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh
}

##################################################################################################

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  count = length(module.vpc.private_subnets)
  name = "ec2-instance-${count.index}"

  instance_type          = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
  ami                    = "ami-0cf2b4e024cdb6960" #data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.generated_key.key_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.ec2-security-group.id]
  subnet_id              = module.vpc.private_subnets[count.index]

#  tags = {
#    Terraform   = "true"
#    Environment = "dev"
#  }

depends_on = [aws_security_group.ec2-security-group, module.vpc]

}

