packer {
  required_version = ">= 1.7.4"
  required_plugins {
    vsphere = {
      version = ">= v1.0.1"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

variable "vcenter_server" {
  type = string
}

variable "vcenter_username" {
  type = string
}

variable "vcenter_password" {
  type      = string
  sensitive = true
}

variable "datacenter" {
  type = string
}

variable "cluster" {
  type = string
}

variable "folder" {
  type = string
}

variable "datastore" {
  type = string
}

variable "vm_version" {
  type = string
}

variable "vm_cpu" {
  type = number
}

variable "vm_ram" {
  type = number
}

variable "vm_library" {
  type = string
}

variable "vm_disksize" {
  type = number
}

variable "windows_admin" {
  type = string
}

variable "server_network" {
  type = string
}

variable "content_library_path" {
  type = string
}

variable "windows_password" {
  type      = string
  sensitive = true
}

source "vsphere-iso" "windows" {
  # Target connection
  vcenter_server      = var.vcenter_server
  username            = var.vcenter_username
  password            = var.vcenter_password
  insecure_connection = true
  # Target environment
  datacenter = var.datacenter
  cluster    = var.cluster
  folder     = var.folder
  datastore  = var.datastore
  # Image build
  vm_version      = var.vm_version
  CPUs            = var.vm_cpu
  RAM             = var.vm_ram
  RAM_reserve_all = false
  content_library_destination {
    library = var.vm_library
    ovf     = true
    destroy = true
  }
  disk_controller_type = [
    "lsilogic-sas"
  ]
  storage {
    disk_size             = var.vm_disksize
    disk_thin_provisioned = true
  }
  guest_os_type = "windows9Server64Guest"
  network_adapters {
    network      = var.server_network
    network_card = "vmxnet3"
  }
  iso_paths = [
    var.content_library_path,
    # TODO: Replace this with content library
    # "[nfs_vsidata_ds1] ISO/Tools/windows.iso"
  ]
  notes = "Build date [ {{ isotime \"2006-01-02 15:04:05\" }} UTC ]"
  # Image deployment
  floppy_files = [
    "scripts/windows/2019/autounattend.xml",
    "scripts/windows/install-vmware-tools.cmd",
    "scripts/windows/deploy-bginfo.ps1",
    "scripts/windows/disable-network-discovery.cmd",
    "scripts/windows/install-chocolatey.ps1",
    "scripts/windows/configure-ansible.ps1"
  ]
  communicator    = "winrm"
  winrm_username  = var.windows_admin
  winrm_password  = var.windows_password
  winrm_use_ssl   = "true"
  winrm_insecure  = "true"
  winrm_timeout   = "6m"
  ip_wait_timeout = "2h"
}

build {
  name = "win2019"

  source "source.vsphere-iso.windows" {
    name    = "win2019"
    vm_name = var.vm_vmname
  }
}
