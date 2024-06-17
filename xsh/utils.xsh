# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-25T09:50:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# NOTE 解析位置参数
# help getopts, run-help getopts
# 共享环境变量: OPTERR, OPTIND, OPTARG
# OPTERR='' ZSH 默认, OPTERR=1 Bash 默认
# 等于 1 则表示若解析错误显示相关诊断信息

# 显示时间  -s 或 -S           设置标签  -t 或 -T "Title"
# 隐藏时间  -h 或 -H  默认     显示zeta  -z 或 -Z 默认隐藏
function @zeta:xsh:_msg_() {
  local title="$1" color="$2"; shift; shift

  # NOTE Reset shared environment variable used by `getopts`
  # https://unix.stackexchange.com/questions/233728
  # Bash do not reset OPTIND to 1 each time it exit from a
  # shell function, but zsh does it, so reset here for both
  local OPTIND=1 OPTARG OPTERR=1 # NOTE OPTIND=1 is the key

  local showTS=0 _opt_ showZeta=0
  while getopts "SsHhZzT:t:" _opt_; do
    case "${_opt_}" in
      s|S) showTS=1   ;; # show timestamp
      h|H) showTS=0   ;; # hide timestamp
      z|Z) showZeta=1 ;; # 显示 zeta 字符串
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
    builtin printf "\e[90m[%s]\e[0m " "$(date '+%FT%T%z')"
  fi

  if [[ ${showZeta} -eq 1 ]]; then
    builtin printf "\e[90mzeta:\e[0m ${color}${title}:\e[0m%s\n" "${msg}"
  else
    builtin printf "${color}${title}:\e[0m%s\n" "${msg}"
  fi
}

function @zeta:xsh:imsg() {
  [[ $# -eq 0 ]] && return # green
  @zeta:xsh:_msg_ INFOS '\e[32m' "$@"
}

function @zeta:xsh:wmsg() {
  [[ $# -eq 0 ]] && return # yellow
  { @zeta:xsh:_msg_ WARNS '\e[33m' "$@"; } 1>&2
}

function @zeta:xsh:emsg() {
  [[ $# -eq 0 ]] && return # red
  { @zeta:xsh:_msg_ ERROR '\e[31m' "$@"; } 1>&2
}

# https://www.baeldung.com/linux/bash-zsh-loop-splitting-globbing
function @zeta:xsh:is-valid-zsh-opt() {
  [[ -z "${ZSH_VERSION:-}" ]] && return 1

  case $1 in
    # NOTE do split strings based on $IFS
    shwordsplit)    ;; # 默认 Bash do it, ZSH not
    # NOTE none if GLOB match nothing
    nullglob)       ;; # 默认 Bash do it, ZSH report error
    *) return 1 ;;
  esac
}

function @zeta:zsh:opt:status() {
  if @zeta:xsh:is-valid-zsh-opt $1; then
    [[ -o $1 ]] && echo 'on'
  fi
}

function @zeta:zsh:opt:enable() {
  if @zeta:xsh:is-valid-zsh-opt $1; then
    [[ ! -o $1 ]] && setopt $1
  fi
}

function @zeta:zsh:opt:disable() {
  if @zeta:xsh:is-valid-zsh-opt $1; then
    [[ -o $1 ]] && unsetopt $1
  fi
}

function @zeta:util:is-binnum() { # binary
  [[ $# -eq 0 ]] && return 1
  [[ -n "$1" && -z "${1//[0-1]/}" ]]
}

function @zeta:util:is-octnum() { # octave
  [[ $# -eq 0 ]] && return 1
  [[ -n "$1" && -z "${1//[0-7]/}" ]]
}

function @zeta:util:is-decnum() { # decimal
  [[ $# -eq 0 ]] && return 1
  [[ -n "$1" && -z "${1//[0-9]/}" ]]
  #[[ $(echo "$1" | wc -l) -gt 1 ]] && return 1
  #[[ -n "$(echo "$1" | sed -n "/^[0-9]\+$/p")" ]]
}

function @zeta:util:is-hexnum() { # hexadecimal
  [[ $# -eq 0 ]] && return 1
  [[ -n "$1" && -z "${1//[0-9A-Fa-f]/}" ]]
  #[[ $(echo "$1" | wc -l) -gt 1 ]] && return 1
  #[[ -n "$(echo "$1" | sed -n "/^[0-9A-Fa-f]\+$/p")" ]]
}

function @zeta:util:is-number() {
  [[ $# -eq 0 ]] && return 1
  [[ -n "$1" && -z "${1//[0-9A-Fa-f]/}" ]]
}

function @zeta:util:inside-git-repo() {
  git rev-parse --is-inside-work-tree &> /dev/null
}

# $1 原始字符串  $2 期望包含字符
function @zeta:util:has-sub-str() {
  [[ -z "$1" || -z "$2" ]] && return 1
  # 删除期望字符后若二者不相等则表示包含
  [[ "$(echo "$1" | sed "s#$2##")" != "$1" ]]
}

function @zeta:util:get-repo-github-url() {
  ! git rev-parse --is-inside-work-tree &> /dev/null && return
  local xurl=$(git remote --verbose | head -1 | cut -d' ' -f1 | cut -f2)
  if @zeta:util:has-sub-str "${xurl}" "git@github.com:"; then
    xurl=$(echo "${xurl}" | sed 's#git@github.com:#https://github.com/#')
  fi
  xurl="${xurl%.git}" # 删除结尾的 .git 字符串
  if @zeta:util:has-sub-str "${xurl}" "https://github.com/"; then
    # GitHubUserRepo="${xurl#https://github.com/}" # 开头 % 结尾
    # GitHubRepoName="${GitHubUserRepo#*/}"
    # GitHubUserName="${GitHubUserRepo%/*}"
    echo "${xurl}"
  fi
}
