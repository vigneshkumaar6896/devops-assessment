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
# VPC CONNECTOR
# -----------------------------
resource "google_vpc_access_connector" "connector" {
  name          = "devops-connector"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.8.0.0/28"
}

# -----------------------------
# CLOUD SQL INSTANCE
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
# SERVICE ACCOUNT
# -----------------------------
resource "google_service_account" "run_sa" {
  account_id   = "cloudrun-sa"
  display_name = "Cloud Run SA"
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

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = "Devops@12345"
}

# -----------------------------
# IAM - SECRET ACCESS
# -----------------------------
resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.run_sa.email}"
}

# -----------------------------
# IAM - CLOUD SQL ACCESS
# -----------------------------
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.run_sa.email}"
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
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.id
        "run.googleapis.com/vpc-access-egress"    = "all-traffic"

        # CLOUD SQL CONNECTION 
        "run.googleapis.com/cloudsql-instances" = "devsecops-assesment-2026:asia-south1:devops-sql"
      }
    }

    spec {
      service_account_name = google_service_account.run_sa.email

      containers {
        image = "asia-south1-docker.pkg.dev/devsecops-assesment-2026/devops-repo/devops-node-app:v4"

        ports {
          container_port = 8080
        }

        env {
          name  = "NODE_ENV"
          value = "production"
        }

        # -----------------------------
        # CLOUD SQL SOCKET CONFIG
        # -----------------------------
        env {
          name  = "INSTANCE_CONNECTION_NAME"
          value = "devsecops-assesment-2026:asia-south1:devops-sql"
        }

        env {
          name  = "DB_USER"
          value = "appuser"
        }

        env {
          name  = "DB_NAME"
          value = "appdb"
        }

        env {
          name  = "DB_PASSWORD"
          value = "Devops@12345"
        }

        env {
          name  = "DB_PORT"
          value = "5432"
        }
      }
    }
  }
}

# -----------------------------
# NOTIFICATION CHANNEL
# -----------------------------
resource "google_monitoring_notification_channel" "mail" {
  display_name = "DevOps Email"
  type         = "email"

  labels = {
    email_address = "vigneshkumaar6896@gmail.com"
  }
}

# -----------------------------
# CPU ALERT
# -----------------------------
resource "google_monitoring_alert_policy" "cpu_alert" {
  display_name = "Cloud Run CPU High"
  combiner     = "OR"
  project      = var.project_id

  conditions {
    display_name = "CPU Usage"

    condition_threshold {
      filter          = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/container/cpu/utilizations\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0.7
      duration        = "60s"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_MEAN"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.mail.id
  ]
}

# -----------------------------
# MEMORY ALERT
# -----------------------------
resource "google_monitoring_alert_policy" "memory_alert" {
  display_name = "Cloud Run Memory High"
  combiner     = "OR"
  project      = var.project_id

  conditions {
    display_name = "Memory Usage"

    condition_threshold {
      filter          = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/container/memory/utilizations\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      duration        = "60s"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_MEAN"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.mail.id
  ]
}

# -----------------------------
# OUTPUT
# -----------------------------
output "cloud_run_url" {
  value = google_cloud_run_service.app.status[0].url
}