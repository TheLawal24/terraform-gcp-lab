variable "project_id" {
  type    = string
  default = "lawal-project-84096"
}

variable "region" {
  type    = string
  default = "europe-west2"
}

variable "zone" {
  type    = string
  default = "europe-west2-a"
}

variable "machine_type" {
  type    = string
  default = "e2-micro"
}

variable "instance_name" {
  type    = string
  default = "terraform-devops-vm"
}

variable "environment" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "environment_config" {
  type = map(object({
    machine_type = string
    disk_size    = number
  }))

  default = {
    dev = {
      machine_type = "e2-micro"
      disk_size    = 10
    }

    staging = {
      machine_type = "e2-small"
      disk_size    = 20
    }

    prod = {
      machine_type = "e2-medium"
      disk_size    = 30
    }
  }
}
