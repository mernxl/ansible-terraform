pipeline {
  agent any

  parameters {
    string(name: 'extra_vars', defaultValue: '', description: 'Pass extra-vars to send down to ansible, must be a JSON string without external braces. It will be padded to existing string configuration. e.g. "version": "v1.3", "build": "one"')
    string(name: 'pre_extras', defaultValue: ' ', description: 'Pass in extras to be sent into ansible when runing pre ansible script')
    string(name: 'plan_extras', defaultValue: ' ', description: 'Pass in extras to be sent padded in the plan stage')
    string(name: 'apply_extras', defaultValue: ' ', description: 'Pass in extras to be sent padded in the apply stage')
    choice(name: 'env', choices: ['dev', 'prod'], description: 'Select the environment you wish to run the pipeline on, defaults to dev.')
  }

  stages {

    stage('test') {
      steps {
        sh "cd terraform"
        sh "terraform validate"
      }
    }

    stage('pre') {
      steps {
        // A pre runbook, to prepare terraform provider dependencies
        ansiblePlaybook colorized: true, credentialsId: 'ubuntu-ssh', disableHostKeyChecking: true, installation: 'ansible', inventory: 'ansible_hosts', limit: "${params.env}", playbook: 'ansible-pre.yml', extras: "${params.pre_extras} --extra-vars '{ \"env\": ${params.env} }' "
      }
    }

    stage('plan') {
      steps {
        ansiblePlaybook colorized: true, credentialsId: 'ubuntu-ssh', disableHostKeyChecking: true, installation: 'ansible', inventory: 'ansible_hosts', limit: "${params.env}", playbook: 'ansible.yml', extras: "${params.plan_extras} --extra-vars '{ \"env\": ${params.env}, \"plan_only\":\"yes\", \"terraform_tvars_files\": \"./terraform.tfvars\", ${params.extra_vars}}' "
      }
    }

    stage('approval') {
      steps {
        script {
          def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
        }
      }
    }

    stage('apply') {
      steps {
         ansiblePlaybook colorized: true, credentialsId: 'ubuntu-ssh', disableHostKeyChecking: true, installation: 'ansible', inventory: 'ansible_hosts', limit: "${params.env}", playbook: 'ansible.yml', extras: "${params.apply_extras} --extra-vars '{ \"env\": ${params.env}, \"plan_only\":\"no\", \"terraform_tvars_files\": \"./terraform.tfvars\", ${params.extra_vars}}' "
      }
    }
  }
}