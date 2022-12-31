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

                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: "f3fd2446-5adb-4979-a1d1-2270597b6466",
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh"""
                        cd create-timeoff-infra
                        terraform --version
                        terraform init -no-color -backend-config="access_key=${env.AWS_ACCESS_KEY_ID}" -backend-config="secret_key=${env.AWS_SECRET_ACCESS_KEY}"
                        """
                    }
                }
            }
        }
    }
}
   