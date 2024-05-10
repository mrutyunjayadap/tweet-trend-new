FROM openjdk:8
COPY jarstaging/Mrutyunjay/My-DevOps-Project/2.1.4/My-DevOps-Project-2.1.4.jar tweet-app.jar
ENTRYPOINT [ "java","-jar","tweet-app.jar" ]
