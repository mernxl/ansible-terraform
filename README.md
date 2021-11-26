# Ansible Terraform

A demo project for deploying terraform to instances using ansible terraform module

## Prerequisites

- AWS account with credentials stored in `./aws/credentials`
- Configured Basic VPC defaults in eu-north-1

## Steps to Setup Environments

1. Deploy basic infrastructure in aws

   ```bash
   cd terraform-infra
   terraform init
   terraform plan
   ```

   Apply the infrastructure

   ```bash
   terraform apply
   ```

1. Populate the `ansible_hosts` file and commit

   1. Fetch Ips of the targets in the `target-ips.txt` file (or from aws console)
   1. Place them in the `ec2_dev` host group in the `ansible_hosts` file

1. Run the ansible-pre.yml playbook on all target systems

   1. Make sure the target ips are in `ansible_hosts` file
   1. Run the following to install requires on target instances

      ```bash
      ansible-playbook -i ansible_hosts ansible-pre.yml
      ```

1. Configure Jenkins server

   1. Goto to aws console, get the connection command to ssh into jenkins-server
   1. Follow from https://www.digitalocean.com/community/tutorials/how-to-install-jenkins-on-ubuntu-20-04#step-4-%E2%80%94-setting-up-jenkins
   1. Configure a `Github Server` in `Configure System` (Use a Personal Access Token as credentials)
      1. Make sure to check `Manage Hooks`
   1. Install the ansible plugin at Jenkins
   1. Configure ansible at `Global Tools Config`
      1. Name: `ansible`
      1. Path: `/usr/bin`
   1. Add the private keys to the target instances, which ansible will use to connect in jenkins credentials
      1. Use the content of the `ec2-terra-ansi.pem` created while deploying infrastructure
      1. The Id of the credentials should be `ubuntu-ssh`
   1. Add a multibranch project to this repository

## Deploying Terraform to Target Servers

This repository after configuration will automatically carry out the changes in the `terraform` dir on the remote instances using ansible.

Basically just pushing changes to this repository should redeploy your terraform code. It will pause after a plan and you can acknowledge to continue or stop.

The `terraform` dir is copied to the remotes before execution, so you can use it to place backend_config_files, variable_files for later referencing.

The stages included in the Jenkins pipeline include;

1. test - Will carry out terraform validate on your configutions
1. plan - Will run a plan of your terraform configuration and print the output for validations.
1. approval - Will pause the pipeline and wait for approval before continueing to execute the. You make choose to cancel.
1. apply - If approved, will apply the change in the terraform

### How to use

#### Terraform Variables

- You can pass in variables to terraform by passing in the ansible `terraform_tvars` variable, it could be a json (map).
- You can also pass in a location to the variables file through `terraform_tvars_files`.

Example
Passing in `extra-vars` as `, "terraform_tvars": { "container_name": "nginx-changed" }` will change the nginx container name in the remote instances

#### Terraform Backend

- Place your backend files into the terraform/ dir and commit
- You can indicate the terraform backend files by passing in the var `backend_config_files`
