FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

# wine settings
ENV WINEARCH win32
ENV WINEDEBUG fixme-all
ENV WINEPREFIX /wine

RUN set -x \
    && dpkg --add-architecture i386 \
    && apt-get update -qy \
    && apt-get install --no-install-recommends -qfy wine32-development wine-development wget curl ca-certificates build-essential \
    && apt-get clean \
    && wget -q http://downloads.sourceforge.net/project/nsis/NSIS%203/3.05/nsis-3.05-setup.exe \
    && wine nsis-3.05-setup.exe /S \
    && while pgrep wineserver >/dev/null; do echo "Waiting for wineserver"; sleep 1; done \
    && rm -rf /tmp/.wine-* \
    && echo 'wine '\''C:\Program Files\NSIS\makensis.exe'\'' "$@"' > /usr/bin/makensis \
    && chmod +x /usr/bin/*

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
