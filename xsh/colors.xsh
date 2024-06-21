# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-10-19T20:13:29+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# Color standards for terminal emulators
# https://github.com/termstandard/colors

# Difference between `printf` and `echo`
# NOTE Bash `echo` do not enable -e by default
# https://unix.stackexchange.com/questions/58310
# https://www.in-ulm.de/~mascheck/various/echo+printf/
# => TIMEFORMAT=$"e-loop => Real=%3lR(s) User=%3lU(s) Sys=%3lS(s)"
# => time for i in {1..999999}; do echo "$i" >/dev/null; done
# => TIMEFORMAT=$"p-loop => Real=%3lR(s) User=%3lU(s) Sys=%3lS(s)"
# => time for i in {1..999999}; do printf "$i" >/dev/null; done
#
# -> e-loop => Real=0m3.977s(s) User=0m2.033s(s) Sys=0m1.938s(s)
# -> p-loop => Real=0m3.879s(s) User=0m1.864s(s) Sys=0m2.008s(s)

# ANSI Colors Frequently Used In Terminal
function @D3() { builtin printf "\e[0;30m%s\e[0m" "$*"; } # Dark(Black)
function @R3() { builtin printf "\e[0;31m%s\e[0m" "$*"; } # Red
function @G3() { builtin printf "\e[0;32m%s\e[0m" "$*"; } # Green
function @Y3() { builtin printf "\e[0;33m%s\e[0m" "$*"; } # Yellow
function @B3() { builtin printf "\e[0;34m%s\e[0m" "$*"; } # Blue
function @P3() { builtin printf "\e[0;35m%s\e[0m" "$*"; } # Purple
function @C3() { builtin printf "\e[0;36m%s\e[0m" "$*"; } # Cyan
function @W3() { builtin printf "\e[0;37m%s\e[0m" "$*"; } # White

function @D9() { builtin printf "\e[0;90m%s\e[0m" "$*"; } # Dark(Grey)
function @R9() { builtin printf "\e[0;91m%s\e[0m" "$*"; } # Red
function @G9() { builtin printf "\e[0;92m%s\e[0m" "$*"; } # Green
function @Y9() { builtin printf "\e[0;93m%s\e[0m" "$*"; } # Yellow
function @B9() { builtin printf "\e[0;94m%s\e[0m" "$*"; } # Blue
function @P9() { builtin printf "\e[0;95m%s\e[0m" "$*"; } # Purple
function @C9() { builtin printf "\e[0;96m%s\e[0m" "$*"; } # Cyan
function @W9() { builtin printf "\e[0;97m%s\e[0m" "$*"; } # White

# $1 灰色梯度索引号[0, 23]
function @GS() {
  [ $# -lt 2 ] && return
  [[ -z "$1" || -n "${1//[0-9]/}" ]] && return 1
  if (( $1 >= 0 && $1 <= 23 )); then
    # 232 ~ 255 is Grayscale Ramp
    local ramp=$(( $1 + 232 )); shift
    # 字体 \e[38;5;  背景 \e[48;5;
    builtin printf "\e[38;5;${ramp}m%s\e[0m" "$*"
  fi
}

# @ES [code] <msg>
# 0 重置  1  黑体粗体  4  显示下划线  5  开始闪烁  7  颜色翻转  2 亮度减半
# m 语法  22 常规字体  24 取消下划线  25 取消闪烁  27 翻转恢复
function @ES() { # Escape Sequence
  local fmt='0'
  while (( $# > 0 )); do
    # https://www.computerhope.com/unix/used.htm
    # https://www.runoob.com/linux/linux-comm-sed.html
    # https://www.w3schools.cn/unix/unix_regular_expressions.asp
    # ^匹配行开头  $匹配行结尾  p仅显示匹配结果  *前模式匹配零次或多次
    # \+前模式匹配一次或多次  \?前模式匹配零次或一次  \(和\)模式组
    if [[ -n "$1" && -z "${1//[0-9]/}" ]]; then
    #  [[ -n "$(echo "$1" | sed -n '/^[0-9]\+$/p')" ]]
      builtin printf -v fmt "%s;%d"  "${fmt}"  "$1"
    elif [[ -n "$1" && -z "${1//[0-9;]/}" ]]; then
    #    [[ -n "$(echo "$1" | sed -n '/^\([0-9]\+;\)\+[0-9]\+$/p')" ]]
      builtin printf -v fmt "%s;%s"  "${fmt}"  "$1"
    else
      break
    fi
    shift
  done

  [ $# -eq 0 ] && return # no message
  # ESC[ 转移序列开始标志 \0x1B[ 或 \033[ 或 \e[
  # ECMA-48 SGR 转义序列语法: ESC[ ARG m  可含多属性, 分号分割
  #echo "fmt=[${fmt}]"
  #echo "msg=[$*]"
  builtin printf "\e[${fmt}m%s\e[0m" "$*"
}

function @colored() {
  ! declare -p RbIdx > /dev/null 2>&1 && return
  ! declare -p RbOut > /dev/null 2>&1 && return
  local _RbCNS_=( G3 Y3 B3 P3  G9 Y9 B9 P9 )
  local _RbMax_=${#_RbCNS_[@]} _RbMsg_="$1"
  local G3='\e[32m' Y3='\e[33m' B3='\e[34m' P3='\e[35m'
  local G9='\e[92m' Y9='\e[93m' B9='\e[94m' P9='\e[95m'
  if [[ -n "${BASH_VERSION}" ]]; then
    [[ -z "${RbIdx}" ]] && RbIdx=0
    eval 'RbOut="${!_RbCNS_[${RbIdx}]}${_RbMsg_}\e[0m"'
    (( RbIdx++, RbIdx = RbIdx % _RbMax_ ))
  elif [[ -n "${ZSH_VERSION}"  ]]; then
    [[ -z "${RbIdx}" || ${RbIdx} -eq 0 ]] && RbIdx=1
    eval 'RbOut="${(P)_RbCNS_[${RbIdx}]}${_RbMsg_}\e[0m"'
    (( RbIdx++, RbIdx = RbIdx % _RbMax_ ))
  fi
}

function @rainbow() {
  local xTitle="$1" xMsg  zFB zLB zIt; shift
  local y1='\e[1;5;90m' y2='\e[0m' RbIdx RbOut
  for zIt in "$@"; do
    zFB="${zIt:0:1}"; zLB="${zIt:${#zIt}-1:1}"
    case "${zFB}${zLB}" in
      "[]") @colored "${zIt:1:${#zIt}-2}"; xMsg+=" ${y1}[${y2}${RbOut}${y1}]${y2}" ;;
      "<>") @colored "${zIt:1:${#zIt}-2}"; xMsg+=" ${y1}<${y2}${RbOut}${y1}>${y2}" ;;
      "()") @colored "${zIt:1:${#zIt}-2}"; xMsg+=" ${y1}(${y2}${RbOut}${y1})${y2}" ;;
      "{}") @colored "${zIt:1:${#zIt}-2}"; xMsg+=" ${y1}{${y2}${RbOut}${y1}}${y2}" ;;
         *) @colored "${zIt}"; xMsg+=" ${RbOut}" ;;
    esac
  done; printf "${xTitle}${xMsg}\n"
}

function zeta-term-color-preview() {
  echo
  printf "msg1 $(@ES '4;5;32' "@ES => 绿色+闪烁+下划线") msg1-end\n"
  echo "msg2 $(@ES 38 5 242 '@ES => grey message again') msg2-end"
  @ES '38;5;242' msg3 @ES '=>' grey message with literally '\n'; echo ' msg3-end'
  echo

  # 字体色
  local X='\e[0m' # ANSI Colors Frequently Used In Terminal
  local D3='\e[0;30m' R3='\e[0;31m' G3='\e[0;32m' Y3='\e[0;33m'
  local B3='\e[0;34m' P3='\e[0;35m' C3='\e[0;36m' W3='\e[0;37m'
  local D9='\e[0;90m' R9='\e[0;91m' G9='\e[0;92m' Y9='\e[0;93m'
  local B9='\e[0;94m' P9='\e[0;95m' C9='\e[0;96m' W9='\e[0;97m'
  # 背景色
  local bgD4='\e[0;40m' bgR4='\e[0;41m' bgC4='\e[0;46m' bgP4='\e[0;45m'
  local bgB4='\e[0;44m' bgG4='\e[0;42m' bgY4='\e[0;43m' bgW4='\e[0;47m'

  # 256-color 模式: 前 16 种预定义颜色
  local fg256='\e[38;5;' bg256='\e[48;5;'
  local cm256="${fg256}"
  local Di0="${cm256}0m" Ri1="${cm256}1m" Gi2="${cm256}2m" Yi3="${cm256}3m"
  local Bi4="${cm256}4m" Pi5="${cm256}5m" Ci6="${cm256}6m" Wi7="${cm256}7m"
  local Di8="${cm256}8m"   Ri9="${cm256}9m"   Gi10="${cm256}10m" Yi11="${cm256}11m"
  local Bi12="${cm256}12m" Pi13="${cm256}13m" Ci14="${cm256}14m" Wi15="${cm256}15m"

  echo "基础色"
  printf  "[$(@D3 @D3)${D3}黑${X}] [$(@R3 @R3)${R3}红${X}] [$(@G3 @G3)${G3}绿${X}] [$(@Y3 @Y3)${Y3}黄${X}] "
  echo -e "[$(@B3 @B3)${B3}蓝${X}] [$(@P3 @P3)${P3}紫${X}] [$(@C3 @C3)${C3}青${X}] [$(@W3 @W3)${W3}白${X}]"
  printf  "[$(@D9 @D9)${D9}灰${X}] [$(@R9 @R9)${R9}红${X}] [$(@G9 @G9)${G9}绿${X}] [$(@Y9 @Y9)${Y9}黄${X}] "
  echo -e "[$(@B9 @B9)${B9}蓝${X}] [$(@P9 @P9)${P9}紫${X}] [$(@C9 @C9)${C9}青${X}] [$(@W9 @W9)${W9}白${X}]"

  printf "\n256Color 模式[0-15]\n"
  local idx colorIdx
  for idx in {0..15}; do
    printf -v colorIdx "CI=%02d" ${idx}
    printf "[${cm256}${idx}m${colorIdx}${X}] "
    (( ${idx} == 7 )) && echo
  done

  printf "\n\n灰色梯度表\n"
  local ramp
  for idx in {0..23}; do
    printf -v ramp "GS=%02d" ${idx}
    printf "[";  @GS ${idx} "${ramp}"; printf "] "
    [ ${idx} -eq 11 ] && {
      echo; local cnt=1
      for cnt in {1..12}; do printf "[$(@D9 @D9灰)] "; done
      echo
    }
  done
  echo; echo
}
