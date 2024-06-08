#FROM openjdk:17
#EXPOSE 8082
#WORKDIR /app
##WORKDIR /opt/apache-tomcat-9.0.65/webapps/
#ADD target/petclinic.war petclinic.war
#ENTRYPOINT ["java","-jar","petclinic.war"]

FROM tomcat:9.0.65-jdk17
COPY target/petclinic.war /usr/local/tomcat/webapps/
EXPOSE 8082
