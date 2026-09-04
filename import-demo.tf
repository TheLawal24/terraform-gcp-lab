resource "google_compute_firewall" "managed_demo" {
  name    = "terraform-import-demo"
  network = module.network.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["8888"]
  }

  source_ranges = [
    module.network.subnet_cidr
  ]

  target_tags = ["terraform-lab"]
}
