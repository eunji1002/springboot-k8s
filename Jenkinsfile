pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIAL = credentials('eunjing')
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = 'eunjing/eunji'
        DOCKER_REGISTRY_USERNAME = 'eunjing'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'eunjing', variable: 'DOCKER_HUB_CREDENTIAL')]) {

                        sh "echo $DOCKER_HUB_CREDENTIAL | docker login -u $DOCKER_REGISTRY_USERNAME --password-stdin $DOCKER_REGISTRY"


                        sh "docker build -t $DOCKER_REGISTRY/$IMAGE_NAME ."
                        sh "docker push $DOCKER_REGISTRY/$IMAGE_NAME"

                        
                        sh "docker logout $DOCKER_REGISTRY"
                    }
                }
            }
        }
    }
}
