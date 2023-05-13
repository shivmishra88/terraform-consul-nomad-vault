provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_instance" "node" {
  count = 7

  ami           = "ami-042e8287309f5df03" # Ubuntu 20.04 LTS
  instance_type = "t2.medium"

  tags = {
    Name = "Node-${count.index}"
  }

  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  private_ip                  = "10.0.1.${count.index+10}"
  key_name                    = "nomad-terraform"

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y unzip jq

              # Create consul user
              sudo useradd --system --home /etc/consul.d --shell /bin/false consul
              sudo mkdir --parents /etc/consul.d
              sudo chown --recursive consul:consul /etc/consul.d

              # Install Consul
              wget https://releases.hashicorp.com/consul/1.10.1/consul_1.10.1_linux_amd64.zip
              unzip consul_1.10.1_linux_amd64.zip
              sudo mv consul /usr/local/bin/
              sudo chmod 755 /usr/local/bin/consul
              sudo chown consul:consul /usr/local/bin/consul
              # Copy the Consul configuration file and systemd service file
              echo '${file("${path.module}/consul.hcl")}' | sudo tee /etc/consul.d/consul.hcl
              echo '${file("${path.module}/consul.service")}' | sudo tee /etc/systemd/system/consul.service
              
              # Enable and start Consul
              sudo systemctl enable consul
              sudo systemctl start consul

              # Create nomad user
              sudo useradd --system --home /etc/nomad.d --shell /bin/false nomad
              sudo mkdir --parents /etc/nomad.d
              sudo chown --recursive nomad:nomad /etc/nomad.d

              # Install Nomad
              wget https://releases.hashicorp.com/nomad/1.1.2/nomad_1.1.2_linux_amd64.zip
              unzip nomad_1.1.2_linux_amd64.zip
              sudo mv nomad /usr/local/bin/
              sudo chmod 755 /usr/local/bin/nomad
              sudo chown nomad:nomad /usr/local/bin/nomad

              # Copy the Nomad configuration file and systemd service file
              echo '${file("${path.module}/nomad.hcl")}' | sudo tee /etc/nomad.d/nomad.hcl
              echo '${file("${path.module}/nomad.service")}' | sudo tee /etc/systemd/system/nomad.service
              # Enable and start Nomad
              sudo systemctl enable nomad
              sudo systemctl start nomad
              EOF
}
