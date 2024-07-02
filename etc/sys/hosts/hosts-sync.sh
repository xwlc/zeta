#!/usr/bin/env bash

THIS_AFP="$(realpath "${0}")"        # 当前文件绝对路径(含名)
THIS_FNO="$(basename "${THIS_AFP}")" # 仅包含当前文件的文件名
THIS_DIR="$(dirname  "${THIS_AFP}")" # 当前文件所在的绝对路径

cat "${THIS_DIR}/hosts.private" > "${THIS_DIR}/hosts"
echo >> "${THIS_DIR}/hosts"

function add-ip() {
  [[ $1 != OK ]] && return
  printf "%-20s%s\n" $2 $3 >> "${THIS_DIR}/hosts"
}

if false; then
  # https://api.github.com/meta
  # https://raw.hellogithub.com/hosts
  # https://github.com/521xueweihan/GitHub520
  GitHub520RAW="https://raw.hellogithub.com/hosts"
  echo "# Github IPs Update Timestamp $(date '+%F %T %z')" >> "${THIS_DIR}/hosts"
  curl --silent ${GitHub520RAW} | head -n -6 | tail -n +2  >> "${THIS_DIR}/hosts"
else
  add-ip XX   140.82.112.3     github.com # 美国
  add-ip XX   140.82.113.4     github.com # 美国
  add-ip OK   140.82.114.4     github.com # 美国
  add-ip XX   140.82.116.4     github.com # 美国
  add-ip XX   20.29.134.23     github.com # 美国
  add-ip XX   20.233.83.145    github.com # 阿联酋
  add-ip XX   20.248.137.48    github.com # 澳大利亚

  add-ip XX   140.82.112.3     gist.github.com # 美国
  add-ip XX   140.82.113.4     gist.github.com # 美国
  add-ip XX   140.82.114.4     gist.github.com # 美国
  add-ip OK   140.82.116.4     gist.github.com # 美国
  add-ip XX   20.29.134.23     gist.github.com # 美国
  add-ip XX   20.233.83.145    gist.github.com # 阿联酋
  add-ip XX   20.248.137.48    gist.github.com # 澳大利亚
fi

sudo cp "${THIS_DIR}/hosts" /etc/hosts
