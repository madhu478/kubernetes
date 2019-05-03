FROM tomcat:7
ADD http://ftp-nyc.osuosl.org/pub/jenkins/war/2.175/jenkins.war  /webapps
CMD ["catalina.sh","run"]
