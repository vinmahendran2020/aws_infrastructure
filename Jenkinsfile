pipeline {
  agent { label 'infra-build' } //use slave with ansible

  options {
    buildDiscarder(logRotator(numToKeepStr: '15', daysToKeepStr: '14'))
    // either use this wiht polling method, or use webhooks to trigger builds
    disableConcurrentBuilds()
  }

  environment {
    // trust known_hosts
    GIT_SSH_COMMAND = "ssh -o StrictHostKeyChecking=no"
    //this formats ansible output nicely https://github.com/ansible/ansible/issues/27078#issuecomment-364560173
    ANSIBLE_STDOUT_CALLBACK="yaml" 
  }

  stages {
    stage('All custom tools') {
      steps {
        sh "pwd && hostname && whoami && ls"
        sh "python --version"
        sh "terraform version"
        sh "ansible --version && ansible-playbook --version && ansible-galaxy --version"
        sh "kubectl version --client=true"
        sh "aws --version"
        sh "aws-iam-authenticator help"
      }
    }

    stage('Terraform: Lint') {
      steps {
        echo "Checking for Terraform formatting issues..."
        // list non formatted files, in current directory (.)
        sh "terraform fmt -list -check ."
      }
    }


    stage('Ansible Install Pre-Reqs') {
      steps{
        sshagent(['innersource_service_user']) {
          sh '''
          ansible-galaxy install -r requirements.yml -f
          '''
        }
      }
    }

    // plan should always happen on all branches
    stage('Terraform: Plan') {
      steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'terraform_user',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sshagent(['innersource_service_user']) {
            sh '''
            export TF_VAR_aws_access_key=$AWS_ACCESS_KEY_ID
            export TF_VAR_aws_secret_key=$AWS_SECRET_ACCESS_KEY
            ansible-playbook site.yml --diff -vv --inventory-file=inventory/ --extra-vars "@./network.yml" --extra-vars "plan=true"
            '''
            // plan=true will run terraform module in check mode, i.e. up to terraform plan
          }
        }
      }
    }

    // manual approve for any deployments 
    stage('Manual Approval for Deployments') {
      // when { 
      //   anyOf { 
      //     branch 'master'; 
      //     branch 'develop' 
      //   } 
      // }
      steps {
        input 'Continue to Deploy?'
      }
    }

    // actual deployment using terraform apply
    stage('Terraform Apply') {
      // when { 
      //   anyOf { 
      //     branch 'master'; 
      //     branch 'develop' 
      //   } 
      // }
      steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'terraform_user',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sshagent(['innersource_service_user']) {
            sh '''
            export TF_VAR_aws_access_key=$AWS_ACCESS_KEY_ID
            export TF_VAR_aws_secret_key=$AWS_SECRET_ACCESS_KEY
            ansible-playbook site.yml -vv --inventory-file=inventory/ --extra-vars "@./network.yml"

            pwd
            '''
          }
        }
      }
    }
  }
}

