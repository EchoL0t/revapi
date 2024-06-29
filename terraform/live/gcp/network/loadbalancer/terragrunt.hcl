include "state" {
  path = find_in_parent_folders("_backends/gcs.hcl")
}

terraform {
  source = "tfr:///terraform-google-modules/lb-http/google//?version=11.1.0"
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

dependency "mig" {
  config_path = "../../vm/web"
}

inputs = {
    project_id   =  "${local.project_id}"
    name = "${local.env}-lb-sapi"
    target_tags = ["web"]
    firewall_networks = ["${dependency.network.outputs.network_name}"]

    backends = {
      default = {
  
        protocol    = "HTTP"
        port        = 80
        port_name   = "http"
        timeout_sec = 10
        enable_cdn  = false
  
        health_check = {
          request_path        = "/health"
          port                = 80
          healthy_threshold   = 3
          unhealthy_threshold = 2
        }
  
        log_config = {
          enable      = true
          sample_rate = 1.0
        }
  
        groups = [
          {
            group = "${dependency.mig.outputs.instance_group}"
          },
        ]
  
        iap_config = {
          enable = false
      }
    }
  }
}
