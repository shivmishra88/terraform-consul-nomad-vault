resource "aws_instance" "ec2" {
  count = 12
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  private_ip             = "${var.cnv_ip_range}${count.index+10}"
  tags = {
        Name = "CNV-${count.index}"
   #     Role = count.index < 3 ? "server" : "client"
        Role = count.index < 3 ? "server" : count.index < 7 ? "client" : "solr-dse"

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
              sudo apt-get install net-tools
              sudo apt-get install default-jdk -y
              sudo apt-get install bzip2
              sudo apt install -y awscli
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
              if [ ${count.index} -lt 7 ]; then
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
              
              else
                  echo "Nomad installed on 7 nodes"

              fi
              echo "Nomad installed"

              # Copy the Nomad configuration file and systemd service file
              if [ ${count.index} -eq 0 ]; then
                  echo "${file("${path.module}/../../nomad.bootstrap.hcl.tpl")}" | sudo tee /etc/nomad.d/nomad.hcl
                  echo "${file("${path.module}/../../nomad.service")}" | sudo tee /etc/systemd/system/nomad.service
              elif [ ${count.index} -eq 1 ] || [ ${count.index} -eq 2 ] ; then
                  echo "${file("${path.module}/../../nomad-server.hcl.tpl")}" | sudo tee /etc/nomad.d/nomad.hcl
                  echo "${file("${path.module}/../../nomad.service")}" | sudo tee /etc/systemd/system/nomad.service
              elif [ ${count.index} -ge 0 ] && [ ${count.index} -le 7 ]; then
                  echo "${file("${path.module}/../../nomad-clients.hcl.tpl")}" | sudo tee /etc/nomad.d/nomad.hcl
                  echo "${file("${path.module}/../../nomad.service")}" | sudo tee /etc/systemd/system/nomad.service
              # Enable and start Nomad
              sudo systemctl enable nomad
              sudo systemctl start nomad
              sudo service consul restart
              sudo service nomad restart
              fi
              echo "Nomad client and server done"


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
               #################################################Contiv########
                  wget https://github.com/contiv/netplugin/releases/download/1.2.0/netplugin-1.2.0.tar.bz2 -P /home/ubuntu
                  sudo tar xvf /home/ubuntu/netplugin-1.2.0.tar.bz2 -C /usr/local/bin/
                  sudo mkdir -p /var/log/contiv/
                  sudo touch /etc/systemd/system/netmaster.service
                  sudo touch /etc/systemd/system/netplugin.service
                  sudo apt install -y openvswitch-switch
              if [ ${count.index} -eq 0 ] || [ ${count.index} -eq 1 ] || [ ${count.index} -eq 2 ]; then
                  echo "${file("${path.module}/../../netmaster.service.tpl")}" | sudo tee /etc/systemd/system/netmaster.service
                  echo "${file("${path.module}/../../netplugin.service.tpl")}" | sudo tee /etc/systemd/system/netplugin.service
                  sudo service openvswitch-switch restart
                  sudo /usr/share/openvswitch/scripts/ovs-ctl restart
                  sudo service netmaster restart
                  sudo service netplugin restart
              elif [ ${count.index} -eq 3 ] || [ ${count.index} -eq 4 ] || [ ${count.index} -eq 5 ] || [ ${count.index} -eq 6 ]; then
                  echo "${file("${path.module}/../../netplugin.service.tpl")}" | sudo tee /etc/systemd/system/netplugin.service
                  sudo service openvswitch-switch restart
                  sudo /usr/share/openvswitch/scripts/ovs-ctl restart
                  sudo service netplugin restart
              else
                  echo "Else nothing"
              fi
                  echo "Installation has been done"
              #########################################Solr and Zk##########################
               if [ ${count.index} -ge 7 ] && [ ${count.index} -le 9 ]; then
                  wget https://archive.apache.org/dist/zookeeper/zookeeper-3.4.9/zookeeper-3.4.9.tar.gz -P /opt
                  sudo tar -xzf /opt/zookeeper-3.4.9.tar.gz -C /opt
                  sudo mv /opt/zookeeper-3.4.9 /opt/zookeeper
                  sudo mkdir -p /var/lib/zookeeper/data
                  sudo cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg
                  echo "${file("${path.module}/../../zoo.cfg.tpl")}" | sudo tee /opt/zookeeper/conf/zoo.cfg
                  
                if [ ${count.index} -eq 7 ]; then
                  sudo echo "1" > /var/lib/zookeeper/data/myid
                elif [ ${count.index} -eq 8 ]; then
                  sudo echo "2" > /var/lib/zookeeper/data/myid
                elif [ ${count.index} -eq 9 ]; then
                  sudo echo "3" > /var/lib/zookeeper/data/myid
                fi


                if [ ${count.index} -ge 7 ] && [ ${count.index} -le 9 ]; then
                  sudo /opt/zookeeper/bin/zkServer.sh start
                fi
                fi


               if [[ ${count.index} -ge 7 && ${count.index} -le 11 ]]; then
                  wget https://dlcdn.apache.org/lucene/solr/8.11.2/solr-8.11.2.tgz -P /opt
                  sudo tar -xzf /opt/solr-8.11.2.tgz -C /opt solr-8.11.2/bin/install_solr_service.sh --strip-components=2
                  sudo bash /opt/install_solr_service.sh /opt/solr-8.11.2.tgz
                  sudo /opt/solr/bin/solr stop  -p  8983
                  sudo /opt/solr/bin/solr start -c -s  /opt/solr/server/solr -p 8983 -z 10.0.1.17:2181,10.0.1.18:2181,10.0.1.19:2181 -noprompt -force
                  sudo echo "deb https://debian.datastax.com/enterprise/ stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
                  sudo curl -L https://debian.datastax.com/debian/repo_key | sudo apt-key add -
                  sudo apt-get update
                  sudo apt-get install dse-full -y
               else
                  echo "Installation is completed"
               fi
                  echo "Installation has been done"

              EOF
}
