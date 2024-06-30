#!/bin/bash

sudo apt update

# Install Python 3.8 and git
sudo apt -y install python3.8 python3.8-venv python3.8-dev git

# Clone the repository (replace <REPO_URL> with the actual URL of your repository)
REPO_URL="https://github.com/EchoL0t/revapi.git"
REPO_DIR="/srv/revapi"
git clone $REPO_URL $REPO_DIR

# Change to the repository directory
cd $REPO_DIR

# Create a virtual environment with Python 3.8
python3.8 -m venv .

# Activate the virtual environment
source ./bin/activate

# Install Ansible inside the virtual environment
pip install ansible

# Run the Ansible playbook (replace <PLAYBOOK.yml> with your playbook file)
ansible-playbook ansible/web/deploy_container.yaml -e "docker_image_version=${docker_image_version}"

# Deactivate the virtual environment
deactivate

