locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.env_vars.locals.env
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "gcs" {
    bucket                      = "sapi-tfstate"
    prefix                      = "${local.env}/${trimprefix(path_relative_to_include(), "../live/${local.env}/")}"
  }
}
  EOF
}
