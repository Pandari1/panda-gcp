output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = google_compute_instance.jenkins.network_interface[0].access_config[0].nat_ip
}


output "cluster_name" {
  description = "GKE Cluster Name"
  value       = google_container_cluster.panda_cluster.name
}

output "cluster_endpoint" {
  description = "GKE API Endpoint"
  value       = google_container_cluster.panda_cluster.endpoint
}