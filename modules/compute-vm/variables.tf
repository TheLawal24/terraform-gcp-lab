variable "instance_name" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "zone" {
  type = string
}

variable "image" {
  type    = string
  default = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "disk_size" {
  type    = number
  default = 10
}

variable "network" {
  type    = string
  default = "default"
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "subnetwork" {
  type    = string
  default = null
}



variable "environment" {
  type = string
}

variable "enable_production_metadata" {
  type    = bool
  default = false
}

variable "deletion_protection" {
  type    = bool
  default = false
}
