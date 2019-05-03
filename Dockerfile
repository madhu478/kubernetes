# Taking the base image
FROM tomcat:7
# download the jenkins.war to webapps folder
ADD http://ftp-nyc.osuosl.org/pub/jenkins/war/2.175/jenkins.war  /webapps
# it will helps to keep container live as long as process runs inside the container 
CMD ["catalina.sh","run"]
