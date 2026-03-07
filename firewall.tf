resource "google_compute_firewall" "devops_firewall" {

  name    = "devops-firewall"
  network = google_compute_network.panda_vpc.name

  allow {
    protocol = "tcp"
    ports = [
      "22",    # SSH
      "80",    # HTTP
      "443",   # HTTPS
      "8080",  # Jenkins
      "9000",  # SonarQube
      "8081"   # Nexus
    ]
  }

  source_ranges = ["0.0.0.0/0"]
}