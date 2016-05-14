FROM findepi/pipelight:ubuntu-14.04
MAINTAINER Piotr Findeisen <piotr.findeisen@gmail.com>

# Install firefox and things required to proceed
RUN set -xe; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get -y update; \
    apt-get install -y --install-recommends \
        firefox \
        tightvncserver `# for silverlight installation` \
        ; \
    rm -rf /var/lib/apt/lists/*; `# Purge apt-get cache` \
    echo "done"

# Create `user-template' user and download silverlight plugin into its HOME
RUN set -xe; \
    pipelight-plugin --update; \
    pipelight-plugin --accept --enable silverlight; \
    useradd --create-home user-template; \
    sudo --set-home -u user-template bash -xe -c ' \
        `# prepare VNC; DISPLAY is required for silverlight installation` \
        mkdir ~/.vnc; \
        echo alamakota | vncpasswd -f > ~/.vnc/passwd; \
        chmod 0600 ~/.vnc/passwd; \
        vncserver -localhost :1; \
        `#sleep 6;` `# does VNC require time to start?` \
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
    echo "silverlight installed"

# Cleanup now obsolete packages
RUN set -xe; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get purge -y --auto-remove tightvncserver; \
    echo "all OK"

COPY setup-and-launch-firefox.sh /usr/local/bin/

