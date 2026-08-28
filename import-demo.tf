resource "google_compute_firewall" "managed_demo" {
  name    = "terraform-import-demo"
  network = google_compute_network.devops_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8888"]
  }

  source_ranges = [
    google_compute_subnetwork.devops_subnet.ip_cidr_range
  ]

  target_tags = ["terraform-lab"]
}
