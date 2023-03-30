[![Community Project header](https://github.com/newrelic/opensource-website/raw/master/src/images/categories/Example_Code.png)](https://opensource.newrelic.com/oss-category/#community-project)

# Terraform for New Relic Service Levels

This terraform module (and example) is provided by the [New Relic OMA team](https://docs.newrelic.com/docs/new-relic-solutions/observability-maturity/introduction/) to help customers scale service level management best practices.

This terraform module is used in conjuction with [New Relic Observability Maturity best practices for Service Level Management](https://docs.newrelic.com/docs/new-relic-solutions/observability-maturity/uptime-performance-reliability/optimize-slm-guide/).

## Key Features

* Service boundary config by app and key transaction
* Product, capability, and feature tagging and naming convention via config
* Auto-creation of Latency and Success service levels
* Auto-creation of Latency and Success service level alerts

## Instructions

Requires [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

1. Clone repo
2. Copy `main-example.tf` to `main.tf`
3. Copy `terraform.tfvars.example` to `terraform.tfvars`
4. Run `terraform init`
5. Update your newrelic `account_id` and `api_key` in `main.tf` shown below
6. Update the `terraform.tfvars` file with your own capabilities config
7. Run `terraform plan` to test changes.
8. Run `terraform apply` to apply your config.
9. Run `terraform destroy` to remove all items created by your config.

``` terraform
provider "newrelic" {
  account_id = 0000000                            # Your New Relic account ID
  api_key    = "NRAK-****"                        # Your New Relic user key
  region     = "US"                               # US or EU (defaults to US)
}
```

### Adding Capability Service Levels in `terraform.tfvars`

#### Variables

 variable | purpose | example
--- | --- | ---
`products_map` | defines the service that capabilities will belong too | Acme Store
`capabilities_map` | defines capabilities that belong to a product | Login
`capabilities` | configs each feature that belongs to a capabitlity | SSO, Guest, Logout

* The `products_map` and `capabilities_map` are designed to help reduce human-error with spelling and/or case mistakes specifically with tags and naming conventions.
* Keys are numerical.
* Incriment keys accordingly. 
* Use the numerical key to reference the product and capability for each feature service level in the `capabilities` map.

The `terraform.tfvars.example` files demostrates how to use these variables and the config schema.

### Capability Map

key | description
--- | --- |
`unique_name` | can be any description and only used by terraform to ensure capabilitiy uniqueness
`account_id` | your New Relic account id where the service levels will be created
`product_name` | numerical reference to the `products_map` where you define your products (a.k.a business service)
`capability_name` | numerical reference to the `capabilities_map` where you define your capabilities
`feature_name` | short text description of your capability feature (a.k.a Search by customer ID, username login, submit application, etc...)
`app_name` | must match exactly the application name in New Relic
`app_guid` | your app_name guid found in your New Relic app metadata/tags
`request_uri` | NRQL LIKE string used to identify the transaction that supports your feature/capability in this app, for example "SELECT * WHERE request.uri LIKE **`'/api/login/%`**'"
`threshold_latency` | the threshold value in seconds to set the service level with the deifned `request_uri`. the service level will be set at 95% tolerance over a 7 day period
`threshold_success` | the success rate threshold for the `request_uri`. the service level will be set at that tolerance over a 7 day period for "error free" transactions.



