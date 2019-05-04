# Tooling Dashboard

## Summary
This repo holds several docker-compose files that set up a basic Java oriented CICD environment in Docker, including a configured reverse proxy for easy access.

The containers will be persistent.

## Requirements
[Latest Docker CE version for your platform](https://docs.docker.com/install/)

Additional libraries for Ubuntu:
* [JQ](https://stedolan.github.io/jq/)


There are two 'versions' in this repo:

* `start_hosted.bat` or `start_hosted.sh`, this version uses hosted volumes 
* `start_mounted.sh`, this will create and use mounted volumes.

Hosted volumes are volumes created and managed by Docker. Mounted volumes are directories on the local filesystem that are mounted in the container.

`start_mounted.sh` will create a directory called 'volumes' which will contain a separate directory for each container.
These directories will be mounted inside of the container and will hold all the container's data.

The `start_hosted` version will make use of named volumes instead.

**`start_hosted` is the recommended approach! To make mounted volumes work I had to take some liberties with security. So is the entire volumes directory and all of its sub-directories are read- and writable by *any* user.** 

The following containers will be set up:
* [Nginx](https://hub.docker.com/_/nginx)
* [Jenkins](https://github.com/jenkinsci/docker/blob/master/README.md)
* [Sonarqube](https://hub.docker.com/_/sonarqube)
* [Nexus](https://hub.docker.com/r/sonatype/nexus3/)
* [Gitlab](https://docs.gitlab.com/omnibus/docker/)
* [InfluxDB](https://hub.docker.com/_/influxdb)
* [Grafana](https://hub.docker.com/r/grafana/grafana/)
* Three [Tomcat](https://hub.docker.com/_/tomcat) servers ('test', 'staging' and 'prod' to simulate different environments)

**Make sure you have enough resources to run this! (8gb RAM atleast)**

## Installation
### Ubuntu
Clone the repository to your local machine and make sure the shell-script has executable permissions.
Execute `./start_mounted.sh` or `./start_hosted.sh` as root.

### Windows
Clone the repository to your local machine and run the following command:
`start_hosted.bat`

Once everything is started up navigate to localhost to find the following dashboard available:
![Dashboard](/dashboard.jpg)

## Jenkins
In `sources\jenkins` there are two files:
* executors.groovy
* plugins.txt

In `executors.groovy` you can set the amount of executors Jenkins should use with the following line:

`Jenkins.instance.setNumExecutors(5)`

By default it will start with `5` executors but feel free to change this number to whatever you prefer.

In `plugins.txt` you can pre-install any desired plugins. See the [Jenkins Documentation](https://github.com/jenkinsci/docker#preinstalling-plugins) for more information





