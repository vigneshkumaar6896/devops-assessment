terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# -----------------------------
# VPC NETWORK
# -----------------------------
resource "google_compute_network" "vpc" {
  name                    = "devops-vpc"
  auto_create_subnetworks = true
}

# -----------------------------
# VPC ACCESS CONNECTOR
# -----------------------------
resource "google_vpc_access_connector" "connector" {
  name          = "devops-connector"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.8.0.0/28"
}

# -----------------------------
# CLOUD SQL (PUBLIC IP - SAFE VERSION)
# -----------------------------
resource "google_sql_database_instance" "db" {
  name             = "devops-sql"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true
    }
  }
}

# -----------------------------
# SECRET MANAGER
# -----------------------------
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"

  replication {
    auto {}
  }
}

# -----------------------------
# SERVICE ACCOUNT
# -----------------------------
resource "google_service_account" "run_sa" {
  account_id   = "cloudrun-sa"
  display_name = "Cloud Run Service Account"
}

# -----------------------------
# CLOUD RUN SERVICE
# -----------------------------
resource "google_cloud_run_service" "app" {
  name     = "devops-node-app"
  location = var.region

  template {
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.name
        "run.googleapis.com/vpc-access-egress"    = "all-traffic"
      }
    }

    spec {
      service_account_name = google_service_account.run_sa.email

      containers {
        image = "asia-south1-docker.pkg.dev/devsecops-assesment-2026/devops-repo/devops-node-app:v2"

        ports {
          container_port = 8080
        }

        env {
          name  = "NODE_ENV"
          value = "production"
        }
      }
    }
  }
}

# -----------------------------
# OUTPUTS
# -----------------------------
output "service_name" {
  value = google_cloud_run_service.app.name
}

output "vpc_connector" {
  value = google_vpc_access_connector.connector.name
}

output "cloud_run_url" {
  value = google_cloud_run_service.app.status[0].url
}