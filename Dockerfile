FROM adoptopenjdk/openjdk11:alpine
RUN ./gradlew build
ARG JAR_FILE=gradle/wrapper/gradle-wrapper.jar
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]