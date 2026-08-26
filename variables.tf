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
