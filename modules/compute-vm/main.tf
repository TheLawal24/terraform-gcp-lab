resource "google_compute_instance" "this" {
  name                      = var.instance_name
  machine_type              = var.machine_type
  zone                      = var.zone
  allow_stopping_for_update = true

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      labels
    ]
  }







  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
    }
  }


  labels = var.labels
  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    access_config {}
  }
  tags = var.tags
}
