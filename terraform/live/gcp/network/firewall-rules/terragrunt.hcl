include "state" {
  path = find_in_parent_folders("_backends/gcs.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/network/google//modules/firewall-rules//?version=9.0.0"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.env_vars.locals.env
  project_id = local.env_vars.locals.project_id
  region = local.env_vars.locals.region
}

dependency "network" {
  config_path = "../network"
}

inputs = {
    project_id   =  "${local.project_id}"
    network_name = dependency.network.outputs.network_name

    ingress_rules = [
      {
        name                    = "${local.env}-allow-de"
        priority                = 101
        ranges                  = null
        destination_ranges      = ["172.16.99.0/24"]
        source_ranges      = ["172.16.99.0/24"]
        allow = [
          {
          protocol = "all"
          ports    = null # all ports
          },
        ]
      },
      {
        name                    = "${local.env}-allow-ssh"
        priority                = 100
        source_ranges           = ["0.0.0.0/0"]
        allow = [
          {
          protocol = "tcp"
          ports    = ["22"]
          },
        ]
      },
    ]
}
