provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "all VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "node" {
  count = 7

  ami           = "ami-042e8287309f5df03" # Ubuntu 20.04 LTS
  instance_type = "t2.medium"

  tags = {
    Name = "Node-${count.index}"
    Role = count.index < 3 ? "server" : "client"
  }

  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  private_ip                  = "10.0.1.${count.index+10}"
  key_name                    = "nomad-terraform"
  vpc_security_group_ids      = [aws_security_group.allow_all.id]

  user_data = <<-EOF
              #!/bin/bash
              exec > >(tee /home/ubuntu/user_data.log) 2>&1
              sudo hostnamectl set-hostname Node-${count.index}
              sudo apt-get update -y
              sudo apt-get install -y unzip jq

              # Create consul user
              sudo useradd --system --home /etc/consul.d --shell /bin/false consul
              sudo mkdir --parents /etc/consul.d
              sudo mkdir --parents /var/consul
              sudo chown --recursive consul:consul /etc/consul.d
              sudo chown --recursive consul:consul /var/consul

              # Install Consul
              wget https://releases.hashicorp.com/consul/1.15.2/consul_1.15.2_linux_amd64.zip
              unzip consul_1.15.2_linux_amd64.zip
              sudo mv consul /usr/local/bin/
              sudo chmod 755 /usr/local/bin/consul
              sudo chown consul:consul /usr/local/bin/consul
              # Copy the Consul configuration file and systemd service file

              # Get private IP address
              private_ip=$(hostname -I | awk '{print $1}')
#Consul Template files
              if [ ${count.index} -eq 0 ]; then
                  echo "${file("${path.module}/consul-server.hcl.tpl")}" | sudo tee /etc/consul.d/consul.hcl
              elif [ ${count.index} -eq 1 ] || [ ${count.index} -eq 2 ]; then
                  echo "${file("${path.module}/consul-client.hcl.tpl")}" | sudo tee /etc/consul.d/consul.hcl
              else
                  echo "${file("${path.module}/consul-server-bootstrap.hcl.tpl")}" | sudo tee /etc/consul.d/consul.hcl
              fi
              echo "${file("${path.module}/consul.service")}" | sudo tee /etc/systemd/system/consul.service
           
              # Enable and start Consul
              sudo systemctl enable consul
              sudo systemctl start consul

              # Create nomad user
              sudo useradd --system --home /etc/nomad.d --shell /bin/false nomad
              sudo mkdir --parents /etc/nomad.d
              sudo mkdir --parents /var/nomad
              sudo chown --recursive nomad:nomad /etc/nomad.d
              sudo chown --recursive nomad:nomad /var/nomad

              # Install Nomad
              wget https://releases.hashicorp.com/nomad/1.5.5/nomad_1.5.5_linux_amd64.zip
              unzip nomad_1.5.5_linux_amd64.zip
              sudo mv nomad /usr/local/bin/
              sudo chmod 755 /usr/local/bin/nomad
              sudo chown nomad:nomad /usr/local/bin/nomad

              # Copy the Nomad configuration file and systemd service file
              echo "${file("${path.module}/nomad.hcl")}" | sudo tee /etc/nomad.d/nomad.hcl
              echo "${file("${path.module}/nomad.service")}" | sudo tee /etc/systemd/system/nomad.service
              # Enable and start Nomad
              sudo systemctl enable nomad
              sudo systemctl start nomad
              EOF
}
