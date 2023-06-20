datacenter = \"dc1\"
data_dir = \"/var/nomad\"
bind_addr = \"0.0.0.0\"
advertise {
  http = \"$private_ip:4646\"
  rpc  = \"$private_ip:4647\"
  serf = \"$private_ip:4648\"
}
server {
  enabled = true
  bootstrap_expect = 3
}
client {
  enabled = false
}
consul {
  address = \"127.0.0.1:8500\"
}
