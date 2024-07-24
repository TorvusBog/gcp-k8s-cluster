provider "google" {
  project = "crack-atlas-418513"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_network" "vpc_network" {
  name                    = "k8s-vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = "k8s-subnetwork"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

resource "google_container_cluster" "primary" {
  name               = "primary-cluster"
  location           = "us-central1"
  initial_node_count = 1

  network    = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.subnetwork.name

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.0.0.0/28"  # Reserved private IP range
      display_name = "Internal Network"
    }
  }

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
    disk_size_gb = 50  # Adjusted disk size to reduce SSD quota requirement
    disk_type    = "pd-standard"  # Using standard disk instead of SSD
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
    disk_size_gb = 50  # Adjusted disk size to reduce SSD quota requirement
    disk_type    = "pd-standard"  # Using standard disk instead of SSD
  }
}

output "kubeconfig" {
  value = google_container_cluster.primary.endpoint
}

output "client_certificate" {
  value = google_container_cluster.primary.master_auth.0.client_certificate
  sensitive = true  # Marked as sensitive
}

output "client_key" {
  value = google_container_cluster.primary.master_auth.0.client_key
  sensitive = true  # Marked as sensitive
}

output "cluster_ca_certificate" {
  value = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
  sensitive = true  # Marked as sensitive
}
