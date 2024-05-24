resource "local_file" "hosts_cfg" {
  content = templatefile("./hosts.tpl",
    {
      ec2-instances = [for i in module.ec2_instance : i.private_ip]
    }
  )
  filename = "./ansible/hosts"
}

resource "local_sensitive_file" "pem_file" {
  filename = pathexpand("./.ssh/${var.key_name}.pem")
  file_permission = "600"
  directory_permission = "700"
  content = tls_private_key.ec2_key.private_key_pem
}
