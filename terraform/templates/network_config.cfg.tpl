#cloud-config
version: 2
ethernets:
    eth0:
        dhcp4: no
        addresses:
            - ${ip_address}/24
        routes:
            - to: default
              via: ${gateway_ip}
        nameservers:
            addresses:
                - ${dns_ip}
                - 1.1.1.1
