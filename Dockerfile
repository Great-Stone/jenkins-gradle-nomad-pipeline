FROM openjdk:11.0.15-jre-slim
RUN mkdir /opt/app
COPY ./build/libs/demo-0.0.1-SNAPSHOT.jar /opt/app/japp.jar
CMD ["java", "-jar", "/opt/app/japp.jar"]