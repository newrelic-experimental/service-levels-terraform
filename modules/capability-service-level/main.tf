terraform {
  # Require Terraform version 1.0 (recommended)
  required_version = "~> 1.0"

  # Require the latest 2.x version of the New Relic provider
  required_providers {
    newrelic = {
      source = "newrelic/newrelic"
    }
  }

}

#
# Latency SLO Creation
#

resource "newrelic_service_level" "sli_latency" {

  guid        = var.capability.app_guid
  name        = "${var.capability.capability_name} - ${var.capability.feature_name} - Latency (terraform)"
  description = "Proportion of requests that are served faster than ${var.capability.threshold_latency} seconds 95% of the time over a 7 day period."

  events {
    account_id = var.capability.account_id
    valid_events {
      from  = "Transaction"
      where = "entityGuid = '${var.capability.app_guid}' AND request.uri LIKE '${var.capability.request_uri}' AND (transactionType='Web')"
    }
    good_events {
      from  = "Transaction"
      where = "entityGuid = '${var.capability.app_guid}' AND request.uri LIKE '${var.capability.request_uri}' AND (transactionType='Web') AND duration < ${var.capability.threshold_latency}"
    }
  }

  objective {
    target = 95
    time_window {
      rolling {
        count = 7
        unit  = "DAY"
      }
    }
  }

}

#
# Latency SLO Alert Creation
#

resource "newrelic_nrql_alert_condition" "service_level_latency" {
  account_id                   = var.capability.account_id
  policy_id                    = var.capability.policy_id
  type                         = "static"
  name                         = newrelic_service_level.sli_latency.name
  description                  = "Alerts when SLO compliance falls below ${var.capability.threshold_latency}"
  enabled                      = true
  violation_time_limit_seconds = 259200

  nrql {
    query = "FROM Metric SELECT clamp_max(sum(newrelic.sli.good) / sum(newrelic.sli.valid) * 100, 100) as 'SLO compliance'  WHERE entity.guid = '${newrelic_service_level.sli_latency.sli_guid}'"
  }

  critical {
    operator              = "below"
    threshold             = 95
    threshold_duration    = 60
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 120
  aggregation_method = "event_flow"
  aggregation_delay  = 0
  slide_by           = 50
}

#
# Success SLO Creation
#


resource "newrelic_service_level" "sli_success" {

  guid        = var.capability.app_guid
  name        = "${var.capability.capability_name} - ${var.capability.feature_name} - Success (terraform)"
  description = "Proportion of requests that are successful ${var.capability.threshold_success}% of the time 7 day period."

  events {
    account_id = var.capability.account_id
    valid_events {
      from  = "Transaction"
      where = "entityGuid = '${var.capability.app_guid}' AND request.uri LIKE '${var.capability.request_uri}' AND (transactionType='Web')"
    }
    good_events {
      from  = "Transaction"
      where = "entityGuid = '${var.capability.app_guid}' AND request.uri LIKE '${var.capability.request_uri}' AND (transactionType='Web') AND error is false"
    }
  }

  objective {
    target = var.capability.threshold_success
    time_window {
      rolling {
        count = 7
        unit  = "DAY"
      }
    }
  }

}

#
# Success SLO Alert Creation
#

resource "newrelic_nrql_alert_condition" "service_level_success" {
  account_id                   = var.capability.account_id
  policy_id                    = var.capability.policy_id
  type                         = "static"
  name                         = newrelic_service_level.sli_success.name
  description                  = "Alerts when your SLO compliance falls below ${var.capability.threshold_success}"
  enabled                      = true
  violation_time_limit_seconds = 259200

  nrql {
    query = "FROM Metric SELECT clamp_max(sum(newrelic.sli.good) / sum(newrelic.sli.valid) * 100, 100) as 'SLO compliance'  WHERE entity.guid = '${newrelic_service_level.sli_success.sli_guid}'"
  }

  critical {
    operator              = "below"
    threshold             = var.capability.threshold_success
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 350
  aggregation_method = "event_flow"
  aggregation_delay  = 120
  slide_by           = 300
}

#
# Latency SLO Tags Creation
#

resource "newrelic_entity_tags" "slo_latency_tags" {

  depends_on = [
    newrelic_service_level.sli_latency
  ]

  guid = newrelic_service_level.sli_latency.sli_guid

  tag {
    key    = "product"
    values = [var.capability.product_name]
  }

  tag {
    key    = "capability"
    values = [var.capability.capability_name]
  }

  tag {
    key    = "feature"
    values = [var.capability.feature_name]
  }

  tag {
    key    = "terraform"
    values = ["true"]
  }

  tag {
    key = "having_fun"
    values = ["true"]
  }

}

#
# Success SLO Tags Creation
#

resource "newrelic_entity_tags" "slo_success_tags" {

  depends_on = [
    newrelic_service_level.sli_success
  ]

  guid = newrelic_service_level.sli_success.sli_guid

  tag {
    key    = "product"
    values = [var.capability.product_name]
  }

  tag {
    key    = "capability"
    values = [var.capability.capability_name]
  }

  tag {
    key    = "feature"
    values = [var.capability.feature_name]
  }

  tag {
    key    = "terraform"
    values = ["true"]
  }

}