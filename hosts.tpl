[nginx_hosts]
%{ for private_ip in ec2-instances ~}
${private_ip}
%{ endfor ~}

[all:vars]
ansible_ssh_private_key_file=user2.pem
ansible_ssh_user=ubuntu