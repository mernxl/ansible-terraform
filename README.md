# Ansible Terraform

A demo project for deploying terraform to instances using ansible terraform module

It supports deploying to multiple environments, based on parameters passed in through jenkins.

## Background
We wish to apply terraform configurations to a bunch of remote instances using ansible. This is required to be handle continuously using the Jenkins CI platform. 

### Folder Structure
- live: Holds entrypoint tf configurations for each target environment.
- terraform: Holds the terraform configurations for our remote instances
- terraform-infra: Holds infrastructure terraform code, to deploy our infrastructure, i.e. the jenkins server as well as our target servers.
- ansible_hosts: Holds our target server hosts, segregated by environment (dev, prod etc)
- ansible-pre.yml: An ansible playbook to prepare our target instance with dependencies of our terraform providers. e.g. install docker in instance if we need to deploy docker containers in remote
- ansible.yml: A playbook to handle terraform deployment to remote hosts.
- Jenkinsfile: Jenkins pipeline configuration, used by jenkins to fufil our goal.

## Prerequisites

- AWS account with credentials stored in `./aws/credentials`. Pass in a profile via the `aws_creds_profile` terraform var, defaults to `ansible-terraform`.
- This account must contain all defualt VPC configurations like defualt security group, subnets etc. Pass in the region in as `aws_region` terraform var.
- Terraform to deploy base infrastructure
- Anisble for installing docker and other needed tools within the target servers.


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
   1. Push your changes to the repository

1. Configure Jenkins server

   1. Goto to aws console, get the connection command to ssh into jenkins-server
   1. Follow from https://www.digitalocean.com/community/tutorials/how-to-install-jenkins-on-ubuntu-20-04#step-4-%E2%80%94-setting-up-jenkins
   1. Configure a `Github Server` in `Configure System` (Use a Personal Access Token as credentials)
      1. Follow from https://plugins.jenkins.io/github/
      1. Make sure to check `Manage Hooks`
   1. Install the ansible plugin at Jenkins
   1. Configure ansible at `Global Tools Config`
      1. Name: `ansible`
      1. Path: `/usr/bin`
   1. Add the private keys to the target instances, which ansible will use to connect in jenkins credentials
      1. Use the content of the `ec2-terra-ansi.pem` created while deploying infrastructure
      1. username should be `ubuntu`
      1. The Id of the credentials should be `ubuntu-ssh`
   1. Add a multibranch project to this repository
      1. Make sure to add a branch source pointing to this repository

## Deploying Terraform to Target Servers

This repository after configuration will automatically carry out the changes in the `terraform` dir on the remote instances using ansible.

Basically just pushing changes to this repository should redeploy your terraform code. It will pause after a plan and you can acknowledge to continue or stop.

The `terraform` and `live` dir are copied to the remotes before execution, so you can use it to place backend_config_files, terraform_tvars_files for later referencing.

The stages included in the Jenkins pipeline are;

1. test - Will carry out terraform validate on your configutions
1. pre - run an ansible prepare playbook to deploy to the target instances terraform dependencies
1. plan - Will run a plan of your terraform configuration and print the output for validations. (Check the console output for full log)
1. approval - Will pause the pipeline and wait for approval before continueing to execute the. You make choose to cancel.
1. apply - If approved, will apply the change in the terraform

### How to use

#### Terraform Variables

- You can pass in variables to terraform by passing in the ansible `terraform_tvars` variable, it could be a json (map).
- You can also pass in a location to the variables file through `terraform_tvars_files`.

Example
1. Passing in `extra-vars` as `"terraform_tvars": { "nginx_container_name": "nginx-changed" }` will change the nginx container name in the remote instances.
1. For the case with a .tvars file for any environment, run terraform with the following `extra-vars` parameter `"terraform_tvars_files": "../relative/path/to.tvars" `

#### Deploying to Different Environments

Deploying to different environments is virtually simple.

1. Add the hosts for that environment (e.g. qa) under a `qa` host group in `ansible_hosts` file
1. Add a dir, inside of `live` dir with the name of the env, and import the terraform module (see live/dev example)
1. Add the environment slug as a choice to the `env` parameter in the Jenkinsfile
1. Commit your code and push
1. At Jenkins, go to run with parameters, select `qa` as `env` and then run.
1. Make sure to other provide the required inputs

#### Terraform Backend

- Place your backend files into the `terraform/` dir and commit
- You can indicate the terraform backend files by passing in the var `backend_config_files`

#### Destroy deployed Terrafom

To destroy existing state, run the the pipeline with the following parameters extra_vars

```
"state": "absent"
```
