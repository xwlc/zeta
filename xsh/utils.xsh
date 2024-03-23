# SPDX-License-Identifier: GPL-3.0 OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-25T09:50:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# NOTE 解析位置参数
# help getopts, run-help getopts
# 共享环境变量: OPTERR, OPTIND, OPTARG
# OPTERR='' ZSH 默认, OPTERR=1 Bash 默认
# 等于 1 则表示若解析错误显示相关诊断信息

# 显示时间  -s 或 -S
# 隐藏时间  -h 或 -H  默认
# 设置标签  -t 或 -T "Title"
function @zeta:xsh:_msg_() {
  local title="$1" color="$2"; shift; shift

  # NOTE Reset shared environment variable used by `getopts`
  # https://unix.stackexchange.com/questions/233728
  # Bash do not reset OPTIND to 1 each time it exit from a
  # shell function, but zsh does it, so reset here for both
  local OPTIND=1 OPTARG OPTERR=1 # NOTE OPTIND=1 is the key

  local showTS=0 _opt_
  while getopts "SsHhT:t:" _opt_; do
    case "${_opt_}" in
      s|S) showTS=1 ;; # show timestamp
      h|H) showTS=0 ;; # hide timestamp
      t|T) title="${OPTARG}" ;; # category
      *) ;;
    esac
  done

  local it idx=1 msg
  for it in "$@"; do
    (( idx >= ${OPTIND} )) && msg="${msg} ${it}"
    (( idx++ ))
  done

  if [[ ${showTS} -eq 1 ]]; then # timestamp in grey color
    builtin printf "\e[0;90m[%s]\e[0m " "$(date '+%FT%T%z')"
  fi
  builtin printf "${color}${title}\e[0m:%s\n" "${msg}"
}

function @zeta:xsh:imsg() {
  [[ $# -eq 0 ]] && return # green
  @zeta:xsh:_msg_ INFO '\e[0;32m' "$@"
}

function @zeta:xsh:wmsg() {
  [[ $# -eq 0 ]] && return # yellow
  { @zeta:xsh:_msg_ WARN '\e[0;33m' "$@"; } 1>&2
}

function @zeta:xsh:emsg() {
  [[ $# -eq 0 ]] && return # red
  { @zeta:xsh:_msg_ ERROR '\e[0;31m' "$@"; } 1>&2
}
