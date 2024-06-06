FROM openjdk:17
EXPOSE 8082
WORKDIR /app
#WORKDIR /opt/apache-tomcat-9.0.65/webapps/
ADD target/petclinic.war petclinic.war
ENTRYPOINT ["java","-war","petclinic.war"]
