FROM openjdk:11
ARG JAR_FILE=gradle/wrapper/gradle-wrapper.jar
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]