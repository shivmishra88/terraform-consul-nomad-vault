datacenter = \"dc1\"
data_dir = \"/var/nomad\"
bind_addr = \"0.0.0.0\"

advertise {
  http = \"$private_ip:4646\"
  rpc  = \"$private_ip:4647\"
  serf = \"$private_ip:4648\"
}

server {
  enabled          = false
}

client {
  enabled = true
  servers = [\"10.0.1.10:4647\", \"10.0.1.11:4647\", \"10.0.1.12:4647\"]
}

consul {
  address = \"127.0.0.1:8500\"
}
