*** Deploy GCP Infra ***
1. gcloud auth login \
   gcloud auth application-default login
2. Update terraform/live/gcp/env.hcl with right project_id and region
3. terragrunt run-all plan \
   terragrunt run-all apply

*** Deploy postgresql ***
1. cp inventory ansible/postgresql_cluster \
   cp main.yml  ansible/postgresql_cluster/vars
2. python3 -m venv ansible/postgresql_cluster
3. cd ansible/postgresql_cluster && source bin/activate
4. pip install ansible
5. ansible all -m ping \
   ansible-playbook deploy_pgcluster.yml





