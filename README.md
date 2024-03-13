# Api-server

[![Spring Boot](https://img.shields.io/badge/Spring_Boot-2.5.4-green.svg)](https://spring.io/projects/spring-boot)
[![Java](https://img.shields.io/badge/Java-21-red.svg)](https://www.java.com/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg)](https://www.mysql.com/)
[![Jenkins](https://img.shields.io/badge/Jenkins-Automation-pink.svg)](https://jenkins.io/)
[![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-yellow.svg)](https://prometheus.io/)

이 간단한 Spring Boot 애플리케이션은 MySQL 데이터베이스와 연동하여 Sample 데이터베이스의 'todo' 테이블을 출력합니다. 뿐만 아니라, Actuator와 Prometheus를 활용하여 모니터링 기능을 제공합니다.

이 프로젝트는 Jenkinsfile을 활용하여 CI/CD를 구축했습니다. Jenkins를 통해 빌드, 테스트, 그리고 배포가 자동화되었으며, ArgoCD를 이용하여 Kubernetes 클러스터에 애플리케이션을 자동으로 배포합니다.

## application.yaml
```bash
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://192.168.245.131:3306/sample?useSSL=false&allowPublicKeyRetrieval=true&useUnicode=true&serverTimezone=UTC
    username: root
    password: 1234
    hikari:
      connection-timeout: 120000
  jpa:
    hibernate:
      ddl-auto: create
    properties:
      hibernate:
        format_sql: true
management:
  endpoints:
    web:
      exposure:
        include: prometheus
```
## dependencies

```bash
dependencies {
	implementation 'org.springframework.boot:spring-boot-starter-web:3.1.2'
	implementation 'org.springframework.boot:spring-boot-starter-actuator:3.1.2'
	implementation 'io.micrometer:micrometer-registry-prometheus'
	implementation 'io.micrometer:micrometer-core'
	compileOnly 'org.projectlombok:lombok'
	runtimeOnly 'com.h2database:h2'
	runtimeOnly 'com.mysql:mysql-connector-j'
	annotationProcessor 'org.projectlombok:lombok'
	testImplementation 'org.springframework.boot:spring-boot-starter-test'
	implementation 'javax.persistence:javax.persistence-api:2.2'
	implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
	implementation 'org.springframework.boot:spring-boot-starter-jdbc'
	implementation 'mysql:mysql-connector-java:8.0.17'
}
```
## dockerfile

```bash
# Builder
FROM gradle:8.6.0-jdk21 AS builder

WORKDIR /usr/src/app

COPY . .

RUN chmod +x ./gradlew

RUN ./gradlew clean build --no-daemon

# Running
FROM azul/zulu-openjdk-alpine:21

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/build/libs/first-example-0.0.1-SNAPSHOT.jar ./first-example-0.0.1-SNAPSHOT.jar

CMD ["java","-jar","./first-example-0.0.1-SNAPSHOT.jar"]

```
## Jenkinsfile

```bash
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
```
## 앱 미리보기
<p>
  <img src="/src/5.png" width="1000" alt="get">
  <img src="/src/6.png" width="1000" alt="jenkins">
  <img src="/src/7.png" width="1000" alt="docker hub">
  <img src="/src/8.png" width="1000" alt="argocd">
</p>
