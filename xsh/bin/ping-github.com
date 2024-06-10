#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2024 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2024-05-22T07:28:46+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

if [[ -n "${XCOLORS}" && -f "${XCOLORS}" ]]; then
  source "${XCOLORS}"
else
  exit 255
fi

function has-cmd() {  command -v "$1" > /dev/null; }
function no-cmd() { ! command -v "$1" > /dev/null; }

# https://ping.ceo/ping/github.com
# https://ping.chinaz.com/github.com
# https://raw.hellogithub.com/hosts

declare -A IpLocName=(
  "20.201"  "巴西"     "20.205"   "新加坡"
  "20.87"   "南非"     "20.248"   "澳大利亚"
  "20.207"  "印度"     "20.27"    "日本"
  "20.200"  "韩国"     "20.175"   "加拿大"
  "20.233"  "阿联酋"   "20.29"    "美国"
  "20.199"  "法国"     "4.208"    "爱尔兰"
  "20.26"   "英格兰"   "185.199"  "美国"
)

# https://api.github.com/meta
GithubWebIPs=(
  "20.201.28.151"   "20.205.243.166"  "20.87.245.0"       "20.248.137.48"
  "20.207.73.82"    "20.27.177.113"   "20.200.245.247"    "20.175.192.147"
  "20.233.83.145"   "20.29.134.23"    "20.199.39.232"     "4.208.26.197"
  "20.26.156.215"
)

GithubApiIPs=(
  "20.201.28.148"     "20.205.243.168"  "20.87.245.6"       "20.248.137.49"
  "20.207.73.85"      "20.27.177.116"   "20.200.245.245"    "20.175.192.149"
  "20.233.83.146"     "20.29.134.17"    "20.199.39.228"     "4.208.26.200"
  "20.26.156.210"
)

GithubGitIPs=(
  "20.201.28.151"   "20.205.243.166"  "20.87.245.0"     "20.248.137.48"
  "20.207.73.82"    "20.27.177.113"   "20.200.245.247"  "20.175.192.147"
  "20.233.83.145"   "20.29.134.23"    "20.199.39.232"   "4.208.26.197"
  "20.26.156.215"   "20.201.28.152"   "20.205.243.160"  "20.87.245.4"
  "20.248.137.50"   "20.207.73.83"    "20.27.177.118"   "20.200.245.248"
  "20.175.192.146"  "20.233.83.149"   "20.29.134.19"    "20.199.39.227"
  "4.208.26.198"    "20.26.156.214"
)

# github.githubassets.com
GithubPagesIPs=(
  "185.199.108.153"   "185.199.109.153"  "185.199.110.153"   "185.199.111.153"
)

function xping() {
  local xip=$1 xloc=$2 xmsg MinAvgMax
  printf "$(@D9 PING) $(@R3 %-15s) $(@D9 %-8s) " ${xip} ${xloc}
# fping -4 -c10 -t200  ${xip} # 200 毫秒 = 0.2 秒
  xmsg="$(ping -4 -q -c10 -i 0.2 ${xip} | tail -n 1)"
  MinAvgMax="$(echo "${xmsg}" | cut -d= -f2 | cut -d' ' -f2)"
  local min=$(echo "${MinAvgMax}" | cut -d/ -f1)
  local avg=$(echo "${MinAvgMax}" | cut -d/ -f2)
  local max=$(echo "${MinAvgMax}" | cut -d/ -f3)
  printf "$(@D9 Avg)=$(@G3 %-8s) " ${avg}
  printf "$(@D9 Min)=$(@B3 %-8s) " ${min}
  printf "$(@D9 Max)=$(@Y3 %-8s)\n" ${max}
}

#######
# NOTE 执行命令 $ curl -v https://github.com 查看哪个地址卡(设置 HOSTs)
#######
for xIP in ${GithubPagesIPs[*]}; do
  IpAddr="${xIP%.*}"
  IpAddr="${IpAddr%.*}"
  IpAddr="${IpLocName["${IpAddr}"]}"
  [[ -z "${IpAddr}" ]] && IpAddr=XXXX

  xping ${IpAddr} ${xIP}
done
