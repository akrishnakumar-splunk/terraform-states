data "vsphere_datacenter" "dc" {
  name = "Crest60"
}

data "vsphere_datastore" "datastore" {
  name          = "SeagateNASVol1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_host" "host" {
  name          = "10.0.1.248"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "${var.cluster_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template_from_ovf" {
  name          = "centos-7-fizzbuzz-vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "${var.instance_name}"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  host_system_id   = "${data.vsphere_host.host.id}"
  num_cpus         = "${var.cpu_count}"
  memory           = "${var.mem_in_mb}"
  guest_id         = "${data.vsphere_virtual_machine.template_from_ovf.guest_id}"

  scsi_type = "${data.vsphere_virtual_machine.template_from_ovf.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template_from_ovf.network_interface_types[0]}"
  }

  disk {
    name             = "disk0.vmdk"
    size             = "${data.vsphere_virtual_machine.template_from_ovf.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template_from_ovf.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template_from_ovf.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template_from_ovf.id}"
  }

  connection {
    type     = "ssh"
    user     = "root"
    password = "admin"
  }

  #   vapp {
  #     properties {
  #       "guestinfo.hostname"                        = "terraform-test.foobar.local"
  #       "guestinfo.interface.0.name"                = "ens192"
  #       "guestinfo.interface.0.ip.0.address"        = "10.0.0.100/24"
  #       "guestinfo.interface.0.route.0.gateway"     = "10.0.0.1"
  #       "guestinfo.interface.0.route.0.destination" = "0.0.0.0/0"
  #       "guestinfo.dns.server.0"                    = "10.0.0.10"
  #     }
  #   }
  provisioner "file" {
    source      = "networking-cfg.sh"
    destination = "/tmp/networking-cfg.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/networking-cfg.sh",
      "/tmp/networking-cfg.sh",
    ]
  }
}
