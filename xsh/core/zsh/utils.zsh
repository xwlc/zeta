# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-08-23T17:19:53+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

function @zeta:xsh:to-upper1() {
  local rest="$1" char1="${1[1]}"
  rest[1]='' # 删除字符串的首个字符
  echo "${char1:u}${rest}" # 小写 -> 大写(首个)
}

function @zeta:xsh:to-uppera()  {
  echo "${1:u}" # u 小写 -> 大写(全部)
}

function @zeta:xsh:to-lowera()  {
  echo "${1:l}" # l 小写 <- 大写(全部)
}

function @zeta:xsh:whats() {
  [[ $# -eq 0 ]] && return
  local var vtype output details xflag
  for var in $@; do
    vtype=''; details=''; xflag=0
    if declare -p "${var}" >& /dev/null; then
      vtype="${(tP)${var}}"
    else
      output="$(type -w ${var})"; xflag=$?
      [[ ${xflag} -eq 0 ]] && vtype="${output#${var}: }"
    fi

    if [[ -n "${_SILENT_:-}" ]]; then
      echo "${vtype}"; continue
    else
      # => `run-help type`
      # keyword, builtin, file, reserved, command, hashed
      case "${vtype}" in
        function) details="$(type -f ${var})" ;;
        alias) details="$(type -f ${var} | cut -d' ' -f6-)" ;;
      esac
    fi

    # - SHLVL 表示 Shell 进程的累加器
    #   执行 `bash` 或 `zsh` 后其值 +1
    # - ZSH_SUBSHELL 表示当前 Shell 进程中的 SubShell 的累加器
    #   执行 echo "--$(echo ${SHLVL})-$(echo ${ZSH_SUBSHELL})--"
    local context="\e[90m[D${SHLVL},S${ZSH_SUBSHELL}]\e[0m"
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
