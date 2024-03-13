# Api-server

[![Spring Boot](https://img.shields.io/badge/Spring_Boot-2.5.4-green.svg)](https://spring.io/projects/spring-boot)
[![Java](https://img.shields.io/badge/Java-21-red.svg)](https://www.java.com/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg)](https://www.mysql.com/)
[![Jenkins](https://img.shields.io/badge/Jenkins-Automation-pink.svg)](https://jenkins.io/)
[![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-yellow.svg)](https://prometheus.io/)

이 간단한 Spring Boot 애플리케이션은 MySQL 데이터베이스와 연동하여 Sample 데이터베이스의 'todo' 테이블을 출력합니다. 뿐만 아니라, Actuator와 Prometheus를 활용하여 모니터링 기능을 제공합니다.

이 프로젝트는 Jenkinsfile을 활용하여 CI/CD를 구축했습니다. Jenkins를 통해 빌드, 테스트, 그리고 배포가 자동화되었으며, ArgoCD를 이용하여 Kubernetes 클러스터에 애플리케이션을 자동으로 배포합니다.
## 인프라 구성도

이 프로젝트는 쿠버네티스 환경을 위해 다음과 같은 구성을 사용했습니다:

- **개발 환경**: 윈도우 운영 체제
- **운영 환경**: VMware Workstation 17, 가상머신에 Ubuntu Server 22.04를 설치하여 운영 환경을 구축했습니다. 실제 운영은 쿠버네티스 클러스터에서 실행됩니다. 이 클러스터는 여러 가상 머신에서 실행되며, 쿠버네티스 마스터 및 워커 노드가 포함됩니다.

 <img src="/src/k8s.drawio.png" width="1000" alt="infra">
 
## application.yaml
application.yaml 파일은 Spring Boot 애플리케이션의 설정 파일입니다.

여기에는 데이터베이스 연결 정보, JPA 설정 및 Actuator의 Prometheus 엔드포인트 노출 설정이 포함되어 있습니다.
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

## dockerfile

위 Dockerfile은 Gradle을 사용하여 Spring Boot 애플리케이션을 빌드하고, 그 결과물을 런타임 환경에 배포하기 위한 것입니다.

먼저, 빌더 스테이지에서는 Gradle을 기반으로한 빌더 이미지를 사용하여 애플리케이션을 빌드합니다. 그리고 런타임 스테이지에서는 해당 빌더 스테이지에서 생성된 JAR 파일을 런타임 환경으로 복사하고 실행합니다.
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
이 파이프라인은 다음과 같은 단계로 구성됩니다:

Checkout: 소스 코드를 가져옵니다.
Build and Push Docker Image: Docker 이미지를 빌드하고 Docker Hub에 푸시합니다.
파이프라인은 Jenkins의 파이프라인 기능을 사용하여 정의되었으며, Docker Hub에 이미지를 푸시하기 위해 보안 자격 증명을 사용합니다.
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
## 🎀🎀 결과 🎀🎀
<p>
  <img src="/src/5.png" width="1000" alt="get">
  <img src="/src/6.png" width="1000" alt="jenkins">
  <img src="/src/7.png" width="1000" alt="docker hub">
  <img src="/src/8.png" width="1000" alt="argocd">
  <img src="/src/9.png" width="1000" alt="prometheus">
  <img src="/src/10.png" width="1000" alt="pod">
  <img src="/src/11.png" width="1000" alt="pod2">
  <img src="/src/12.png" width="1000" alt="svc">
</p>

## 트러블슈팅 : 6443 refused
🔥 **문제 상황**

The connection to the server 192.168.245.131:6443 was refused - did you specify the right host or port? 

🌟 **해결 방안**

1. swap off
```bash
$ sudo -i
$ swapoff -a
$ exit
$ strace -eopenat kubectl version
$ sudo systemctl restart kubelet.service
```
2. PC 메모리 증설

✨ **해당 경험을 통해 알게된 점**

처음에는 Weave CNI를 사용하여 문제가 발생했을 것으로 생각했지만, Flannel로 변경해도 동일한 오류가 지속되었습니다. 또한, 네트워크 문제가 해결된 것처럼 보였지만 곧 다시 같은 오류가 발생하는 현상을 경험했습니다. 

그래서 PC의 메모리를 확인해보니 사용 중인 메모리가 94%에 이르렀습니다. 이로 인해 가상 머신에서 네트워크 오류가 발생한 것으로 판단했습니다.

이러한 상황에서 Kubernetes API가 자주 끊겨 Grafana와의 연동을 완료하지 못했습니다. 메모리 부족으로 인한 네트워크 문제가 이어져 발생한 이 문제를 해결하기 위해서는 메모리 업그레이드가 필요하다는 결론을 내렸습니다.
