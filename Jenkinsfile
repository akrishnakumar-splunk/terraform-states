pipeline {
    agent any
    environment {
        TF_VAR_cpu_count = "${cpuCount}"
        TF_VAR_mem_in_mb = "${memInMB}"
        TF_VAR_instance_name = "${name}"
        TF_HOME = tool('jenkins-terraform')
        PATH = "$TF_HOME:$PATH"
    }
    stages {
        stage('Terraform Init'){
            steps {
                sh 'terraform --version'
                sh "terraform init -input=false"
                sh "terraform get"
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
                        sh "terraform init -input=false"
                        sh "terraform get"
                        sh "terraform plan \
                        -out=terraform-instance.tfplan -var 'vsphere_user=$VSPHERE_USERNAME' -var 'vsphere_password=$VSPHERE_PASSWORD' -var 'vsphere_server=$VSPHERE_SERVER'"
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
                            sh "terraform apply terraform-instance.tfplan"
                    }
            }
            }
        }
    }
    
}