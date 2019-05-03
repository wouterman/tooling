#!/bin/bash

COMPOSE_HOSTED="sources/compose-files/docker-compose-hosted.yml"

echo "***************************"
echo "Stopping any conflicting containers"
echo "***************************"
docker-compose -f ${COMPOSE_HOSTED} down

echo "***************************"
echo "Starting up hosted containers"
echo "***************************"
docker-compose -f ${COMPOSE_HOSTED} up --build -d

echo "Replacing Nginx html folder"
docker cp  ./sources/nginx/default.conf nginx:/etc/nginx/conf.d/default.conf

echo "Replacing Nginx default.conf"
docker cp ./sources/nginx/html  nginx:/usr/share/nginx/

echo "Tomcat-test: replacing tomcat-users.xml"
docker cp ./sources/tomcat/tomcat-users.xml tomcat-test:/usr/local/tomcat/conf/tomcat-users.xml

echo "Tomcat-test: Replacing context.xml"
docker cp ./sources/tomcat/context.xml tomcat-test:/usr/local/tomcat/webapps/manager/META-INF/context.xml

echo "Tomcat-stage: replacing tomcat-users.xml"
docker cp ./sources/tomcat/tomcat-users.xml tomcat-stage:/usr/local/tomcat/conf/tomcat-users.xml

echo "Tomcat-stage: Replacing context.xml"
docker cp ./sources/tomcat/context.xml tomcat-stage:/usr/local/tomcat/webapps/manager/META-INF/context.xml

echo "Tomcat-prod: replacing tomcat-users.xml"
docker cp ./sources/tomcat/tomcat-users.xml tomcat-prod:/usr/local/tomcat/conf/tomcat-users.xml

echo "Tomcat-prod: Replacing context.xml"
docker cp ./sources/tomcat/context.xml tomcat-prod:/usr/local/tomcat/webapps/manager/META-INF/context.xml

docker restart nginx
docker restart tomcat-test
docker restart tomcat-stage
docker restart tomcat-prod