FROM openjdk:8
COPY jarstaging/Mrutyunjay/My-DevOps-Project/2.1.3/My-DevOps-Project-2.1.3.jar tweet-app.jar
ENTRYPOINT [ "java","-jar","tweet-app.jar" ]
