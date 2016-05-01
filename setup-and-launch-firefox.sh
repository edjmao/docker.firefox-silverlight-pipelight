#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

uid=1000
uname=firefox

silverlight_test_page=http://bubblemark.com/silverlight2.html

while test $# -gt 0; do
    case "$1" in
        -u)
            uid="$2"; shift;;

        --)
            shift; break;;

        -*)
            echo "unknown option $1" >&2; exit 1;;

        *)
            break;;
    esac
    shift
done

set -x

useradd --create-home --uid "${uid}" "${uname}"
cd "/home/${uname}"

cat >/usr/local/bin/run-as-user <<EOF
#/bin/sh
exec sudo --set-home --preserve-env -u "${uname}" "\$@"
EOF
chmod +x /usr/local/bin/run-as-user

cat >/usr/local/bin/run-firefox <<EOF
#/bin/sh
exec run-as-user firefox "\$@"
EOF
chmod +x /usr/local/bin/run-firefox

# We want to reach the interactive shell even when things go wrong.
set +o errexit

# Force actual installation.
run-as-user env \
    WINE=/opt/wine-staging/bin/wine \
    WINEPREFIX=/home/"${uname}"/.wine-pipelight \
    WINEARCH=win32 \
    QUIETINSTALLATION=1 \
    /usr/share/pipelight/install-dependency \
    wine-silverlight5.1-installer wine-mpg2splt-installer

pipelight-plugin --create-mozilla-plugins

# Done. We should be able to use the browser.
run-firefox -new-instance "${silverlight_test_page}"

test -t 0 && test -t 1 && {
    set +x
    echo
    echo
    echo
    echo
    echo "  Just in case you want to poke around, I'm dropping you into a shell."
    echo "  To run the browser, use \`run-firefox' command instead of \`firefox'.  This will"
    echo "  run firefox as the '${uname}' user, rather than 'root'."
    echo "  If you want an interactive shell running as your Docker alter ego, type:"
    echo "  \`run-as-user bash -l'"
    echo
    exec bash -l
}

