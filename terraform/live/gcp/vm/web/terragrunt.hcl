include "state" {
  path = find_in_parent_folders("_backends/gcs.hcl")
}

terraform {
    source = "tfr:///terraform-google-modules/vm/google//modules/mig?version=11.1.0"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.env_vars.locals.env
  project_id = local.env_vars.locals.project_id
  region = local.env_vars.locals.region
}

dependency "instance_template" {
  config_path = "./instance_template"

  mock_outputs = {
    self_link = "/projects/${local.project_id}"
  }
}

inputs = {
  project                    = "${local.project_id}"
  project_id                 = "${local.project_id}"
  hostname                   = "${local.env}-sapi-autoscaler"
  region                     = "${local.region}"
  zone                       = "${local.region}-a"
  #  subnetwork                 = "${local.env}-sapi-de"
  #subnetwork_project         = "${local.project_id}"
  autoscaling_enabled        = true
  min_replicas               = 4
  max_replicas               = 8
  named_ports = [{
    name = "http",
    port = 80
  }]
  cooldown_period            = 200
  autoscaling_cpu            = [{
    target            = 0.9
    predictive_method = "NONE"
  }]
  update_policy              = [{
    type                           = "PROACTIVE"
    instance_redistribution_type   = "PROACTIVE"
    minimal_action                 = "RESTART"
    max_surge_fixed                = 0
    max_unavailable_fixed          = 3
    min_ready_sec                  = 50
    replacement_method             = "RECREATE"
    most_disruptive_allowed_action = "REPLACE"
    max_surge_percent              = null
    max_unavailable_percent        = null
  }]

  instance_template          = dependency.instance_template.outputs.self_link
}
