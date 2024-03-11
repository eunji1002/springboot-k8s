# Builder
FROM gradle:8.6.0-jdk21 AS builder

WORKDIR /usr/src/app

COPY . .

RUN ./gradlew clean build --no-daemon

# Running
FROM openjdk:21-jdk

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/build/libs/first-example-0.0.1-SNAPSHOT.jar ./first-example-0.0.1-SNAPSHOT.jar

CMD ["java","-jar","./first-example-0.0.1-SNAPSHOT.jar"]
