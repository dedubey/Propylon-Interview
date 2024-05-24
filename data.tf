data "aws_caller_identity" "current" {}

data "aws_vpc" my_vpc {
    id = module.vpc.vpc_id
    depends_on = [module.vpc]
}


######################################################################


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

#############################################################################


data "aws_acm_certificate" "alb_certificate" {
  domain = "example.com"
  key_types = ["RSA_4096"]
  depends_on = [aws_acm_certificate.certificate]
}

##############################################################################