data_dir = "/var/consul"
server = true
bootstrap_expect = 7

retry_join = ["10.0.1.10", "10.0.1.11", "10.0.1.12", "10.0.1.13", "10.0.1.14", "10.0.1.15", "10.0.1.16"]

ui = true
client_addr = "0.0.0.0"
