# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).


## Unreleased - 2017-04-26
### Added
- Updated the Docker compose configuration to version 3
- Set up Docker volumes for the Docker containers in the Docker compose config
- Set up a Docker network in Docker compose that puts both containers (TDM & THREDDS)
  onto it
- Moved a lot of the configuration variables from Dockerfiles and Docker compose
  configuration file into an external environments file
- Removed the thredds-quickstart service from the compose configuration as it just
  duplicates the docker-production service
- Updated the Java startup options to move some hard coded values to environment
  variables
- Added a health check to the THREDDS Docker configuration that tests for a healthy
  response from the THREDDS server
- Removed the shell script that gets executed for the TDM Docker container. The
  command is now executed inline

## 4.6.10 - 2017-04-20
### Added
- 4.6.10 release of the Unidata TDS wrapped in a Docker container
