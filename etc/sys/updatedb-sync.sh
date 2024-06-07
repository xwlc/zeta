#!/usr/bin/env bash

if [[ "$0" == "updatedb-sync.sh" ]]; then
  THIS_DIR="${PWD}"
else
  THIS_DIR="$(realpath "${0%/*}")"
fi

sudo cp "${THIS_DIR}/updatedb.conf" /etc/updatedb.conf

if false; then
  man updatedb.conf
  updatedb # 更新 /var/lib/plocate/plocate.db
  locate # 默认索引 /var/lib/plocate/plocate.db
fi
