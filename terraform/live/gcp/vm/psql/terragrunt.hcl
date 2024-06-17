include "state" {
  path = find_in_parent_folders("_backends/gcs.hcl")
}

terraform {
    source = "tfr:///terraform-google-modules/vm/google//modules/compute_instance?version=10.1.1"
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
  hostname                   = "${local.env}-sqpi-psql"
  region                     = "${local.region}"
  zone                       = "${local.region}-a"
  subnetwork                 = "${local.env}-sapi-de"
  subnetwork_project         = "${local.project_id}"
  num_instances              = 3
  instance_template          = dependency.instance_template.outputs.self_link
  static_ips = ["172.16.99.41", "172.16.99.42", "172.16.99.43"]
}
