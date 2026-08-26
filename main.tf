module "compute_vm" {
  source = "./modules/compute-vm"

  instance_name = var.instance_name
  machine_type  = var.machine_type
  zone          = var.zone

  network    = google_compute_network.devops_vpc.id
  subnetwork = google_compute_subnetwork.devops_subnet.id

  labels = {
    environment = "lab"
    managed_by  = "terraform"
    owner       = "devops-training"
  }

  tags = ["terraform-lab"]
}
