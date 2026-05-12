terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Create a custom VPC
resource "google_compute_network" "docker_vpc" {
  name                    = "docker-vpc"
  auto_create_subnetworks = false
}

# Create a subnet
resource "google_compute_subnetwork" "docker_subnet" {
  name          = "docker-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.docker_vpc.id
  region        = var.region
}

# External Firewall Rules
resource "google_compute_firewall" "docker_firewall_external" {
  name    = "docker-firewall-external"
  network = google_compute_network.docker_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "2376"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["docker-node"]
}

# Internal Firewall Rules (Swarm, Overlay, Consul)
resource "google_compute_firewall" "docker_firewall_internal" {
  name    = "docker-firewall-internal"
  network = google_compute_network.docker_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "2377", "7946", "8300", "8301", "8302", "8500", "8600"]
  }

  allow {
    protocol = "udp"
    ports    = ["4789", "7946", "8301", "8302", "8600"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.1.0/24"]
  target_tags   = ["docker-node"]
}

# Node A
resource "google_compute_instance" "node_a" {
  name         = "node-a"
  machine_type = var.gke_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.gke_disk_size_gb
      type  = var.gke_disk_type
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  network_interface {
    network    = google_compute_network.docker_vpc.name
    subnetwork = google_compute_subnetwork.docker_subnet.name
    access_config {
      # Ephemeral public IP
    }
  }

  tags = ["docker-node"]
}

# Node B
resource "google_compute_instance" "node_b" {
  name         = "node-b"
  machine_type = var.gke_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.gke_disk_size_gb
      type  = var.gke_disk_type
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  network_interface {
    network    = google_compute_network.docker_vpc.name
    subnetwork = google_compute_subnetwork.docker_subnet.name
    access_config {
      # Ephemeral public IP
    }
  }

  tags = ["docker-node"]
}
