# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [4.6.13] - 2019-02-12
### Updated
- 4.6.13 release of the Unidata TDS wrapped in a Docker container
- Docker compose to 3.7 version

### Removed
- Configs section in swarm compose

## [4.6.12] - 2018-12-12
### Added
- 4.6.12 release of the Unidata TDS wrapped in a Docker container
- Minor readme improvements
- Updated netCDF and related packages
- ncsos no longer needs a separate
- Use /dev/urandom for random numbers
- Updated to unidata/tomcat-docker:8.5
- Instructions for parameterizing uid/gid

## [4.6.11] - 2017-12-07
### Added
- 4.6.11 release of the Unidata TDS wrapped in a Docker container
- Changed artifacts.unidata.ucar.edu/content/repositories to artifacts.unidata.ucar.edu/repository¯
- Added Docker Swarm configuration and documentation
- Added docker healthcheck feature
- Added parameterization of JNA temporary directory
- Fixed HDF download URL
- Added TDM environment variables for running of the TDM
- Migrated docker-compose to version 3 of docker-compose
- Fixed trailing space
- Added parameterization of docker-compose w/ environment variables
- Changed to version 1.3 of ncsos
- Changed copyright to 2017
- Removed the TDM container which is now in its own repo: unidata/tdm-docker
- Added some information concerning docker-machine
- Added this CHANGELOG

## [4.6.10] - 2017-04-20
### Added
- 4.6.10 release of the Unidata TDS wrapped in a Docker container

[Unreleased]: https://github.com/Unidata/thredds-docker/compare/v4.6.13...HEAD
[4.6.13]: https://github.com/Unidata/thredds-docker/compare/v4.6.12...v4.6.13
[4.6.12]: https://github.com/Unidata/thredds-docker/compare/v4.6.11...v4.6.12
[4.6.11]: https://github.com/Unidata/thredds-docker/compare/v4.6.10...v4.6.11
