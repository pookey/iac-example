provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-1"
}

provider "template" { }

data "aws_ami" "packerbuilt" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["pookey-base-*"]
  }
}

#resource "aws_spot_instance_request" "server_web" {
#  ami             = data.aws_ami.packerbuilt.image_id
#  instance_type   = "t2.micro"
#  spot_type       = "one-time"
#  subnet_id       = aws_subnet.my_subnet.id
# 
#  user_data       = data.template_cloudinit_config.config.rendered
#
#  security_groups = [
#    aws_security_group.allow_ssh.id,
#  ]
#
#  root_block_device {
#    volume_size = "10"
#  }
#}
#
data "template_file" "cloudinit_facter" {
  template = "${file("cloudinit_config_facter.yaml.tmpl")}"

  vars = {
    NODETYPE      = "webserver"
    PUPPET_BRANCH = "master"
  }
}

data "template_file" "cloudinit_bootstrap" {
  template = "${file("bootstrap.sh.tmpl")}"

  vars = {
    PUPPET_BRANCH = "master"
  }
}


data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Setup hello world script to be called by the cloud-config
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloudinit_facter.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.cloudinit_bootstrap.rendered
  }
}

resource "aws_instance" "web" {
  ami             = data.aws_ami.packerbuilt.image_id
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.my_subnet.id
  user_data       = data.template_cloudinit_config.config.rendered
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
  ]
  tags            = {
    Name = "HelloWorld"
  }
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "example_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id     = aws_vpc.example_vpc.id
  tags = {
    Name = "myIGW"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id     = aws_vpc.example_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "assoc1" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "172.16.10.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "my_subnet"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.example_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}

output "instance_ips" {
  value = [aws_instance.web.*.public_ip]
}
output "instance_ids" {
  value = [aws_instance.web.*.id]
}

