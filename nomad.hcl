data_dir = "/var/nomad"

advertise {
  http = "{{ GetInterfaceIP \"eth0\" }}"
  rpc  = "{{ GetInterfaceIP \"eth0\" }}"
  serf = "{{ GetInterfaceIP \"eth0\" }}:5648" # non-default ports may be specified
}

server {
  enabled          = true
  bootstrap_expect = 7
}

client {
  enabled = true
  servers = ["127.0.0.1:4647"]
}

consul {
  address = "127.0.0.1:8500"

  server_service_name = "nomad"
  client_service_name = "nomad-client"

  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
}
