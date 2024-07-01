## Deploy GCP Infra 
1. gcloud auth login \
   gcloud auth application-default login
2. Update terraform/live/gcp/env.hcl with right project_id and region. 
   Specify your ssh public key in terraform/live/gcp/vm/psql/instance_template/terragrunt.hcl
3. export GITHUB_SHA=$(git rev-parse HEAD)
4. terragrunt run-all apply

## Deploy postgresql 
1. git clone https://github.com/vitabaks/postgresql_cluster.git ansible/postgresql_cluster
2. cp inventory ansible/postgresql_cluster \
   cp main.yml  ansible/postgresql_cluster/vars
3. python3 -m venv ansible/postgresql_cluster
4. cd ansible/postgresql_cluster && source bin/activate
5. pip install ansible
6. ansible all -m ping \
   ansible-playbook deploy_pgcluster.yml

## Run tests
   run_tests.sh

## System Diagram

<img width="660" alt="pic" src="https://github.com/EchoL0t/revapi/assets/59018133/60a9c2aa-17b6-437a-820f-08acd04e36af">




