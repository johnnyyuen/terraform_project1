provider "aws" {
    region = "us-east-1"
    access_key = aws_access_key
    secret_key = aws_secret_key
}

variable "subnet_prefix" {
  description = "cidr block for the subnet"
  #default = "10.0.1.0/24"
  #type = string
  #type = any
}

variable "pls_apply_with_awsid_tfvar" {
  description = "Please use -var-file= to apply"
}

variable "aws_access_key" {
  description = "the access key for AWS account - jj1010uk"
}

variable "aws_secret_key" {
  description = "the secret key for aws"
}



#resource "<provider>_<resource_type>" "name" {
#    config options......
#   key = "value"
#   key2 = "another value"
#}


#resource "aws_instance" "my1stServer" {
#    ami = "ami-09e67e426f25ce0d7"
#    instance_type = "t2.micro"#
#
#        tags = {
#            Name = "aUbuntu"
#        }
#    }

# 1. Create vpc
resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "productionVPC"
    }
}

# 2. Create internet gateway
resource "aws_internet_gateway" "gw-1" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod_internet_gateway"
  }
}

# resource "aws_internet_gateway" "gw-2" {
#   vpc_id = aws_vpc.prod-vpc.id

#   tags = {
#     Name = "prod_internet_gateway"
#   }
# }

# 3. Create Custom Route Table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-1.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw-1.id
  }
}

# 4. Create a subnet
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = var.subnet_prefix
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod-subnet"
  }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

# 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# 7. Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "web-server-nic-1" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}
resource "aws_network_interface" "web-server-nic-2" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.51"]
  security_groups = [aws_security_group.allow_web.id]

}

# 8. Assign an elastic IP to the network interface crated in step 7
resource "aws_eip" "web1-eip-1" {
  vpc      = true
  network_interface = aws_network_interface.web-server-nic-1.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw-1]
}

resource "aws_eip" "web2-eip-2" {
  vpc      = true
  network_interface = aws_network_interface.web-server-nic-2.id
  associate_with_private_ip = "10.0.1.51"
  depends_on = [aws_internet_gateway.gw-1]
}

output "server_resource_1" {
#  value = aws_eip.web1-eip-1.id
#  value = aws_eip.web1-eip-1.private_ip
  value = aws_eip.web1-eip-1.public_ip
}

 output "server_resource_2" {
#   value = aws_eip.web2-eip-2.id
#   value = aws_eip.web2-eip-2.private_ip
   value = aws_eip.web2-eip-2.public_ip
 }


# 9. Create Ubuntu server and install/enable apache

resource "aws_instance" "web-server-instance-1" {
   ami = "ami-09e67e426f25ce0d7"
   instance_type = "t2.micro"
   availability_zone = "us-east-1a"
   key_name = "main_key_jysnt"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-nic-1.id
  }

  user_data = "${file("install_apache.sh")}"

  tags = {
    Name = "Ubuntu web server-1"
    }
  }

  resource "aws_instance" "web-server-instance-2" {
   ami = "ami-09e67e426f25ce0d7"
   instance_type = "t2.micro"
   availability_zone = "us-east-1a"
   key_name = "main_key_jysnt"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-nic-2.id
  }

  user_data = "${file("install_apache.sh")}"

  tags = {
    Name = "Ubuntu web server-2"
    }
  }