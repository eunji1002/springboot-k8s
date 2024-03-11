FROM openjdk:21-jdk

WORKDIR /usr/src/app

COPY ./build/libs/first-example-0.0.1-SNAPSHOT.jar ./build/libs/first-example-0.0.1-SNAPSHOT.jar

CMD ["java","-jar","./build/libs/first-example-0.0.1-SNAPSHOT.jar"]