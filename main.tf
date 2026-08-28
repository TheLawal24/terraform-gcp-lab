module "compute_vm" {
  source = "./modules/compute-vm"

  instance_name = var.instance_name
  machine_type  = local.selected_machine_type
  disk_size     = var.environment_config[var.environment].disk_size
  zone          = var.zone

  environment                = var.environment
  enable_production_metadata = var.environment == "prod"

  network    = google_compute_network.devops_vpc.id
  subnetwork = google_compute_subnetwork.devops_subnet.id

  labels = local.common_labels

  tags = ["terraform-lab"]
}
