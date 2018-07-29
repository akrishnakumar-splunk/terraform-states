pipeline {
    agent any
    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform-0.11.1"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage ('Setup Environment') {
            steps {
                def tfHome = tool('terraform-0.11.1')
            env.PATH = "${tfHome}:${env.PATH}"
            env.TF_VAR_cpu_count = "${cpuCount}"
            env.TF_VAR_mem_in_mb = "${memInMB}"
            env.TF_VAR_instance_name = "${name}"
            env.DYNAMODB_STATELOCK = "vsph-tfstatelock"
            env.STATES_BUCKET = "vsph-states-bucket"
            env.VSPH_ACCESS_KEY = credentials('tfstates_access_key')
            env.VSPH_SECRET_KEY = credentials('tfstates_secret_key')
            }
        }
        stage('Terraform Init'){
            steps {
                sh 'terraform --version'
            sh "terraform init -input=false -plugin-dir=/var/jenkins_home/terraform_plugins \
                --backend-config='dynamodb_table=$DYNAMODB_STATELOCK' --backend-config='bucket=$STATES_BUCKET' \
                --backend-config='access_key=$VSPH_ACCESS_KEY' --backend-config='secret_key=$VSPH_SECRET_KEY'"
            sh "echo \$PWD"
            sh "whoami"
            }
        }
        stage('Terraform Plan'){
            steps {
                script {
                        try {
                            sh "terraform workspace new ${name}"
                        } catch (err) {
                            sh "terraform workspace select ${name}"
                        }
                        sh "terraform plan -var 'aws_access_key=$VSPH_ACCESS_KEY' -var 'aws_secret_key=$VSPH_SECRET_KEY' \
                        -out terraform-instance.tfplan;echo \$? > status"
                        stash name: "terraform-instance-plan", includes: "terraform-instance.tfplan"
                }
            }
        }
        stage('Terraform Apply'){
            steps {
                script{
                    def apply = false
                    try {
                        input message: 'Apply Plan?', ok: 'Apply'
                        apply = true
                    } catch (err) {
                        apply = false
                        currentBuild.result = 'UNSTABLE'
                    }
                    if(apply){
                            unstash "terraform-instance-plan"
                            sh 'terraform apply terraform-instance.tfplan'
                    }
            }
            }
        }
    }
    
}