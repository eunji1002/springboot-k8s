pipeline {
    agent any
    environment {
         TAG = "${new java.text.SimpleDateFormat('yyyy-MM-dd_HH-mm-ss').format(new Date())}"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build') {
            steps {
                script {
                    // Docker 이미지 빌드
                    app = docker.build("eunjing/eunji:${env.BUILD_NUMBER}", ".")
                }
            }
        }
        stage('Push') {
            steps {
                script {
                    // Docker Hub에 로그인 후 이미지 푸시
                    docker.withRegistry('https://registry.hub.docker.com', 'label') {
                        app.push("${TAG}")
                        app.push("latest")
                    }
                }
            }
        }
    }
}