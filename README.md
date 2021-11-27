# Ansible Terraform

A demo project for deploying terraform to instances using ansible terraform module

It provides surport for deploying to multiple environments, based on parameters passed into jenkins.

## Prerequisites

- AWS account with credentials stored in `./aws/credentials`. Pass in a profile via the `aws_creds_profile` terraform var, defaults to `ansible-terraform`.
- This account must contain all defualt VPC configurations like defualt security group, subnets etc. Pass in the region in as `aws_region` terraform var.

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

   1. Fetch Ips of the targets from aws console
   1. Place them in the `ansible_hosts` file, those terminating with `dev` under the `dev` host group and the `prod` in prod host group

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

The `terraform` and `live` dir are copied to the remotes before execution, so you can use it to place backend_config_files, variable_files for later referencing.

The stages included in the Jenkins pipeline include;

1. test - Will carry out terraform validate on your configutions
1. plan - Will run a plan of your terraform configuration and print the output for validations. (Check the console output for full log)
1. approval - Will pause the pipeline and wait for approval before continueing to execute the. You make choose to cancel.
1. apply - If approved, will apply the change in the terraform

### How to use

#### Terraform Variables

- You can pass in variables to terraform by passing in the ansible `terraform_tvars` variable, it could be a json (map).
- You can also pass in a location to the variables file through `terraform_tvars_files`.

Example
Passing in `extra-vars` as `, "terraform_tvars": { "nginx_container_name": "nginx-changed" }` will change the nginx container name in the remote instances

#### Deploying to Different Environments

Deploying to different environments is virtually simple.

1. Add the hosts for that environment (e.g. qa) under a `qa` host group in `ansible_hosts` file
1. Add a dir, inside of `live` dir with the name of the env, and import the terraform module (see live/dev example)
1. Add the environment slug as to the choice parameter `env` in the Jenkinsfile
1. Commit your code and push
1. At Jenkins, go to run with parameters, select `qa` as `env` and then run.
1. Make sure to provide the required inputs

#### Terraform Backend

- Place your backend files into the `terraform/` dir and commit
- You can indicate the terraform backend files by passing in the var `backend_config_files`

#### Destroy deployed Terrafom

To destroy existing state, run the the pipeline with the following parameters extra_vars

```
, "state": "absent"
```
