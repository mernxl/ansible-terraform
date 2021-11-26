pipeline {
  agent any

  stages {

    stage('test') {
      steps {
        sh "cd terraform"
        sh "terraform validate"
      }
    }  

    stage('plan') {
      steps {
        ansiblePlaybook extras: 'plan_only=yes', colorized: true, credentialsId: 'ubuntu-ssh', disableHostKeyChecking: true, installation: 'ansible', inventory: 'ansible_hosts', playbook: 'ansible.yml', extras: 'plan_only=yes'
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
         ansiblePlaybook extras: 'plan_only=no', colorized: true, credentialsId: 'ubuntu-ssh', disableHostKeyChecking: true, installation: 'ansible', inventory: 'ansible_hosts', playbook: 'ansible.yml'
      }
    }
  }
}