resource "google_compute_instance" "terraform_vm" {
  name         = "terraform-devops-vm"
  machine_type = "e2-micro"
  zone         = "europe-west2-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }

  network_interface {
    network = "default"

    access_config {
    }
  }

  labels = {
    environment = "lab"
    managed_by  = "terraform"
  }

  tags = ["terraform-lab"]
}
