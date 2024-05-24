# Propylon Test

This requires some basic setup to run the terraform 

Configure the aws credentials before running the Terraform Commands

AWS_ACCESS_KEY_ID  

AWS_SECRET_ACCESS_KEY  

AWS_DEFAULT_REGION = "us-west-2"  


Steps to get the required infrastructure 

1. terraform init
2. terraform plan -out plan.json
3. terraform apply plan.json

If received an error while running terraform apply plan.json run it without the plan.
4. terraform apply --auto-approve

# About the files
1. vpc.tf

This file creates the required VPC and the subnets .

a. 3 Public subnets 
b. 3 Private subnets 
c. 3 Database subnets
d. 3 nat gateways , one in each availbiity zone

This also creates NACLs to allow only private subnets to communicate with Database subnet.

2. ec2.tf

This file creates the required 3 EC2 instances in the private subnets

a. 3 EC2 instances 
b. Security Group for the insatnces 
c. IAM role and IAM profile for the instances to access the s3 
d. private key to connect to EC2 instances

3. alb.tf

This file creates the ALB load balancer , 2 listeners and the target group 

a. front-end ALB
b. target group with 3 EC2 instances 
c. 2 listeners 

4. s3.tf

This file creates the required S3 bucket that will be used by EC2 instances as static content storage for nginx. The bucket permissions are added so that ec2 instance can download files from s3 bucket.

a. S3 bucket 
b. S3 bucket permissions

5. ansible-control.tf

This file creates a EC2 instance which acts as the Ansible Control Node . This EC2 instance is used to connect to the nginx instances to install nginx and load the basic config files. Since the nginx EC2 instances are in the private subnets , this acts as Bastion host to connect to nginx instances.
 
 a. EC2 with Ansible installed on it
 b. Runs the ansible-playbook.yml on the Ansible instance

6. ansible directoy 

This directory contains the website files and ansible playboook file which would be run by Ansible in order install nginx and load the basic config files on to the nginx EC2 instances

7. cert-import.tf 

This creates a certificate for domain example.com and this certificate is imported into the AWS Certificate Manager to be used by the Application Load balancer 

8. inventory.tf 

This file creates 2 files 
a. First file is created in ansible directory called "hosts", this contains the IP addresses of the nginx EC2 
   instances.This file is used by Ansible as inventory where it needs to install nginx and load basic config
b. Second file is created inside .ssh directory , this is the private key used to connect to all the EC2 instances.  

9. backend-infra.tf

If we want to use S3 as backend and DynamoDB for locking the terraform state file , this creates the required infra for it.

a. S3 bucket for backend
b. DynamoDB table for locking mechanism.
