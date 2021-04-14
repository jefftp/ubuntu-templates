# Declare variables
variable "username" {
  type = string
  default = "user"
}

variable "password" {
  type = string
  sensitive = true
  default = "password"
}

# Configure a source block for the Ubuntu base image
source "vmware-iso" "ubuntu-base-2004" {
  # ISO URL and checksum
  iso_url              = "https://releases.ubuntu.com/20.04.2/ubuntu-20.04.2-live-server-amd64.iso"
  iso_checksum         = "sha256:d1f2bf834bbe9bb43faf16f9be992a6f3935e65be0edece1dee2aa6eb1767423"

  # Basic VM details
  vm_name              = "ubuntu-base-2004"
  guest_os_type        = "ubuntu-64"

  # VM Hardware Config
  version              = "13"
  cores                = 1
  cpus                 = 1
  memory               = 1024
  disk_size            = 20000
  network_adapter_type = "VMXNET3"
  vmx_data = {
    "scsi0.virtualdev" = "pvscsi"
  }

  # Boot and config options
  boot_wait            = "5s"
  ssh_timeout          = "30m"
  ssh_username         = var.username
  ssh_password         = var.password
  boot_command         = [
    "<esc><esc><f6><esc><wait>",
    "<bs><bs><bs><bs><bs>",
    "autoinstall ds=nocloud-net;",
    "s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<wait><enter>"
  ]
  http_directory       = "http"
  shutdown_command     = "echo ${var.password} | sudo -S shutdown -P now"
}

build {
  sources = ["source.vmware-iso.ubuntu-base-2004"]

  provisioner "file" {
    source             = "files/etc_multipath.conf"
    destination        = "/tmp/etc_multipath.conf"
  }

  provisioner "shell" {
    execute_command    = "echo ${var.password} | sudo -S -E sh -eux '{{.Path}}'"
    script             = "files/setup-ubuntu2004.sh"
  }

  provisioner "shell" {
    execute_command    = "echo ${var.password} | sudo -S -E sh -eux '{{.Path}}'"
    script             = "files/cleanup-ubuntu2004.sh"
  }

  post-processor "shell-local" {
    inline = [
      "ovftool output-${source.name}/${source.name}.vmx ${source.name}-`date +%Y%m%d`.ova",
      "rm -rf output-${source.name}"
    ]
  }
}

