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

provider "newrelic" {
  account_id = 0000000                            # Your New Relic account ID
  api_key    = "NRAK-****"                        # Your New Relic user key
  region     = "US"                               # US or EU (defaults to US)
}

resource "newrelic_alert_channel" "alert_channel_slack" {
  name = "slack-integration"
  type = "slack"

  config {
    url     = "<YOUR_SLACK_INTEGRATION_URL>"
    channel = "<YOUR_SLACK_CHANNEL_NAME>"
  }
}

resource "newrelic_alert_policy" "service_levels_policy" {
  name                = "Service Levels - terraform"
  incident_preference = "PER_CONDITION"
}

resource "newrelic_alert_policy_channel" "service_levels_channels" {
  policy_id   = newrelic_alert_policy.service_levels_policy.id
  channel_ids = [newrelic_alert_channel.alert_channel_slack.id]
}


module "service_levels" {
  providers = {
    newrelic = "newrelic"
  }
  source   = "./modules/capability-service-level"
  for_each = { for index, sli in var.capabilities : sli.unique_name => sli }
  capability = {
    unique_name       = each.value.unique_name
    account_id        = each.value.account_id
    product_name      = lookup(var.products_map, each.value.product_name)
    capability_name   = lookup(lookup(var.capabilities_map, each.value.product_name), each.value.capability_name)
    feature_name      = each.value.feature_name
    app_name          = each.value.app_name
    app_guid          = each.value.app_guid
    request_uri       = each.value.request_uri
    threshold_latency = each.value.threshold_latency
    threshold_success = each.value.threshold_success
    policy_id         = newrelic_alert_policy.service_levels_policy.id
  }
}


