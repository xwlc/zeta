#!/usr/bin/env bash

THIS_AFP="$(realpath "${0}")"        # 当前文件绝对路径(含名)
THIS_FNO="$(basename "${THIS_AFP}")" # 仅包含当前文件的文件名
THIS_DIR="$(dirname  "${THIS_AFP}")" # 当前文件所在的绝对路径
# printf "[${THIS_AFP}]\n[${THIS_DIR}] [${THIS_FNO}]\n"; exit

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
  # 20.201  巴西   20.87  南非     20.248 澳大利亚   20.26  英格兰
  # 20.207  印度   20.199 法国     20.175 加拿大
  # 20.29   美国   4.208  爱尔兰   20.233 阿联酋

  add-ip OK  20.200.245.247     github.com # 韩国   20.200
  add-ip XX  20.205.243.166     github.com # 新加坡 20.205
  add-ip XX  20.27.177.113      github.com # 日本   20.27
  add-ip XX  140.82.113.4       github.com # 美国   140.82

  add-ip XX  140.82.114.4       gist.github.com
  add-ip OK  140.82.116.4       gist.github.com

  add-ip XX  185.199.108.153    github.githubassets.com # 美国 185.199
fi

sudo cp "${THIS_DIR}/hosts" /etc/hosts
