FROM adoptopenjdk/openjdk11:alpine
ARG JAR_FILE_PATH=target/*.jar
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/docker-springboot.jar"]