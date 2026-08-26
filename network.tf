resource "google_compute_network" "devops_vpc" {
  name                    = "terraform-devops-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "devops_subnet" {
  name          = "terraform-devops-subnet"
  ip_cidr_range = "10.20.0.0/24"
  region        = var.region
  network       = google_compute_network.devops_vpc.id
}
