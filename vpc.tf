module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = var.vpc_name
  cidr = "172.16.0.0/16"


  azs                          = var.availability_zones
  private_subnets              = ["172.16.0.0/20", "172.16.16.0/20", "172.16.32.0/20"]
  public_subnets               = ["172.16.48.0/22", "172.16.52.0/22", "172.16.56.0/22"]
  database_subnets             = ["172.16.80.0/20", "172.16.96.0/20", "172.16.112.0/20"]
  create_igw                   = true
  enable_nat_gateway = true
  one_nat_gateway_per_az = true
  create_database_subnet_route_table     = true
  database_dedicated_network_acl = true
  database_inbound_acl_rules = [
  {
    "cidr_block": "172.16.0.0/20",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  },
  {
    "cidr_block": "172.16.16.0/20",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 101,
    "to_port": 0
  },
  {
    "cidr_block": "172.16.32.0/20",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 102,
    "to_port": 0
  }
 ]

 database_outbound_acl_rules = [
  {
    "cidr_block": "172.16.0.0/20",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  },
  {
    "cidr_block": "172.16.16.0/20",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 101,
    "to_port": 0
  },
  {
    "cidr_block": "172.16.32.0/20",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 102,
    "to_port": 0
  }
]

tags = {
    Terraform = "true"
  }
}  