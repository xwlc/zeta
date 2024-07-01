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
  add-ip XX  140.82.114.4       gist.github.com         # 140.82  美国
  add-ip OK  140.82.116.4       gist.github.com         # 140.82  美国
  add-ip XX  185.199.108.153    github.githubassets.com # 185.199 美国

  add-ip OK   20.27.177.113     github.com  # 日本      平均时间 62.724
  add-ip XX   20.200.245.247    github.com  # 韩国      平均时间 89.889
  add-ip XX   20.207.73.82      github.com  # 印度      平均时间 189.354
  add-ip XX   20.29.134.23      github.com  # 美国      平均时间 206.488
  add-ip XX   20.248.137.48     github.com  # 澳大利亚  平均时间 206.754
  add-ip XX   20.233.83.145     github.com  # 阿联酋    平均时间 214.074
  add-ip XX   20.205.243.166    github.com  # 新加坡    平均时间 221.730
  add-ip XX   140.82.113.4      github.com  # 美国      平均时间 250.677
  add-ip XX   4.208.26.197      github.com  # 爱尔兰    平均时间 252.393
  add-ip XX   20.199.39.232     github.com  # 法国      平均时间 258.687
  add-ip XX   20.26.156.215     github.com  # 英格兰    平均时间 263.803
  add-ip XX   20.175.192.147    github.com  # 加拿大    平均时间 301.189
  add-ip XX   20.201.28.151     github.com  # 巴西      平均时间 389.250
  add-ip XX   20.87.245.0       github.com  # 南非      平均时间 420.538
fi

sudo cp "${THIS_DIR}/hosts" /etc/hosts
