terraform {
  required_version = ">=1.5.0"

  backend "s3" {
    bucket                      = "terraform-state"
    key                         = "workloads/terraform.tfstate"
    region                      = "main"
    endpoints                   = { s3 = "http://172.30.1.80:9000" }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://sho@172.30.1.200/system"
}

resource "libvirt_volume" "almalinux10_image" {
  name   = "almalinux10-base.qcow2"
  pool   = "vm_pool"
  source = "https://repo.almalinux.org/almalinux/10/cloud/x86_64/images/AlmaLinux-10-GenericCloud-latest.x86_64.qcow2"
  format = "qcow2"
}

resource "libvirt_volume" "debian12_image" {
  name   = "debian12-base.qcow2"
  pool   = "vm_pool"
  source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
  format = "qcow2"
}

resource "libvirt_volume" "freeipa_disk" {
  name           = "freeipa-disk.qcow2"
  pool           = "vm_pool"
  base_volume_id = libvirt_volume.almalinux10_image.id
  size           = 42949672960
  format         = "qcow2"
}

resource "libvirt_volume" "portfolio_disk" {
  name           = "portfolio-disk.qcow2"
  pool           = "vm_pool"
  base_volume_id = libvirt_volume.debian12_image.id
  size           = 10737418240
  format         = "qcow2"
}

resource "libvirt_volume" "minecraft_disk" {
  name           = "minecraft-disk.qcow2"
  pool           = "vm_pool"
  base_volume_id = libvirt_volume.debian12_image.id
  size           = 21474836480
  format         = "qcow2"
}

resource "libvirt_volume" "navidrome_disk" {
  name           = "navidrome-disk.qcow2"
  pool           = "vm_pool"
  base_volume_id = libvirt_volume.debian12_image.id
  size           = 16106127360
  format         = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/cloud_init.cfg")
  vars = {
    admin_user = "sho"
    ssh_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILM/84tpkx+yYsA8Zr5or1xuELOGMl0JEP576SyUc9eC sho@bazzite"
  }
}

resource "libvirt_cloudinit_disk" "freeipa_init" {
  name      = "freeipa-init.iso"
  pool      = "vm_pool"
  user_data = data.template_file.user_data.rendered
  network_config = templatefile("${path.module}/templates/network_config.cfg.tpl", {
    interface_name = "etho0"
    ip_address     = "172.30.1.85"
    gateway_ip     = "172.30.1.254"
    dns_ip         = "172.30.1.85"
  })
}

resource "libvirt_cloudinit_disk" "portfolio_init" {
  name      = "portfolio-init.iso"
  pool      = "vm_pool"
  user_data = data.template_file.user_data.rendered
  network_config = templatefile("${path.module}/templates/network_config.cfg.tpl", {
    interface_name = "ens3"
    ip_address     = "172.30.1.93"
    gateway_ip     = "172.30.1.254"
    dns_ip         = "172.30.1.85"
  })
}

resource "libvirt_cloudinit_disk" "minecraft_init" {
  name      = "minecraft-init.iso"
  pool      = "vm_pool"
  user_data = data.template_file.user_data.rendered
  network_config = templatefile("${path.module}/templates/network_config.cfg.tpl", {
    interface_name = "ens3"
    ip_address     = "172.30.1.91"
    gateway_ip     = "172.30.1.254"
    dns_ip         = "172.30.1.85"
  })
}

resource "libvirt_cloudinit_disk" "navidrome_init" {
  name      = "navidrome-init.iso"
  pool      = "vm_pool"
  user_data = data.template_file.user_data.rendered
  network_config = templatefile("${path.module}/templates/network_config.cfg.tpl", {
    interface_name = "ens3"
    ip_address     = "172.30.1.92"
    gateway_ip     = "172.30.1.254"
    dns_ip         = "172.30.1.85"
  })
}

resource "libvirt_domain" "freeipa_vm" {
  name   = "freeipa"
  memory = "3072"
  vcpu   = 2
  cpu { mode = "host-passthrough" }
  cloudinit = libvirt_cloudinit_disk.freeipa_init.id
  network_interface {
    bridge = "br0"
    mac    = "52:54:00:ee:ef:61"
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  disk { volume_id = libvirt_volume.freeipa_disk.id }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "portfolio_vm" {
  name   = "portfolio"
  memory = "1024"
  vcpu   = 1
  cpu { mode = "host-passthrough" }
  cloudinit = libvirt_cloudinit_disk.portfolio_init.id
  network_interface {
    bridge = "br0"
    mac    = "52:54:00:ee:ef:62"
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  disk { volume_id = libvirt_volume.portfolio_disk.id }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "minecraft_vm" {
  name   = "minecraft"
  memory = "6144"
  vcpu   = 2
  cpu { mode = "host-passthrough" }
  cloudinit = libvirt_cloudinit_disk.minecraft_init.id
  network_interface {
    bridge = "br0"
    mac    = "52:54:00:ee:ef:63"
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  disk { volume_id = libvirt_volume.minecraft_disk.id }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "navidrome_vm" {
  name   = "navidrome"
  memory = "1024"
  vcpu   = 1
  cpu { mode = "host-passthrough" }
  cloudinit = libvirt_cloudinit_disk.navidrome_init.id
  network_interface {
    bridge = "br0"
    mac    = "52:54:00:ee:ef:65"
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  disk { volume_id = libvirt_volume.navidrome_disk.id }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
