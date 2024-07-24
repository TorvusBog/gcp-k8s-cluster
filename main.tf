provider "google" {
  project = "crack-atlas-418513"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_container_cluster" "primary" {
  name               = "primary-cluster"
  location           = "us-central1"
  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
}

output "kubeconfig" {
  value = google_container_cluster.primary.endpoint
}

output "client_certificate" {
  value = google_container_cluster.primary.master_auth.0.client_certificate
}

output "client_key" {
  value = google_container_cluster.primary.master_auth.0.client_key
}

output "cluster_ca_certificate" {
  value = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}

