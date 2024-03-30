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
  local var vtype output details
  for var in $@; do
    vtype='' details=''
    if declare -p "${var}" >& /dev/null; then
      vtype="${(tP)${var}}"
    else
      output="$(type -w ${var} | cut -d' ' -f2)"
      [[ $? -eq 0 ]] && vtype="${output}"
    fi

    if [[ -n "${_SILENT_:-}" ]]; then
      echo "${vtype}"
      continue
    else
      # => `run-help type`
      # keyword, builtin, file, reserved, command, hashed
      case "${vtype}" in
        function) details="$(type -f ${var})" ;;
        alias) details="$(type -f ${var} | cut -d' ' -f6-)" ;;
      esac
    fi

    local context="\e[90m[${SHLVL}][${ZSH_SUBSHELL}]\e[0m"
    if [[ -z "${vtype}" ]]; then
      echo "${context} $(@Y9 ${var}) $(@D9 '->') $(@R3 Unknown)"
    else
      echo "${context} $(@Y9 ${var}) $(@D9 '->') $(@G9 ${vtype})"
      [[ -n "${details}" ]] && echo "${details}"
    fi
  done
}
