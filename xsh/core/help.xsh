# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-08-23T17:19:53+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# 查询: 变量类型, 函数定义, 别名等
if @zeta:xsh:no-cmd whats; then
  alias whats='@zeta:xsh:whats'
fi

# 内嵌命令帮助
function help-bash() {
  if [[ -n "${BASH_VERSION:-}" ]]; then
    help "$1"
  else
    bash -c "help $1"
  fi
}

function help-zsh() {
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    run-help "$1"
    return
  fi

  local zhelp="/usr/share/zsh/help"
  [[ ! -d "${zhelp}" ]] && return

  if [[ -f "${zhelp}/$1" ]]; then
    echo; cat "${zhelp}/$1"; echo; return
  fi

  # Make the same output as `run-help`
  @D9 'Here is a list of topics for which special help is available\n'
  echo; ls "${zhelp}"; echo
  echo "=> $(@C3 man) $(@Y3 zsh)"
  echo "=> $(@C3 man) $(@Y3 zshbuiltins)"
  echo "=> $(@C3 man) $(@Y3 bash-builtins)"
  echo
}

function ls-path()  {
  local _PATH_="${PATH// /␟}" # 保持可能的空格
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    _PATH_=( ${=_PATH_//:/ } ) # 强制进行字符分隔, IFS
  else
    _PATH_=( ${_PATH_//:/ } ) # 默认自动进行字符分隔, IFS
  fi

  echo; local idx=1 _path_
  for _path_ in "${_PATH_[@]}"; do
    builtin printf -v idx "%2d" ${idx}
    echo "$(@Y9 "${idx}") $(@D9 '->') $(@G9 "${_path_//␟/ }")"
    (( idx++ ))
  done
  echo
}

function ls-fpath() {
  local _FPATH_="${FPATH// /␟}" # 保持可能的空格
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    _FPATH_=( ${=_FPATH_//:/ } ) # 强制进行字符分隔, IFS
  else
    _FPATH_=( ${_FPATH_//:/ } ) # 默认自动进行字符分隔, IFS
  fi

  echo; local idx=1 _fpath_
  for _fpath_ in "${_FPATH_[@]}"; do
    builtin printf -v idx "%2d" ${idx}
    echo "$(@Y9 "${idx}") $(@D9 '->') $(@G9 "${_fpath_//␟/ }")"
    (( idx++ ))
  done
  echo
}

function ls-split() {
  case $# in
    0) echo; echo "${PATH}" | sed 's/:/\n/g';  echo ;;
    1) echo; echo "$1" | sed "s/[: ;\t]/\n/g"; echo ;;
    2) echo; echo "$2" | sed "s/[$1]/\n/g";    echo ;;
  esac
}

# ZSH 命令 whence
# - whence -v  等同于 type
# - whence -c  等同于 which
# - whence -ca 等同于 where
# - whence -w  显示命令类型: function, alias, none

# 显示当前 Shell 的[环境变量]
# env                     等同于 printenv
# declare -x | grep VAR   显示当前 Shell 的环境变量
# export -p | grep PATH   显示当前 Shell 的环境变量
# export VAR=VAL          设置当前 Shell 的环境变量(子进程可用)
# printenv                显示所有环境变量的值(仅显示 export 的变量)
# printenv PATH           显示指定环境变量的值(仅显示 export 的变量)

# 显示当前 Shell 的[变量]
# declare                 Bash/ZSH 均可用, 在 ZSH 中等于 typeset
# declare -p | grep VAR   包括环境变量, 普通变量
# set | grep VAR          包括环境变量, 普通变量, 函数定义(仅Bash)
# typeset | grep VAR      类似 set, 同时显示变量类型, 仅 ZSH 可用

# 显示当前 Shell 的[环境]变量
alias ls-sh-envs='printenv'
# 显示当前 Shell 的[变量]列表
alias ls-sh-vars='declare -p'
# 显示当前 Shell 的[函数]定义
alias ls-sh-body='declare -f'

if [[ -n "${ZSH_VERSION:-}" ]]; then
  alias help='help-zsh'
  # 显示当前会话可用函数列表, 包括:
  # - 补全函数, 自动加载函数, 等等
  alias ls-sh-funs='typeset -f +'
else
  # 显示当前会话可用函数列表
  alias ls-sh-funs='declare -F'
fi

# 显示 Bash 或 Zsh 的 keywords 列表
function ls-sh-keywords() {
  local word  data  cnt=0  max=$1
  [[ -z "$1" || -n "${1//[0-9]/}" ]] && max=8
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    data=( ${(k)reswords} )
  else
    data=( $(compgen -k) )
  fi
  echo; local XX='\e[0m' Y9='\e[93m'
  for word in "${data[@]}"; do
    builtin printf "${Y9}%-10s${XX}" ${word}
    (( cnt++ )); (( cnt % max == 0 )) && echo
  done
  echo; (( cnt % max != 0 )) && echo
}

# 显示 Bash 或 Zsh 的 builtin 列表
function ls-sh-builtins() {
  local word  data  cnt=0  max=$1  wlen
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    data=( ${(k)builtins} ); wlen=16
    [[ -z "$1" || -n "${1//[0-9]/}" ]] && max=8
  else
    data=( $(compgen -b) ); wlen=12
    [[ -z "$1" || -n "${1//[0-9]/}" ]] && max=10
  fi
  echo; local XX='\e[0m' G9='\e[92m'
  for word in "${data[@]}"; do
    builtin printf "${G9}%-${wlen}s${XX}" ${word}
    (( cnt++ )); (( cnt % max == 0 )) && echo
  done
  echo; (( cnt % max != 0 )) && echo
}

# 显示当前会话所有的别名列表
function ls-sh-aliases() {
  local data  line  nick  cmd
  local XX='\e[0m' D9='\e[90m' G9='\e[92m' Y9='\e[93m'
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    local IFS=$'\n'; data=( $(alias) )
    for line in "${data[@]}"; do
      nick="${line%%=*}"; cmd="${line#${nick}=}"; cmd="${cmd//\'/}"
      printf "${G9}%+20s ${D9}-> ${Y9}%s${XX}\n" "${nick}" "${cmd}"
    done
  else
    data=( $(compgen -a) )
    for nick in "${data[@]}"; do
      cmd="$(type ${nick})"; cmd="${cmd##*\`}"; cmd="${cmd//\'/}"
      printf "${G9}%+20s ${D9}-> ${Y9}%s${XX}\n" "${nick}" "${cmd}"
    done
  fi
}

# 显示当前会话可用函数列表
function ls-sh-functions() {
  local word  data  aload  cnt=0  max=$1
  [[ -z "$1" || -n "${1//[0-9]/}" ]] && max=6
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    aload=( $(typeset -f -U +) ) # 显示 autoloadable 函数
    data=(
      $(diff -d --suppress-common-lines \
          --unchanged-line-format="" \
          --old-line-format="%L" \
          --new-line-format="" \
          <( typeset -f +)  <( typeset -f -U +)
      )
    )
  else
    data=( $(compgen -A function) )
  fi
  echo; local XX='\e[0m' D9='\e[90m' Y9='\e[93m'
  [[ $# -ne 0 && ${#aload[@]} -ne 0 ]] && {
    for word in "${aload[@]}"; do
      builtin printf "${D9}%-30s${XX}" ${word}
      (( cnt++ )); (( cnt % max == 0 )) && echo
    done
    echo; (( cnt % max != 0 )) && echo; cnt=0
  }

  for word in "${data[@]}"; do
    builtin printf "${Y9}%-30s${XX}" ${word}
    (( cnt++ )); (( cnt % max == 0 )) && echo
  done
  echo; (( cnt % max != 0 )) && echo
}

# $1 指定显示列数
# 显示当前会话补全函数列表
# NOTE Completion/compinit
# -> cat /usr/share/zsh/functions/Completion/compinit
# -> Zsh 补全语法1 compdef FUNC1(补全) FUNC2(命令)
#    k=命令索引  v=补全函数
#    FUNC1 和 FUNC2 添加到 _comps 关联数组
function ls-sh-complete() {
  local data  cnt=0  max=$1
  local XX='\e[0m' D9='\e[90m' G9='\e[92m' Y9='\e[93m'
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    [[ -z "$1" || -n "${1//[0-9]/}" ]] && max=3
    local k v
    data=( ${(k)builtins} )
    eval "
    for k v ( \"\${(@kv)_comps}\" ); do
      builtin printf \"\${Y9}%+20s \${D9}->  \${D9}%-30s\${XX}\" \"\${v}\" \"\${k}\"
      (( cnt++ ))
      (( cnt % max == 0 )) && echo
    done
    "
  else
    local IFS=$'\n'; data=( $(complete -p) )
    [[ -z "$1" || -n "${1//[0-9]/}" ]] && max=2
    local line  info  comp  cmd  str
    for line in "${data[@]}"; do
      info="${line##complete?}"; comp="${info% *}"; cmd="${info#${comp}}"
      builtin printf -v str "${D9}complete ${G9}%s${Y9}%s${XX}" "${comp}" "${cmd}"
      builtin printf "%-110s" "${str}"
      (( cnt++ )); (( cnt % max == 0 )) && echo
    done
  fi
  echo; (( cnt % max != 0 )) && echo
}
