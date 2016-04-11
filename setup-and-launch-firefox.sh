#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

uid=1000
uname=firefox

silverlight_test_page=http://bubblemark.com/silverlight2.html
installation_wizard=https://github.com/findepi/docker.firefox-silverlight-pipelight/blob/master/INSTALL-WIZARD.md

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

cat >/usr/local/bin/run-firefox <<EOF
#/bin/sh
exec sudo --set-home --preserve-env -u "${uname}" firefox "\$@"
EOF
chmod +x /usr/local/bin/run-firefox

# We want to reach the interactive shell even when things go wrong.
set +o errexit

# Opening a page using silverlight will trigger actual install. Opening it
# together with our Installation Wizard gives user chance to behave
# accordingly.
run-firefox -new-instance "${installation_wizard}" "${silverlight_test_page}"
# Now user waits for the silverlight to be installed, as instructed by the
# Wizard. If they choose to close firefox before installation finishes, it will
# be aborted, and the next line probably ineffective. (I must admit I didn't
# dig long enough to understand correlation between sliverlight plugin lazy
# installation and the --create-mozilla-plugins command.)
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
    echo
    exec bash -l
}

