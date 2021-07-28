terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("gcp.json")

  project = "rkhl-tazik"
  region  = "europe-central2"
  zone    = "europe-central2-a"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

// allowing ssh-connect
resource "google_compute_firewall" "ssh-rule" {
  name    = "ssh"
  network = google_compute_network.vpc_network.name
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
}

// creating default network
resource "google_compute_network" "default" {
  name = "test-network"
}

// creating data-variable
data "template_file" "default" {
  template = "${file("start.sh")}"
  vars = {
    address = "some value"
  }
}

// creating srany tazik
resource "google_compute_instance" "vm_instance" {
  name         = "try-hard"
  machine_type = "e2-small"

  tags = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210720"
    }
  }

// adding ssh-key
  metadata = {
   ssh-keys = "root:${file("~/.ssh/id_rsa.pub")}"
 }

// creating of metadata startup script and adding into VM
  metadata_startup_script = "${file("start.sh")}"

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}



