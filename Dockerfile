FROM findepi/pipelight:ubuntu-14.04
MAINTAINER Piotr Findeisen <piotr.findeisen@gmail.com>

RUN set -xe; \
    echo "preparing ..."; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get -y update; \
    \
    echo "installing silverlight ..."; \
    apt-get install -y --install-recommends tightvncserver; \
    pipelight-plugin --update; \
    pipelight-plugin --accept --enable silverlight; \
    useradd --create-home user-template; \
    sudo --set-home -u user-template bash -xe -c ' \
        `# prepare VNC; DISPLAY is required for silverlight installation` \
        mkdir ~/.vnc; \
        echo alamakota | vncpasswd -f > ~/.vnc/passwd; \
        chmod 0600 ~/.vnc/passwd; \
        vncserver -localhost :1; \
        export DISPLAY=:1; \
        \
        export WINE=/usr/share/pipelight/wine; \
        export WINEPREFIX="${HOME}"/.wine-pipelight; \
        export WINEARCH=win32; \
        export QUIETINSTALLATION=1; \
        /usr/share/pipelight/install-dependency \
            wine-silverlight5.1-installer wine-mpg2splt-installer; \
        \
        vncserver -kill :1; \
        rm -rf ~/.vnc; \
    '; \
    pipelight-plugin --create-mozilla-plugins; \
    userdel `# but no --remove` user-template; \
    apt-get purge -y --auto-remove tightvncserver; \
    echo "silverlight installed"; \
    \
    echo "installing firefox ..."; \
    apt-get install -y --install-recommends firefox; \
    echo "cleaning up ..."; \
    rm -rf /var/lib/apt/lists/*; `# Purge apt-get cache` \
    echo "done"

COPY setup-and-launch-firefox.sh /usr/local/bin/
