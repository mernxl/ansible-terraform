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
        ansiblePlaybook colorized: true, credentialsId: 'ubuntu-ssh', disableHostKeyChecking: true, installation: 'ansible', inventory: 'ansible_hosts', playbook: 'ansible.yml'
      }
    }

    stage('apply') {
     
      steps {
        echo "applying..."
      }
    }
  }
}