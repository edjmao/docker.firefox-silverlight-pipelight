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

useradd `# but no --create-home` --uid "${uid}" "${uname}"
cp -a "/home/user-template" "/home/${uname}"
chown -R "${uname}": "/home/${uname}"

# By using fixed location outside of HOME, we allow this to be mounted as
# persistent volume at run-time.
mkdir -p /firefox-profile-dir
chown -R "${uname}:" /firefox-profile-dir
ln -s /firefox-profile-dir .mozilla

exec sudo --set-home --preserve-env -u "${uname}" firefox -new-instance "${silverlight_test_page}"
