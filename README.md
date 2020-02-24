Infrastructure As Code Example
==============================

This example uses Packer to build a base AMI based off Amazon Linux 2.

It then bootstraps this AMI using puppet.

The Terraform example creates a VPC and a single instance in it, using cloud-init
to apply puppet specific to that nodettype


``
cd packer
wget https://releases.hashicorp.com/packer/1.5.4/packer_1.5.4_darwin_amd64.zip
unzip packer_1.5.4_darwin_amd64.zip

cd ../terraform/
wget https://releases.hashicorp.com/terraform/0.12.21/terraform_0.12.21_darwin_amd64.zip
unzip terraform_0.12.21_darwin_amd64.zip
./terraform init
``
