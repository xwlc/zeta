#!/usr/bin/env bash

if [[ "$0" == "hosts-sync.sh" ]]; then
  THIS_DIR="${PWD}"
else
  THIS_DIR="$(realpath "${0%/*}")"
fi

cat "${THIS_DIR}/hosts.private" > "${THIS_DIR}/hosts"
echo >> "${THIS_DIR}/hosts"

# https://api.github.com/meta
# https://raw.hellogithub.com/hosts
# https://github.com/521xueweihan/GitHub520
GitHub520RAW="https://raw.hellogithub.com/hosts"
echo "# Github IPs Update Timestamp $(date '+%F %T %z')" >> "${THIS_DIR}/hosts"
curl --silent ${GitHub520RAW} | head -n -6 | tail -n +2  >> "${THIS_DIR}/hosts"

sudo cp "${THIS_DIR}/hosts" /etc/hosts
