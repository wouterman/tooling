#!/bin/bash
echo "***************************"
echo "Stopping any conflicting containers"
echo "***************************"
docker-compose down

echo "***************************"
echo "Starting up ephemeral containers"
echo "***************************"
docker-compose -f docker-compose-raw.yml up -d

echo "***************************"
echo "Waiting for Gitlab to start up"
echo "***************************"
GITLAB_STATUS="$(docker inspect gitlab | jq '.[].State.Health.Status')"

while [[ ${GITLAB_STATUS} != "\"healthy\"" ]] ; do
    echo "Gitlab status: ${GITLAB_STATUS}"
    echo "Waiting 30 seconds."
    sleep 30s
    GITLAB_STATUS="$(docker inspect gitlab | jq '.[].State.Health.Status')"
done
echo "Gitlab status: ${GITLAB_STATUS}"


echo "***************************"
echo "Removing old volumes"
echo "***************************"
rm -r ./volumes

echo "Creating volume directories"
mkdir -p ./volumes/nginx/conf
mkdir -p ./volumes/jenkins/jenkins_home
mkdir -p ./volumes/sonarqube/conf
mkdir -p ./volumes/sonarqube/data
mkdir -p ./volumes/sonarqube/extensions
mkdir -p ./volumes/sonarqube/bundled-plugins
mkdir -p ./volumes/nexus/data
mkdir -p ./volumes/gitlab/config
mkdir -p ./volumes/gitlab/logs
mkdir -p ./volumes/gitlab/data
mkdir -p ./volumes/tomcat-prod/conf
mkdir -p ./volumes/tomcat-prod/webapps
mkdir -p ./volumes/tomcat-stage/conf
mkdir -p ./volumes/tomcat-stage/webapps
mkdir -p ./volumes/tomcat-test/conf
mkdir -p ./volumes/tomcat-test/webapps
mkdir -p ./volumes/influxdb/data
mkdir -p ./volumes/grafana/data

echo "Copying nginx"
docker cp nginx:/etc/nginx ./volumes/nginx/conf
docker cp nginx:/usr/share/nginx/html ./volumes/nginx/html

echo "Replacing Nginx html folder"
cp -r ./sources/nginx/html/ ./volumes/nginx/

echo "Replacing Nginx default.conf"
cp ./sources/nginx/default.conf ./volumes/nginx/conf/nginx/conf.d/default.conf

echo "Copying jenkins"
docker cp jenkins:/var/jenkins_home/ ./volumes/jenkins/jenkins_home

echo "Creating Sonarqube plugins directory"
docker exec -it sonarqube mkdir /opt/sonarqube/lib/bundled-plugins/

echo "Copying Sonarqube"
docker cp sonarqube:/opt/sonarqube/conf ./volumes/sonarqube/conf
docker cp sonarqube:/opt/sonarqube/data ./volumes/sonarqube/data
docker cp sonarqube:/opt/sonarqube/extensions ./volumes/sonarqube/extensions
docker cp sonarqube:/opt/sonarqube/lib/bundled-plugins ./volumes/sonarqube/bundled-plugins

echo "Copying Nexus"
docker cp nexus:/nexus-data ./volumes/nexus/data

echo "Copying Gitlab"
docker cp gitlab:/etc/gitlab ./volumes/gitlab/config
docker cp gitlab:/var/log/gitlab ./volumes/gitlab/logs
docker cp gitlab:/var/opt/gitlab ./volumes/gitlab/data

echo "Copying Tomcat-prod"
docker cp tomcat-prod:/usr/local/tomcat/conf ./volumes/tomcat-prod/
docker cp tomcat-prod:/usr/local/tomcat/webapps ./volumes/tomcat-prod/

echo "Replacing tomcat-users.xml"
cp ./sources/tomcat/tomcat-users.xml ./volumes/tomcat-prod/conf/tomcat-users.xml

echo "Replacing context.xml"
cp ./sources/tomcat/context.xml ./volumes/tomcat-prod/webapps/manager/META-INF/context.xml

echo "Copying Tomcat-test"
cp -r ./volumes/tomcat-prod/conf ./volumes/tomcat-test
cp -r ./volumes/tomcat-prod/webapps ./volumes/tomcat-test

echo "Copying Tomcat-stage"
cp -r ./volumes/tomcat-prod/conf ./volumes/tomcat-stage
cp -r ./volumes/tomcat-prod/webapps ./volumes/tomcat-stage

echo "Copying InfluxDB"
docker cp influxdb:/var/lib/influxdb ./volumes/influxdb/data

echo "Copying Grafana"
docker cp grafana:/var/lib/grafana ./volumes/grafana/data

echo "Changing volume permissions"
chown -R root:root volumes
chmod -R 777 volumes

echo "Changing Gitlab git-data permissions"
sudo chown -R -v 998:root ./volumes/gitlab/data/gitlab/git-data
sudo chmod -R -v 0700 ./volumes/gitlab/data/gitlab/git-data

sudo chown -R -v 998:998 ./volumes/gitlab/data/gitlab/git-data/repositories
sudo chmod -R -v 2770 ./volumes/gitlab/data/gitlab/git-data/repositories

echo "***************************"
echo "Stopping and removing ephemeral containers"
echo "***************************"
docker-compose down

echo "***************************"
echo "Starting up persistent containers"
echo "***************************"
docker-compose up --build -d