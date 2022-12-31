pipeline {
    options
    {
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    agent any

    parameters {
        choice(name: 'SelectTerraformOperation', choices: ['', "apply", "destroy_preview", "destroy", "plan"], description: 'Pick something')
    }

    environment 
    {
        TERRAFORM_ACTION = "${SelectTerraformOperation}"
    }
    stages {

         stage("Execution") {
            steps {
                script {
                     withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: "f3fd2446-5adb-4979-a1d1-2270597b6466",
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        if (TERRAFORM_ACTION == "apply") {
                            sh"""
                            cd create-timeoff-infra/prod
                            terraform --version
                            terraform init -no-color -backend-config="access_key=${env.AWS_ACCESS_KEY_ID}" -backend-config="secret_key=${env.AWS_SECRET_ACCESS_KEY}"
                            terraform apply -auto-approve -no-color
                            """
                        }
                        else if (TERRAFORM_ACTION == "destroy_preview") {
                            sh"""
                            cd create-timeoff-infra/prod
                            terraform --version
                            terraform init -no-color -backend-config="access_key=${env.AWS_ACCESS_KEY_ID}" -backend-config="secret_key=${env.AWS_SECRET_ACCESS_KEY}"
                            terraform plan -destroy -no-color
                            """
                        }
                        else if (TERRAFORM_ACTION == "destroy") {
                            sh"""
                            cd create-timeoff-infra/prod
                            terraform --version
                            terraform init -no-color -backend-config="access_key=${env.AWS_ACCESS_KEY_ID}" -backend-config="secret_key=${env.AWS_SECRET_ACCESS_KEY}"
                            terraform destroy -auto-approve -no-color
                            """
                        }
                        else if (TERRAFORM_ACTION == "plan"){
                            sh"""
                            cd create-timeoff-infra/prod
                            terraform --version
                            terraform init -no-color -backend-config="access_key=${env.AWS_ACCESS_KEY_ID}" -backend-config="secret_key=${env.AWS_SECRET_ACCESS_KEY}"
                            terraform plan -no-color
                            """
                        } 
                    }
                    
                }
            }
        }
    }
}
   