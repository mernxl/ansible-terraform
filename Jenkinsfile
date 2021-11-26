pipeline {
  agent any

  parameters {
    string(name: 'extra_vars', defaultValue: '', description: 'Pass extra-vars to send down to ansible, must be a JSON string without external braces. It will be padded to existing so it should commence with a comma (,). e.g. ,"env": "dev", "build": "one"')
    string(name: 'plan_extras', defaultValue: ' ', description: 'Pass in extras to be sent padded in the plan stage')
    string(name: 'apply_extras', defaultValue: ' ', description: 'Pass in extras to be sent padded in the apply stage')
  }

  stages {

    stage('test') {
      steps {
        sh "cd terraform"
        sh "terraform validate"
      }
    }  

    stage('plan') {
      steps {
        ansiblePlaybook colorized: true, credentialsId: 'ubuntu-ssh', disableHostKeyChecking: true, installation: 'ansible', inventory: 'ansible_hosts', playbook: 'ansible.yml', extras: "${params.plan_extras} --extra-vars '{\"plan_only\":\"yes\" ${params.extra_vars}}' "
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
         ansiblePlaybook colorized: true, credentialsId: 'ubuntu-ssh', disableHostKeyChecking: true, installation: 'ansible', inventory: 'ansible_hosts', playbook: 'ansible.yml', extras: "${params.apply_extras} --extra-vars '{\"plan_only\":\"no\" ${params.extra_vars}}' "
      }
    }
  }
}