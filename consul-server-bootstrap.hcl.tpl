data_dir = \"/var/consul\"
server = true
bootstrap_expect = 3
ui = true
client_addr = \"0.0.0.0\"
advertise_addr = \"$private_ip\"
bind_addr = \"$private_ip\"
retry_interval = \"30s\"
