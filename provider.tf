variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "instance_name" {}

variable "cpu_count" {
  default = 2
}

variable "mem_in_mb" {
  default = 1024
}

variable "cluster_name" {
  default = "CrestCluser"
}

provider "vsphere" {
  version        = "~> 1.6"
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}
