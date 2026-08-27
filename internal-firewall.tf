locals {
  internal_ports = {
    ssh   = "22"
    https = "443"
  }
}

resource "google_compute_firewall" "internal_services" {
  for_each = local.internal_ports

  name    = "${local.internal_firewall_prefix}-${each.key}"
  network = google_compute_network.devops_vpc.name

  allow {
    protocol = "tcp"
    ports    = [each.value]
  }

  source_ranges = [
    google_compute_subnetwork.devops_subnet.ip_cidr_range
  ]

  target_tags = ["terraform-lab"]
}
