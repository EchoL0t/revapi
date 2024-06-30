include "state" {
  path = find_in_parent_folders("_backends/gcs.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/lb-internal/google//?version=5.1.0"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.env_vars.locals.env
  project_id = local.env_vars.locals.project_id
  region = local.env_vars.locals.region
  backend_instance_groups = [
    {
      group       = "https://www.googleapis.com/compute/v1/projects/persuasive-axe-426422-e4/zones/europe-west3-a/instanceGroups/gcp-sqpi-psql-instance-group-001"
      description = ""
      failover    = false
    },
    {
      group       = "https://www.googleapis.com/compute/v1/projects/persuasive-axe-426422-e4/zones/europe-west3-b/instanceGroups/gcp-sqpi-psql-instance-group-002"
      description = ""
      failover    = false
    },
    {
      group       = "https://www.googleapis.com/compute/v1/projects/persuasive-axe-426422-e4/zones/europe-west3-c/instanceGroups/gcp-sqpi-psql-instance-group-003"
      description = ""
      failover    = false
    }
  ]
}

dependency "network" {
  config_path = "../../../network/network"
}

dependency "umig" {
  config_path = "../"
}

inputs = {
    project       =  "${local.project_id}"
    project_id    =  "${local.project_id}"
    region        = "${local.region}"
    name          =  "${local.env}-lb-psql"
    source_tags   = ["web", "psql"]
    target_tags   = ["psql", "web"]
    network       = "${dependency.network.outputs.network_name}"
    subnetwork    = "${local.env}-sapi-de"
    ports         = ["5432"]
    ip_address    = "172.16.99.40"
    global_access = true
    health_check = {
      type                = "http"
      host                = "1.2.3.4"
      request             = ""
      response            = ""
      check_interval_sec  = 5
      healthy_threshold   = 2
      timeout_sec         = 5
      unhealthy_threshold = 2
      proxy_header        = "NONE"
      port                = 8008
      port_name           = "health-check-port"
      request_path        = "/"
      enable_log          = false
    }
    backends = local.backend_instance_groups
}
