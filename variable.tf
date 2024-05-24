variable "region" {
  type        = string
  description = "The AWS region."
  default     = "us-west-2"
}

variable "vpc_name" {
  type        = string
  description = "VPC NAME."
  default     = "my-vpc"
}

variable "availability_zones" {
  type  =  list(string)
  description = " Availability zone"
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "instance_type" {
  type = string
  description = "Instance Type"
  default = "t2.micro"
}

variable "key_name" {
  type = string
  description = "private key name"
  default = "user2"
}

variable "common_name" {
  type = string
  description = "private key name"
  default = "example.com"
}