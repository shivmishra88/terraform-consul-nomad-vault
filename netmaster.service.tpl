[Unit]
Description=netmaster
Requires=network-online.target
After=network-online.target
[Service]
EnvironmentFile=-/etc/sysconfig/netmaster
Environment=GOMAXPROCS=2
Restart=on-failure
ExecStart="/usr/local/bin/netmaster --mode docker --netmode vlan --fwdmode bridge  --consul-endpoints http://$private_ip:8500"
ExecReload=/bin/kill -HUP
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
KillSignal=SIGINT
[Install]
WantedBy=multi-user.target
