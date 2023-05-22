data_dir = \"/var/consul\"
retry_join = [\"10.0.1.10\", \"10.0.1.11\", \"10.0.1.12\"]
client_addr = \"0.0.0.0\"
advertise_addr = \"$private_ip\"
bind_addr = \"$private_ip\"
retry_interval = \"30s\"