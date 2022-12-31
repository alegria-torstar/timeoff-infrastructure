pipeline {
    options
    {
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    agent any
    environment 
    {
        LAMBDA_NAME = "${LambdaName}"
        TERRAFORM_ACTION = "${SelectTerraformOperation}"
        AWS_PROFILE = "torstaraemprod"
    }
    stages {
        stage("Preparation") {
            steps {
                script {
                    sh"""
                    cd create-timeoff-infra
                    terraform --version
                    terraform init -no-color
                    """
                }
            }
        }
    }
}
   