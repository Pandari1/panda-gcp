# -----------------------------
# Provider
# -----------------------------
provider "google" {
  credentials = file("credentials/panda-terraform-key.json")
  project     = "learning-487000"
  region      = "us-central1"
  zone        = "us-central1-a"
}

# -----------------------------
# VPC
# -----------------------------
resource "google_compute_network" "panda_vpc" {
  name                    = "panda-vpc"
  auto_create_subnetworks = false
}

# -----------------------------
# Subnet
# -----------------------------
resource "google_compute_subnetwork" "panda_subnet" {
  name          = "panda-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.panda_vpc.id
}

# -----------------------------
# Firewall
# -----------------------------
resource "google_compute_firewall" "cluster_firewall" {
  name    = "cluster-firewall"
  network = google_compute_network.panda_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080","8081" ,"9000"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# -----------------------------
# Service Account
# -----------------------------
resource "google_service_account" "gke_service_account" {
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
}

# -----------------------------
# Jenkins VM (Public)
# -----------------------------
resource "google_compute_instance" "jenkins" {

  name         = "jenkins"
  machine_type = "e2-standard-2"

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
    }
  }

  network_interface {
    network    = google_compute_network.panda_vpc.id
    subnetwork = google_compute_subnetwork.panda_subnet.id

    access_config {}
  }
}

# -----------------------------
# SonarQube VM
# -----------------------------
resource "google_compute_instance" "sonarqube" {

  name         = "sonarqube"
  machine_type = "e2-medium"

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 25
    }
  }

  network_interface {
    network    = google_compute_network.panda_vpc.id
    subnetwork = google_compute_subnetwork.panda_subnet.id
  }
}

# -----------------------------
# Nexus VM
# -----------------------------
resource "google_compute_instance" "nexus" {

  name         = "nexus"
  machine_type = "e2-medium"

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 25
    }
  }

  network_interface {
    network    = google_compute_network.panda_vpc.id
    subnetwork = google_compute_subnetwork.panda_subnet.id
  }
}

# -----------------------------
# Monitoring VM
# -----------------------------
resource "google_compute_instance" "monitor" {

  name         = "monitor"
  machine_type = "e2-medium"

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 25
    }
  }

  network_interface {
    network    = google_compute_network.panda_vpc.id
    subnetwork = google_compute_subnetwork.panda_subnet.id
  }
}

# -----------------------------
# GKE Cluster
# -----------------------------
resource "google_container_cluster" "panda_cluster" {

  name     = "panda-gke-cluster"
  location = "us-central1"

  deletion_protection = false

  network    = google_compute_network.panda_vpc.name
  subnetwork = google_compute_subnetwork.panda_subnet.name

  networking_mode = "VPC_NATIVE"

  remove_default_node_pool = true
  initial_node_count       = 1

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
  }
}

# -----------------------------
# Node Pool
# -----------------------------
resource "google_container_node_pool" "panda_nodes" {

  name     = "panda-node-pool"
  cluster  = google_container_cluster.panda_cluster.name
  location = "us-central1"

  node_count = 1

  node_config {

    machine_type = "e2-medium"

    service_account = google_service_account.gke_service_account.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}