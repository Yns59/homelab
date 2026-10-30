variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

variable "proxmox_host" {
  type = string
}

variable "bridge" {
  type        = string
  default     = "vmbr1"
  description = "Carte réseau Proxmox"
}



variable "started" {
  type        = bool
  default     = true
  description = "Démarrer automatiquement la VM après sa création"
}

variable "datastore_id" {
  type        = string
  default     = "local-lvm"
  description = "Nom du datastore Proxmox"
}

variable "template" {
  type        = number
  default     = 101
  description = "ID du template Proxmox à cloner"
}

variable "reseau" {
  type        = string
  default     = "10.20.10"
  description = "Préfixe du réseau (ex: 10.20.10)"
}

variable "gateway" {
  type        = string
    default     = "10.20.10.1"
  description = "Passerelle du réseau"
}

variable "node_name" {
  type        = string
  default     = "pve"
  description = "Nom du nœud Proxmox"
}

variable "username" {
  type        = string
  default     = "username"
  description = "Utilisateur Cloud-Init"
}


variable "ct_template" {
  type = number
  default = "107"
}

variable "ssh_public_key" {
  type        = string
  description = "Clé publique SSH"
  sensitive = true
}
