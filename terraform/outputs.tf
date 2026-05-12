output "node_a_public_ip" {
  description = "Public IP of Node A"
  value       = google_compute_instance.node_a.network_interface[0].access_config[0].nat_ip
}

output "node_b_public_ip" {
  description = "Public IP of Node B"
  value       = google_compute_instance.node_b.network_interface[0].access_config[0].nat_ip
}

output "node_a_private_ip" {
  description = "Private IP of Node A"
  value       = google_compute_instance.node_a.network_interface[0].network_ip
}

output "node_b_private_ip" {
  description = "Private IP of Node B"
  value       = google_compute_instance.node_b.network_interface[0].network_ip
}
