FROM ubuntu:14.04
MAINTAINER Piotr Findeisen <piotr.findeisen@gmail.com>

RUN set -xe; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get -y update; \
    `# add-apt-repository` apt-get install -y software-properties-common; \
    `# pipelight` add-apt-repository -y ppa:pipelight/stable; \
    `# ttf-mscorefonts-installer` apt-add-repository -y multiverse; \
    `# wine-staging is i386` dpkg --add-architecture i386; \
    apt-get -y update; \
    `# Allow installation of MS corefonts (pipelight dependency)` \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula boolean true | debconf-set-selections; \
    apt-get install -y --install-recommends \
        firefox \
        pipelight-multi; \
    pipelight-plugin --update; \
    pipelight-plugin --accept --enable silverlight; \
    `# Purge apt-get cache` rm -rf /var/lib/apt/lists/*;

COPY setup-and-launch-firefox.sh /usr/local/bin/

