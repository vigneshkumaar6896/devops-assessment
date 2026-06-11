
# EMAIL NOTIFICATION 
resource "google_monitoring_notification_channel" "mail" {
  display_name = "DevOps Email Alert"
  type         = "email"

  labels = {
    email_address = "vigneshkumaar6896@gmail.com.com"
  }
}

# -----------------------------
# CPU ALERT POLICY
# -----------------------------
resource "google_monitoring_alert_policy" "cpu_high" {
  display_name = "High CPU Alert"
  combiner     = "OR"

  conditions {
    display_name = "CPU utilization > 70%"

    condition_threshold {
      filter     = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\""
      duration   = "60s"
      comparison = "COMPARISON_GT"

      threshold_value = 0.7

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.mail.id
  ]
}