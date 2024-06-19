# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-25T09:50:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# 索引数组 declare -a   关联数组 declare -A
# Zsh 数组索引 1 开始, Bash 数组索引 0 开始

# 间接引用: Zsh 语法 ${(P)VAR}  Bash 语法 ${!VAR}
# 关闭选项 set +o OptName 打开选项 set -o OptName

# Zsh 命令 `declare` 等同于 `typeset`, 兼容 Bash
# for x in "$*"; do echo $x; done 仅循环迭代一次

############
# 信息显示 #
############

# 显示时间  -s 或 -S           设置标签  -t 或 -T "Title"
# 隐藏时间  -h 或 -H  默认     显示zeta  -z 或 -Z 默认隐藏
function @zeta:xsh:_msg_() {
  local title="$1" color="$2"; shift; shift

  # NOTE Reset shared environment variable used by `getopts`
  # https://unix.stackexchange.com/questions/233728
  # Bash do not reset OPTIND to 1 each time it exit from a
  # shell function, but zsh does it, so reset here for both
  local OPTIND=1 OPTARG OPTERR=1 # NOTE OPTIND=1 is the key

  # NOTE getopts 解析位置参数
  # help getopts, run-help getopts
  # 共享环境变量: OPTERR, OPTIND, OPTARG
  # OPTERR='' ZSH 默认, OPTERR=1 Bash 默认
  # 等于 1 则表示若解析错误显示相关诊断信息
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

##################################
# Shell 配置选项(特性)及通用 API #
##################################

# https://www.baeldung.com/linux/bash-zsh-loop-splitting-globbing
# -> 依据 $IFS 进行字符串分割(默认行为): Bash 启用, Zsh 禁用
#    Zsh 选项名 shwordsplit
# -> 显示空如果 GLOB 匹配失败(默认行为): Bash 启用, Zsh 报告错误
#    Zsh 选项名 nullglob

# 若 $1 选项已<禁用>则<启用>之(提供恢复命令)
function @zeta:xsh:opt-if-off-then-on() {
  [[ $# -ne 1 || -z "$1" ]] && return 1
  [[ -o $1 ]] && return 0 # 已启用
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    setopt $1   # 启用选项
    builtin echo "unsetopt $1" # eval 禁用恢复命令
  elif [[ -n "${BASH_VERSION:-}" ]]; then
    shopt -s $1 # 启用选项
    builtin echo "shopt -u $1" # eval 禁用恢复命令
    # 特性选项状态 shopt extglob | cut -f2
  fi
}

# 若 $1 选项已<启用>则<禁用>之(提供恢复命令)
function @zeta:xsh:opt-on-then-off() {
  [[ $# -ne 1 || -z "$1" ]] && return 1
  [[ ! -o $1 ]] && return 0 # 已禁用
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    unsetopt $1 # 禁用选项
    builtin echo "setopt $1"   # eval 启用恢复命令
  elif [[ -n "${BASH_VERSION:-}" ]]; then
    shopt -u $1 # 禁用选项
    builtin echo "shopt -s $1" # eval 启用恢复命令
  fi
}

# 变量名 $1 间接引用(indirection-expansion)
function @zeta:xsh:ind-exp-var() {
  [[ $# -ne 1 || -z "$1" ]] && return 1
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    eval '[[ ${(t)'${(P)1}'} != scalar ]] && return 3' # 类型错误
    eval 'builtin echo ${'${(P)1}'}'
  elif [[ -n "${BASH_VERSION:-}" ]]; then
    eval 'if ! declare -p '${!1}' > /dev/null 2>&1; then return 2; fi' # 未定义
    eval '[[ -n "${'${!1}'@a}" ]] && return 3' # 类型错误
    eval 'builtin echo ${'${!1}'}'
  fi
}
# VAR1="ok-hi"; VAR2=VAR1; @zeta:xsh:ind-exp-var VAR2; echo retval=$?
#               VAR3=VAR4; @zeta:xsh:ind-exp-var VAR3; echo retval=$?

# 间接引用(indirection-expansion)
# 回显<索引数组>全部值 => 数组名 $1
# 回显<数组>指定索引值 => 数组名 $1, 索引值(从1起) $2
function @zeta:xsh:ind-exp-ia() {
  [[ -z "$1" ]] && return 1
  [[ -n "$2" ]] && {
    local xfeature  isok  xrestore
    [[ -n "${ZSH_VERSION:-}" ]]  && xfeature=ksh_glob
    [[ -n "${BASH_VERSION:-}" ]] && xfeature=extglob
    xrestore="$(@zeta:xsh:opt-if-off-then-on ${xfeature})"
    isok=$?; [[ ${isok} -ne 0 ]] && return 2 # 参数错误
    [[ ! "$2" =~ ^[0-9]*([0-9])$ ]] && return 2 # 非数字索引
    [[ -n "${xrestore}" ]] && eval "${xrestore}" # 恢复选项状态
  }

  if [[ -n "${ZSH_VERSION:-}" ]]; then
    eval '[[ ${(t)'${(P)1}'} != array ]] && return 3' # 类型错误
    if [[ -n "$2" ]]; then
      local idx=$2; (( idx == 0 )) && idx=1
      eval 'builtin echo "${'${(P)1}'['${idx}']}"'
    else
      eval 'builtin echo "${'${(P)1}'[@]}"'
    fi
  elif [[ -n "${BASH_VERSION:-}" ]]; then
    eval '[[ ${'${!1}'@a} != a ]] && return 3' # 类型错误
    if [[ -n "$2" ]]; then
      local idx=$2; (( idx--, idx < 0 )) && idx=0
      eval 'builtin echo ${'${!1}'['${idx}']}'
    else # NOTE 仅 echo 命令按照预期工作
      eval 'builtin echo ${'${!1}'[@]}'
    fi
  fi
# 关于 Bash 数组间接引用(indirection expansion)的实现示例
# $ declare -a abc=(v1 v2 v3);xyz=abc;echo "\${${xyz}[@]}"
# $ eval echo "\${${xyz}[@]}";  eval echo '${'${xyz}'[@]}'
# https://utectec.com/note/bash-array-expansion-using-variable-indirection-expansion/
}
# declare -a IA=(v1  v2  v3  v4  v5  v6) # 使用示例
# IX=IA; @zeta:xsh:ind-exp-ia IX   ; echo retval=$?
# IX=IA; @zeta:xsh:ind-exp-ia IX  3; echo retval=$?
# IX=IZ; @zeta:xsh:ind-exp-ia IX  4; echo retval=$?

# 间接引用(indirection-expansion)
# 回显<关联数组>全部 key 值  => 数组名 $1
# 回显<数组>在指定索引处的值 => 数组名 $1, 索引值 $2
function @zeta:xsh:ind-exp-aa() {
  [[ -z "$1" ]] && return 1
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    eval '[[ ${(t)'${(P)1}'} != association ]] && return 3' # 类型错误
    if [[ -n "$2" ]]; then
      eval 'builtin echo "${'${(P)1}'['$2']}"'
    else
      eval 'builtin echo "${(k)'${(P)1}'}"' # 显示 key 列表
    fi
  elif [[ -n "${BASH_VERSION:-}" ]]; then
    eval '[[ ${'${!1}'@a} != A ]] && return 3'
    if [[ -n "$2" ]]; then
      eval 'builtin echo ${'${!1}'['$2']}'
    else # NOTE 仅 echo 命令按照预期工作
      eval 'builtin echo ${!'${!1}'[@]}' # 显示 key 列表
    fi
  fi
}
# declare -A IA=(k1  v1  k2  v2  k3  v3) # 使用示例
# IX=IA; @zeta:xsh:ind-exp-aa IX   ; echo retval=$?
# IX=IA; @zeta:xsh:ind-exp-aa IX k2; echo retval=$?
# IX=IZ; @zeta:xsh:ind-exp-aa IX kx; echo retval=$?

######################
# 常用(通用)便捷函数 #
######################

# 四种分割符 => ␜  换行 ␝  制表 ␞  空格 ␟
function @zeta:util:space-holder()   { builtin printf "$1" | sed -z 's/\x20/␟/g'; }
function @zeta:util:space-resets()   { builtin printf "$1" | sed -z 's/␟/\x20/g'; }
function @zeta:util:tab-holder()     { builtin printf "$1" | sed -z 's/\x09/␞/g'; }
function @zeta:util:tab-resets()     { builtin printf "$1" | sed -z 's/␞/\x09/g'; }
function @zeta:util:newline-holder() { builtin printf "$1" | sed -z 's/\x0a/␝/g'; }
function @zeta:util:newline-resets() { builtin printf "$1" | sed -z 's/␝/\x0a/g'; }

# $1 原始字符串  $2 期望包含字符
function @zeta:util:has-sub-str() {
  [[ -z "$1" || -z "$2" ]] && return 1
  # 删除期望字符后若二者不相等则表示包含
  [[ "$(echo "$1" | sed "s#$2##")" != "$1" ]]
}

# 数字检测
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

function @zeta:git:is-inside-repo() {
  git rev-parse --is-inside-work-tree &> /dev/null
}

function @zeta:git:get-github-url() {
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
