terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://${var.proxmox_host}:8006/"
  api_token = var.proxmox_api_token
  insecure  = true
}

locals {
  vms = {
    # Bloc Docker
    portainer = {
      vmid   = 102
      role   = "docker"
      cores  = 4
      memory = 6144
      disk   = 20
      ip     = 11
    }

    # Bloc Supervision
    supervision = {
      vmid   = 103
      role   = "monitoring"
      cores  = 2
      memory = 4096
      disk   = 30
      ip     = 12
    }

    # Bloc Kubernetes : 1 control plane + 2 workers (6 vCPU, 11 Go au total)
    k8s-control = {
      vmid   = 104
      role = "k8s-control-plane"
      cores  = 2
      memory = 3072
      disk   = 20
      ip     = 13
    }

    k8s-worker1 = {
      vmid   = 105
      role = "k8s-worker"
      cores  = 2
      memory = 4096
      disk   = 30
      ip     = 14
    }

    k8s-worker2 = {
      vmid   = 106
      role = "k8s-worker"
      cores  = 2
      memory = 4096
      disk   = 30
      ip     = 15
    }
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each = local.vms

  name      = each.key
  node_name = var.node_name
  vm_id   = each.value.vmid


  clone {
    vm_id = var.template
  }



  tags = ["terraform", each.value.role]

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = each.value.disk
  }

  network_device {
    bridge = var.bridge
  }
 

  initialization {
    user_account {
      username = var.username
      keys = [var.ssh_public_key]
    }
    
    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }

    ip_config {
      ipv4 {
        address = "${var.reseau}.${each.value.ip}/24"
        gateway = var.gateway
      }
    }
  }



  started = var.started
}

output "vm_ips" {
  value = {
    for vm, config in local.vms :
    vm => "${var.reseau}.${config.ip}"
  }
}




locals {
  containers = {
    crowdsec = {
      vm_id        = 200
      unprivileged = true
      cores        = 2
      disk         = 8
      memory       = 4096
      ip           = 16
    }
  }
}

resource "proxmox_virtual_environment_container" "container" {
  for_each = local.containers

  node_name    = var.node_name
  vm_id        = each.value.vm_id
  unprivileged = each.value.unprivileged

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = var.datastore_id
    size         = each.value.disk
  }

  initialization {
    hostname = each.key

    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }

    ip_config {
      ipv4 {
        address = "${var.reseau}.${each.value.ip}/24"
        gateway = var.gateway
      }
    }
  }

  network_interface {
    name   = "eth0"
    bridge = var.bridge
  }

  clone {
    vm_id = var.ct_template
  }
}


