data_dir = \"/var/nomad\"

advertise {
  http = \"$private_ip\"
  rpc  = \"$private_ip\"
  serf = \"$private_ip:5648\" # non-default ports may be specified
}

server {
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true
}

consul {
  address = \"127.0.0.1:8500\"
  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
}
