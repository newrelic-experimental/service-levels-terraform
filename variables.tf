variable "products_map" {
  type = map(any)
}

variable "capabilities_map" {
  type = map(any)
}

variable "capabilities" {
  type = list(object({
    unique_name       = string
    account_id        = number
    product_name      = string
    capability_name   = string
    feature_name      = string
    app_name          = string
    app_guid          = string
    request_uri       = string
    threshold_success = number
    threshold_latency = number
    })
  )
}