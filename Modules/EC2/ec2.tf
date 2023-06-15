resource "aws_instance" "ec2" {
  count = 7
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  private_ip             = "${var.cnv_ip_range}${count.index+10}"
  tags = {
        Name = "CNV-${count.index}"
        Role = count.index < 3 ? "server" : "client"
    }
    root_block_device {
    volume_size = var.cnv_volume_size
    volume_type = "gp3"
    }
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
              echo "${file("${path.module}/../../docker.service.tpl")}" | sudo tee /lib/systemd/system/docker.service
              sudo systemctl daemon-reload
              sudo service docker restart
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
              
              #Consul Template files
              if [ ${count.index} -eq 0 ]; then
                  echo "${file("${path.module}/../../consul-server-bootstrap.hcl.tpl")}" | sudo tee /etc/consul.d/consul.hcl
              elif [ ${count.index} -eq 1 ] || [ ${count.index} -eq 2 ]; then
                  echo "${file("${path.module}/../../consul-server.hcl.tpl")}" | sudo tee /etc/consul.d/consul.hcl
              else
                  echo "${file("${path.module}/../../consul-client.hcl.tpl")}" | sudo tee /etc/consul.d/consul.hcl
              fi
              echo "${file("${path.module}/../../consul.service")}" | sudo tee /etc/systemd/system/consul.service
           
              # Enable and start Consul
              sudo systemctl enable consul
              sudo systemctl restart consul

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
                  echo "${file("${path.module}/../../nomad.bootstrap.hcl.tpl")}" | sudo tee /etc/nomad.d/nomad.hcl
              elif [ ${count.index} -eq 1 ] || [ ${count.index} -eq 2 ] ; then
                  echo "${file("${path.module}/../../nomad-server.hcl.tpl")}" | sudo tee /etc/nomad.d/nomad.hcl
              else
                  echo "${file("${path.module}/../../nomad-clients.hcl.tpl")}" | sudo tee /etc/nomad.d/nomad.hcl
              fi
              echo "${file("${path.module}/../../nomad.service")}" | sudo tee /etc/systemd/system/nomad.service
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
                  echo "${file("${path.module}/../../vault.hcl.tpl")}" | sudo tee /etc/vault.d/vault.hcl
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
                  echo "${file("${path.module}/../../vault.hcl.tpl")}" | sudo tee /etc/vault.d/vault.hcl
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
# #################Docker status###############################
#                  service docker status
#######################################Contiv#############
#              if [ ${count.index} -eq 1 ] || [ ${count.index} -eq 2 ] || [ ${count.index} -eq 3 ]; then
#                  sudo wget https://github.com/contiv/netplugin/releases/download/1.2.0/netplugin-1.2.0.tar.bz2
#                  sudo tar xvf netplugin-1.2.0.tar.bz2
#                  sudo cp netmaster /usr/local/bin/
#                  sudo cp netplugin /usr/local/bin/
#                  sudo cp netctl /usr/local/bin/
#                  echo "${file("${path.module}/../../netmaster.service.tpl")}" | sudo tee /etc/systemd/system/netmaster.service
#                  echo "${file("${path.module}/../../netplugin.service.tpl")}" | sudo tee /etc/systemd/system/netplugin.service
#                  sudo service netmaster restart
#                  sudo service netplugin restart                  
#              else
#                  sudo wget https://github.com/contiv/netplugin/releases/download/1.2.0/netplugin-1.2.0.tar.bz2
#                  sudo tar xvf netplugin-1.2.0.tar.bz2
#                  sudo cp netplugin /usr/local/bin/
#                  sudo cp netctl /usr/local/bin/
#                  echo "${file("${path.module}/../../netplugin.service.tpl")}" | sudo tee /etc/systemd/system/netplugin.service
#                  sudo service netplugin restart
#              else
#                  echo "Installation has been done"

              EOF
}
