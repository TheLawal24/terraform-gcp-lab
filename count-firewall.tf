locals {
  count_ports = ["8080", "9090"]
}

resource "google_compute_firewall" "count_demo" {
  count = length(local.count_ports)

  name    = "${local.count_firewall_prefix}-${local.count_ports[count.index]}"
  network = google_compute_network.devops_vpc.name

  allow {
    protocol = "tcp"
    ports    = [local.count_ports[count.index]]
  }

  source_ranges = [
    google_compute_subnetwork.devops_subnet.ip_cidr_range
  ]

  target_tags = ["terraform-lab"]
}
