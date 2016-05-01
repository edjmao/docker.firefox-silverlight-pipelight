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

## Contributing

Fork on Github.
