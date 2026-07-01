pipeline {
    agent {
        label 'dynamic-agent'
    }

    // Creates a dropdown in the Jenkins UI for manual runs
    parameters {
        choice(
            name: 'ACTION', 
            choices: ['Apply', 'Destroy'], 
            description: 'Select "Apply" to deploy the infrastructure (Default on commit), or "Destroy" to tear down the WordPress app and save costs.'
        )
    }

    environment {
        // Keeps the Terraform console output clean
        TF_IN_AUTOMATION = 'true'
    }

    stages {
        stage('Terraform Init') {
            steps {
                echo "Initializing Terraform..."
                sh 'terraform init -no-color'
            }
        }

        stage('Terraform Execution') {
            steps {
                // Securely fetch the tfvars file from Jenkins Credentials
                withCredentials([file(credentialsId: 'wp-tfvars', variable: 'SECRET_TFVARS')]) {
                    script {
                        // Copy the injected file into the workspace where Terraform expects it
                        sh 'cp $SECRET_TFVARS terraform.tfvars'

                        if (params.ACTION == 'Apply') {
                            echo "Planning and Applying the WordPress Infrastructure..."
                            sh 'terraform plan -out=tfplan -no-color'
                            sh 'terraform apply -auto-approve tfplan -no-color'
                            
                        } else if (params.ACTION == 'Destroy') {
                            echo "Tearing down the WordPress Infrastructure to stop billing..."
                            sh 'terraform destroy -auto-approve -no-color'
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            // CRITICAL: Ensure the unencrypted tfvars file and plan are destroyed 
            // from the workspace regardless of whether the pipeline succeeds or fails.
            sh 'rm -f terraform.tfvars tfplan'
        }
    }
}
