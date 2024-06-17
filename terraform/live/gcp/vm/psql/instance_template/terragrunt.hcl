include "state" {
  path = find_in_parent_folders("_backends/gcs.hcl")
}

terraform {
    source = "tfr:///terraform-google-modules/vm/google//modules/instance_template?version=10.1.1"
}

dependency "network" {
 config_path = "../../../network/network"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.env_vars.locals.env
  project_id = local.env_vars.locals.project_id
  region = local.env_vars.locals.region
}

dependency "sa" {
  config_path = find_in_parent_folders("sa")

  mock_outputs = {
    email = "this@value.shouldbereplaced"
  }
}

inputs = {
  project_id                 = "${local.project_id}"
  name_prefix                = "${local.env}-psql"
  region                     = "${local.region}"
  zone                       = "${local.region}-a"
  subnetwork                 = "${local.env}-sapi-de"
  subnetwork_project         = "${local.project_id}"
  disk_size_gb               = 20
  disk_type                  = "pd-standard"
  machine_type               = "e2-custom-2-4096"
  source_image               = "ubuntu-2004-focal-v20231130"
  source_image_project       = "ubuntu-os-cloud"
  metadata                   = {
    user-data = <<EOT
    #cloud-config
    users:
      - default
    ssh_authorized_keys:
      - ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAA0DKHYgX1vrlriyRRGsEuApa6+SecrA5rfjrqKP7nrcors3Cp+IfbgIyQUcYpMYfLUZgxp17Skjecmx/qfSn88TgDqx233jsNFkpLhhcDJr1XkL4GPZrS8vjpAFy+cF4j4nKtGTx7OQCreCz5vRoVaplbocJ6lINgK4siTkrOKPjwHHg== echol0t@echol0t-Swift-SF313-52G
    fs_setup:
      - cmd: mkfs -t %(filesystem)s -L %(label)s %(device)s
        label: psql
        filesystem: 'xfs'
        device: '/dev/sdb'
    mounts:
      - [ /dev/sdb, /var/lib/postgresql, "auto", "defaults,nofail,comment=cloudconfig", "0", "0" ]
    EOT
  }
  service_account            = { 
    email  = dependency.sa.outputs.email
    scopes = ["cloud-platform"]
  }

  additional_disks = [
    {
      auto_delete  = true
      boot         = false
      disk_size_gb = 50
      disk_type    = "pd-standard"
      disk_name    = null
      device_name  = null
      disk_labels  = {}
    }
  ]

  tags = ["psql"]
}
