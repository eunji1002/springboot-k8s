# Builder
FROM gradle:8.6.0-jdk21 AS builder

WORKDIR /usr/src/app

COPY . .

RUN ./gradlew clean build --no-daemon

# Running
FROM azul/zulu-openjdk-alpine:21

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/build/libs/first-example-0.0.1-SNAPSHOT.jar ./first-example-0.0.1-SNAPSHOT.jar

CMD ["java","-jar","./first-example-0.0.1-SNAPSHOT.jar"]
