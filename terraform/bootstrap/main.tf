terraform {
  required_version = ">=1.5.0"
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

resource "libvirt_volume" "debian12_base" {
  name   = "debian12-base-bootstrap.qcow2"
  pool   = "vm_pool"
  source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
  format = "qcow2"
}

resource "libvirt_volume" "utility_disk" {
  name           = "utility-disk.qcow2"
  pool           = "vm_pool"
  base_volume_id = libvirt_volume.debian12_base.id
  size           = 21474836480
  format         = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/cloud_init.cfg")
  vars = {
    admin_user = "sho"
    ssh_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILM/84tpkx+yYsA8Zr5or1xuELOGMl0JEP576SyUc9eC sho@bazzite"
  }
}

resource "libvirt_cloudinit_disk" "utility_init" {
  name      = "utility-init.iso"
  pool      = "vm_pool"
  user_data = data.template_file.user_data.rendered
  network_config = templatefile("${path.module}/templates/network_config.cfg.tpl", {
    interface_name = "ens3"
    ip_address     = "172.30.1.80"
    gateway_ip     = "172.30.1.254"
    dns_ip         = "172.30.1.85"
  })
}

resource "libvirt_domain" "utility_vm" {
  name   = "utility"
  memory = "2048"
  vcpu   = 2
  cpu { mode = "host-passthrough" }
  cloudinit = libvirt_cloudinit_disk.utility_init.id
  network_interface {
    bridge = "br0"
    mac    = "52:54:00:ee:ef:60"
  }
  disk { volume_id = libvirt_volume.utility_disk.id }
  
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
