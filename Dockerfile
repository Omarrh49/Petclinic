FROM tomcat:8.0-alpine

ADD target/petclinic.war /usr/local/tomcat/webapps/

EXPOSE 8082

CMD [“catalina.sh”, “run”]

#FROM openjdk:17
#EXPOSE 8082
#WORKDIR /opt/apache-tomcat-9.0.65/webapps/
#ADD target/petclinic.war petclinic.war
#ENTRYPOINT ["java","-jar","/petclinic.war"]
