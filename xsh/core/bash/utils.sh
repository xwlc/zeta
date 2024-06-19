# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-08-23T17:19:53+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

function @zeta:xsh:to-upper1() { echo "${1@u}"; } # u 小写 -> 大写(首个)

function @zeta:xsh:to-uppera() { echo "${1@U}"; } # U 小写 -> 大写(全部)
function @zeta:xsh:to-lowera() { echo "${1@L}"; } # L 小写 <- 大写(全部)

function @zeta:xsh:whats() {
  [[ $# -eq 0 ]] && return
  local var vtype output details xflag
  for var in $@; do
    vtype=''; details=''; xflag=0
    # NOTE 仅显示指定属性的变量
    # => declare -p -x  仅显示[拥有] export 属性变量
    # => declare -p +x  仅显示[没有] export 属性变量
    if declare -p "${var}" >& /dev/null; then
      local attrs="${!var@a}" # 获取属性字符串
      # NOTE 普通变量属性字符串为空, 用 Z 标记
      [[ -z "${attrs}" ]] && attrs=Z
      # NOTE [确保]属性值按照 aAilnrtux 顺序排序
      #      即 help declare 命令帮助中显示的顺序
      # -n 属性表示变量使用时自动间接引用, ${V3} 的值 OK, 等效于 ${!V2}
      #    V1='OK'; V2=V1; declare -n V3=V1
      #    echo "[${V1}] -> [${V2}]?=V1 [${!V2}]?=OK [${V3}]?=OK"
      # -l 属性表示变量赋值时自动将 大写 -> 小写, 即变量值始终都是[小写]
      # -u 属性表示变量赋值时自动将 大写 <- 小写, 即变量值始终都是[大写]
      local OPTERR  OPTARG  OPTIND=1  opt
      while getopts 'aAilnrtuxZ' opt "-${attrs}"; do
        # 属性显示方式参考 Zsh 手册 14.3.1 节
        # keywords separated by hyphens(-)
        case "${opt}" in
          a) vtype='array'        ;;
          A) vtype='association'  ;;
          i) vtype='integer'      ;;
          l) vtype='lower'        ;;
          n) vtype='reference'    ;;
          r) vtype='readonly'     ;;
          t) vtype='trace'        ;;
          u) vtype='upper'        ;;
          x) vtype='export'       ;;
          Z) vtype='scalar'       ;;
        esac
      done
    else
      output="$(type -t "${var}")"; xflag=$?
      [[ ${xflag} -eq 0 ]] && vtype="${output}"
    fi

    if [[ -n "${_SILENT_:-}" ]]; then
      echo "${vtype}"; continue
    else
      case "${vtype}" in # 参考 => `help type`
        function) details="$(type ${var} | tail +2)" ;;
        alias) details="$(type ${var} | cut -d'`' -f2 | cut -d"'" -f1)" ;;
      esac
    fi

    # - SHLVL 表示 Shell 进程的累加器
    #   执行 `bash` 或 `zsh` 后其值 +1
    # - BASH_SUBSHELL 表示当前 Shell 进程中的 SubShell 的累加器
    #   执行 echo "--$(echo ${SHLVL})-$(echo ${BASH_SUBSHELL})--"
    local context=$'\e[90m'"[D${SHLVL},S${BASH_SUBSHELL}]"$'\e[0m'
    if [[ -z "${vtype}" ]]; then
      if (( xflag == 0 )); then
        echo "${context} $(@Y9 ${var}) $(@D9 '->') $(@G9 none)"
      else
        echo "${context} $(@Y9 ${var}) $(@D9 '->') $(@R3 undefined)"
      fi
    else
      echo "${context} $(@Y9 ${var}) $(@D9 '->') $(@G9 ${vtype})"
      [[ -n "${details}" ]] && echo "${details}"
    fi
  done
}
