output vpc_id {
  value = module.vpc.vpc_id
}

output public_subnet {
    value = module.vpc.public_subnets
}

output private_ip {
    value = [for i in module.ec2_instance : i.private_ip]
}
