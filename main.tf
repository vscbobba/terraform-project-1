resource "aws_vpc" "project1_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "project1_vpc"
  }
}

resource "aws_internet_gateway" "Project1_IGW" {

  vpc_id = aws_vpc.project1_vpc.id
  tags = {
    Name = "project1_IGW"
  }
}

resource "aws_subnet" "project1_public" {
  vpc_id                  = aws_vpc.project1_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name        = "Public-subnet"
    description = "public subnet purpose"
  }
}

resource "aws_subnet" "project1_private" {
  vpc_id     = aws_vpc.project1_vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name        = "Private-subnet"
    description = "no internet"
  }
}
resource "aws_route_table" "example_rt" {
       vpc_id = aws_vpc.project1_vpc.id
       route {
          cidr_block = "0.0.0.0/0"
          gateway_id = aws_internet_gateway.Project1_IGW.id
       }
       tags = {
          Name = "Main"
       }
}
resource "aws_route_table_association" "a" {
        subnet_id      = aws_subnet.project1_public.id
        route_table_id = aws_route_table.example_rt.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.project1_vpc.id

  dynamic ingress {
    iterator = port
    for_each = var.port
    content{  
          description      = "TLS from VPC"
          from_port        = port.value
          to_port          = port.value
          protocol         = "tcp"
          cidr_blocks      = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "example_ec2" {
       ami = var.ami[0]
       instance_type = var.instance_type[0]
       key_name = "mykeyz"
       subnet_id = aws_subnet.project1_public.id
       vpc_security_group_ids = [aws_security_group.allow_tls.id]
       user_data = file("~/DEVOPS/AWS/terraform/userdata.tpl")
       tags = {
        Name = "example_ec2"
       }
       provisioner "file" {
          source      = "/home/venkat/DEVOPS/newfile.sh"
          destination = "/tmp/newfile.sh"
        }
        connection {
          type        = "ssh"
          user        = "ubuntu"             # Replace with your SSH user
          private_key = file("~/.ssh/id_ed25519")  # Replace with your private key path
          host  = self.public_ip
        }
        provisioner "remote-exec" {
              inline = [
                  "chmod +x /tmp/newfile.sh",
                  "/tmp/newfile.sh"
              ]
        }
}

