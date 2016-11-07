# findepi/firefox-silverlight-pipelight

## Introduction

The image contains firefox with silverlight run via pipelight.

The image uses X11 and Pulseaudio fowarding (or socket sharing) to allow the
application inside the container to display graphics and play audio.

## Usage

To launch the firefox with Silverlight plugin type the following:

```
docker_image=findepi/firefox-silverlight-pipelight \
    && docker run \
        --interactive --tty --rm \
        `#--env SOCKS_SERVER="socks://172.17.0.1:5080" --env SOCKS_VERSION=5` \
        `# X display` \
        --env DISPLAY="${DISPLAY}" --volume /tmp/.X11-unix:/tmp/.X11-unix \
        `# pulse sound` \
        --env PULSE_SERVER="unix:/tmp/pulse-unix" \
        --volume /run/user/"${UID}"/pulse/native:/tmp/pulse-unix \
        `# X-related devices` \
        $(find /dev/dri -type c -printf '--device %p\n') \
        `# time zones` \
        --volume /etc/localtime:/etc/localtime:ro \
        --volume /etc/timezone:/etc/timezone:ro \
        `# disabling GPU acceleration was required in *my* case` \
        --env PIPELIGHT_GPUACCELERATION=0 \
        "${docker_image}" \
            `# create user, a firefox profile, enable silverlight plugin and open a page` \
            /usr/local/bin/setup-and-launch-firefox.sh \
            -u "${UID}"
```

### Persistent profile

If you want your Dockerized Firefox's profile to be preserved across runs in
`~/.firefox-with-silverlight`, use the following:

```
docker_image=findepi/firefox-silverlight-pipelight \
    && persistent_storage="${HOME}/.firefox-with-silverlight" \
    && mkdir -p "${persistent_storage}" \
    && docker run \
        --interactive --tty --rm \
        `#--env SOCKS_SERVER="socks://172.17.0.1:5080" --env SOCKS_VERSION=5` \
        `# X display` \
        --env DISPLAY="${DISPLAY}" --volume /tmp/.X11-unix:/tmp/.X11-unix \
        `# pulse sound` \
        --env PULSE_SERVER="unix:/tmp/pulse-unix" \
        --volume /run/user/"${UID}"/pulse/native:/tmp/pulse-unix \
        `# X-related devices` \
        $(find /dev/dri -type c -printf '--device %p\n') \
        `# time zones` \
        --volume /etc/localtime:/etc/localtime:ro \
        --volume /etc/timezone:/etc/timezone:ro \
        --volume "${persistent_storage}:/firefox-profile-dir" \
        `# disabling GPU acceleration was required in *my* case` \
        --env PIPELIGHT_GPUACCELERATION=0 \
        "${docker_image}" \
            `# create user, a firefox profile, enable silverlight plugin and open a page` \
            /usr/local/bin/setup-and-launch-firefox.sh \
            -u "${UID}"
```

### Persistent profile & fast startup

Unfortunately, Silverlight is not truly free software. As far as its licence can be understood,
redistribution is not allowed, so an image with Silverlight already installed cannot be shared
on dockerhub or elsewhere. Therefore, each run of this docker image pulls fresh Silverlight
installer from Internet and runs it. And this takes time.

However, there's nothing stopping you from creating a local docker image that has everything needed
already in it, so that it starts fast. You just need to remember not to share it (or don't tell
anyone).

1. Start the image using the above command (the one setting up a persistent Firefox profile)
2. Once everything is installed and browser is started you should
   - note down the container id, as reported by `docker ps -a`
   - then save the container as an image with `docker commit <container-id>
   firefox-silverlight-pipelight-installed`
   - exit, remove or do  whatever with the current container.
3. To start the container again, issue the following command

```
docker_image=firefox-silverlight-pipelight-installed \
    && persistent_storage="${HOME}/.firefox-with-silverlight" \
    && test -d "${persistent_storage}" \
    && docker run \
        --interactive --tty --rm \
        `#--env SOCKS_SERVER="socks://172.17.0.1:5080" --env SOCKS_VERSION=5` \
        `# X display` \
        --env DISPLAY="${DISPLAY}" --volume /tmp/.X11-unix:/tmp/.X11-unix \
        `# pulse sound` \
        --env PULSE_SERVER="unix:/tmp/pulse-unix" \
        --volume /run/user/"${UID}"/pulse/native:/tmp/pulse-unix \
        `# X-related devices` \
        $(find /dev/dri -type c -printf '--device %p\n') \
        `# time zones` \
        --volume /etc/localtime:/etc/localtime:ro \
        --volume /etc/timezone:/etc/timezone:ro \
        --volume "${persistent_storage}:/firefox-profile-dir" \
        `# disabling GPU acceleration was required in *my* case` \
        --env PIPELIGHT_GPUACCELERATION=0 \
        "${docker_image}" \
            `# Launch firefox profile, using silverlight already installed` \
            /usr/bin/env \
            /usr/local/bin/run-firefox http://bubblemark.com/silverlight2.html
```

Important note: because the image start scripts create a user account inside
docker container with the user ID matching the running user ID, the thus saved
container can be used only by the very user who created it.

## Contributing

Fork on Github.
