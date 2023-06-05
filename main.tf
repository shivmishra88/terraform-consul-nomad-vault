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
    description = "All TCP from anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
              # Get private IP address
              private_ip=$(hostname -I | awk '{print $1}')
              ##########Install Docker###
              sudo apt install -y docker.io
              echo "${file("${path.module}/docker.service.tpl")}" | sudo tee /lib/systemd/system/docker.service
              sudo systemctl daemon-reload
              sudo service docker restart
        ######################################
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
              #Consul Template files
              if [ ${count.index} -eq 0 ]; then
                  echo "${file("${path.module}/consul-server-bootstrap.hcl.tpl")}" | sudo tee /etc/consul.d/consul.hcl
              elif [ ${count.index} -eq 1 ] || [ ${count.index} -eq 2 ]; then
                  echo "${file("${path.module}/consul-server.hcl.tpl")}" | sudo tee /etc/consul.d/consul.hcl
              else
                  echo "${file("${path.module}/consul-client.hcl.tpl")}" | sudo tee /etc/consul.d/consul.hcl
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
              if [ ${count.index} -eq 0 ]; then
                  echo "${file("${path.module}/nomad.bootstrap.hcl.tpl")}" | sudo tee /etc/nomad.d/nomad.hcl
              elif [ ${count.index} -eq 1 ] || [ ${count.index} -eq 2 ] ; then
                  echo "${file("${path.module}/nomad-server.hcl.tpl")}" | sudo tee /etc/nomad.d/nomad.hcl
              else
                  echo "${file("${path.module}/nomad-clients.hcl.tpl")}" | sudo tee /etc/nomad.d/nomad.hcl
              fi
              echo "${file("${path.module}/nomad.service")}" | sudo tee /etc/systemd/system/nomad.service
              # Enable and start Nomad
              sudo systemctl enable nomad
              sudo systemctl start nomad
              sudo service consul restart
              sudo service nomad restart
              # Install Vault
              if [ ${count.index} -eq 0 ]; then
                  echo "Installing Vault on Node-0..."
                  # Create vault user
                  sudo useradd --system --home /etc/vault.d --shell /bin/false vault
                  sudo mkdir --parents /etc/vault.d
                  sudo chown --recursive vault:vault /etc/vault.d
                  sudo curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
                  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
                  sudo apt-get update && sudo apt-get install vault -y
                  echo "${file("${path.module}/vault.hcl.tpl")}" | sudo tee /etc/vault.d/vault.hcl
                  sudo service vault restart
                  export VAULT_ADDR=http://127.0.0.1:8200
                  export VAULT_SKIP_VERIFY=true
                  vault operator init -key-shares=3 -key-threshold=2 > /home/ubuntu/vault_init.txt
                  UNSEAL_KEY_1=$(cat /home/ubuntu/vault_init.txt | grep "Unseal Key 1:" | awk '{print $NF}')
                  UNSEAL_KEY_2=$(cat /home/ubuntu/vault_init.txt | grep "Unseal Key 2:" | awk '{print $NF}')
                  ROOT_TOKEN=$(cat /home/ubuntu/vault_init.txt | grep "Initial Root Token:" | awk '{print $NF}')
                  # Unseal Vault with two keys
                  vault operator unseal $UNSEAL_KEY_1
                  vault operator unseal $UNSEAL_KEY_2
                  cd /home/ubuntu
                  consul kv put vault_init.txt @/home/ubuntu/vault_init.txt
              ##########################Node-1 and Node-2####
              elif [ ${count.index} -eq 1 ] || [ ${count.index} -eq 2 ]; then
                  echo "Installing Vault on Node-1 and Node-2..."
                  #####
                  sudo useradd --system --home /etc/vault.d --shell /bin/false vault
                  sudo mkdir --parents /etc/vault.d
                  sudo chown --recursive vault:vault /etc/vault.d
                  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
                  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
                  sudo apt-get update && sudo apt-get install vault -y
                  echo "${file("${path.module}/vault.hcl.tpl")}" | sudo tee /etc/vault.d/vault.hcl
                  sudo service vault restart
                  sleep 120
                  consul kv get vault_init.txt
                  consul kv get vault_init.txt > /home/ubuntu/vault_init.txt
                  export VAULT_ADDR=http://127.0.0.1:8200
                  export VAULT_SKIP_VERIFY=true
                  UNSEAL_KEY_1=$(cat /home/ubuntu/vault_init.txt | grep "Unseal Key 1:" | awk '{print $NF}')
                  UNSEAL_KEY_2=$(cat /home/ubuntu/vault_init.txt | grep "Unseal Key 2:" | awk '{print $NF}')
                  # Unseal Vault with two keys
                  vault operator unseal $UNSEAL_KEY_1
                  vault operator unseal $UNSEAL_KEY_2
              else
                  echo "Else nothing"
              fi
                  echo "Installation has been done"
                  #sudo service consul restart
                  #sleep 3
                  #sudo service nomad restart
                  #sleep 3
                  #sudo service vault restart
              EOF
}
