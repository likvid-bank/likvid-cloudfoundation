data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}

resource "oci_audit_configuration" "audit_retention" {
  compartment_id        = var.tenancy_ocid
  retention_period_days = var.audit_retention_days
}

resource "oci_events_rule" "audit_log_events" {
  for_each = var.enable_audit_log_forwarding ? toset(["enabled"]) : toset([])

  compartment_id = var.foundation_compartment_ocid
  display_name   = "audit-log-critical-events"
  description    = "Capture critical security events from audit logs"
  is_enabled     = true

  condition = jsonencode({
    eventType = [
      "com.oraclecloud.identitycontrolplane.createuser",
      "com.oraclecloud.identitycontrolplane.deleteuser",
      "com.oraclecloud.identitycontrolplane.updateuser",
      "com.oraclecloud.identitycontrolplane.createpolicy",
      "com.oraclecloud.identitycontrolplane.deletepolicy",
      "com.oraclecloud.identitycontrolplane.updatepolicy",
    ]
  })

  actions {
    actions {
      action_type = "OSS"
      is_enabled  = true

      stream_id = var.audit_log_stream_id
    }
  }
}

resource "oci_vulnerability_scanning_host_scan_recipe" "default" {
  compartment_id = var.foundation_compartment_ocid
  display_name   = "default-host-scan-recipe"

  port_settings {
    scan_level = "STANDARD"
  }

  schedule {
    type        = "WEEKLY"
    day_of_week = "SUNDAY"
  }

  agent_settings {
    scan_level = "STANDARD"

    agent_configuration {
      vendor = "OCI"
    }
  }
}

resource "oci_vulnerability_scanning_container_scan_recipe" "default" {
  compartment_id = var.foundation_compartment_ocid
  display_name   = "default-container-scan-recipe"

  scan_settings {
    scan_level = "STANDARD"
  }
}
