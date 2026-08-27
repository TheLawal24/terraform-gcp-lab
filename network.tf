resource "google_compute_network" "devops_vpc" {
  name                    = local.vpc_name
  auto_create_subnetworks = false

  lifecycle {
    precondition {
      condition = (
        (terraform.workspace == "default" && var.environment == "dev") ||
        (terraform.workspace != "default" && terraform.workspace == var.environment)
      )

      error_message = "Workspace and environment do not match. Use default for dev, staging for staging, and prod for prod."
    }
  }
}

resource "google_compute_subnetwork" "devops_subnet" {
  name          = local.subnet_name
  ip_cidr_range = var.environment_config[var.environment].subnet_cidr
  region        = var.region
  network       = google_compute_network.devops_vpc.id
}
