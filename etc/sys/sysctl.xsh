#!/usr/bin/env bash

if [[ "$0" == "sysctl.xsh" ]]; then
  THIS_DIR="${PWD}"
else
  THIS_DIR="$(realpath "${0%/*}")"
fi

sudo cp "${THIS_DIR}/sysctl.conf" /etc/sysctl.conf
