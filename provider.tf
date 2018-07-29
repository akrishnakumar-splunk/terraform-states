variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "instance_name" {}

variable "cpu_count" {
  default = 2
}

terraform {
  backend "s3" {
    bucket         = "vsph-states-bucket"
    access_key     = "AKIAJXD6DGP7KWNGBSUQ"
    secret_key     = "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"
    dynamodb_table = "vsph-tfstatelock"
    region         = "us-east-1"
    key            = "base"
  }
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

provider "aws" {
  version    = "~> 1.29"
  region     = "us-east-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}
