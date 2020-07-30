FROM debian:buster
LABEL maintainer="Patrick Pacher <patrick@safing.io>"


# Installs the `dpkg-buildpackage` command
RUN apt-get update \
    && apt-get install curl build-essential debhelper devscripts equivs imagemagick -y --no-install-recommends \
    && apt-get clean


# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
