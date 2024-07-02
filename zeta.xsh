# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-24T20:01:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# shellcheck shell=bash
# NOTE https://www.shellcheck.net/wiki
# Install `sudo apt install shellcheck`

# `$-` 表示当前 SHELL 启动参数
# Zsh/Bash 启动参数若包含 i 则表示 Interactive Shell
# NOTE Bash can only `return` from function or sourced script,
# but it works well in ZSH for none function or sourced script
[[ $- == *i* ]] || return # 非交互式 Shell 则直接返回

# NOTE zeta/xsh Only Support for Bash Shell and Zsh Shell
# https://gitlab.gnome.org/GNOME/vte/-/blob/master/src/vte.sh.in
if [[ -z "${ZSH_VERSION:-}" && -z "${BASH_VERSINFO[*]:-}" ]]; then
  return # => ${BASH_VERSION:-} 和 ${BASH_VERSINFO[*]:-}
fi

# 保存 ZSH 启动日志(查看组件模块加载时间)
if [[ -n "${ZSH_VERSION:-}" && -n "${ZETA_ENABLE_STARTUP_LOG}" ]]; then
  # https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
  if false; then
    PS4=$'%D{%H:%M:%S-%N} %N:%i -> '
  else # `zmodload` 显示已加载模块列表
    zmodload zsh/datetime
    PS4=$'${EPOCHREALTIME} %N:%i -> '
  fi
  # https://tldp.org/LDP/abs/html/io-redirection.html
  # `exec` with no cmd, redirection for current shell
  exec 3>&2  2> ${HOME}/zsh-launch-$$.log
  setopt xtrace prompt_subst
fi

# => zsh -xv # 启用 (x)traceing 和 (v)erbose output
# => time zsh -i -c exit 和 time zsh --no-rcs -i -c exit
_xnow1_=$(date +%s%N) # 简单计算 Shell 大概的启动加载耗时

if [[ -n "${ZSH_VERSION:-}" ]]; then
  # https://zsh.sourceforge.io/releases.html
  # https://sourceforge.net/p/zsh/code/ref/master/tags/
  autoload is-at-least && { is-at-least 5.8.0 || return; }

  # NOTE Z-Shell Benchmark -> About `zprof` Output
  # https://wiki.zshell.dev/zh-Hans/docs/guides/benchmark
  # ZSH 内置性能分析模块, 执行 zporf 命令显示性能分析报告
  # => 查看 Zsh 源码 => zsh/Src/Modules/zprof.c
  # => num  calls  time/1 time/2 time/3  self/1 self/2 self/3  函数名=F
  # num=序号; calls=F函数调用的次数
  # time/1=F总的执行时间(毫秒)     self/1=F自身代码总执行时间(不含调用F执行时间)
  # time/2=F平均执行时间(毫秒)     self/2=F函数自身代码的平均行时间
  # time/3=F总的执行时间/启动耗时  self/3=F自身代码总执行时间/启动耗时
  zmodload zsh/zprof

  # ZSH 的 $0 动态变化, 函数中表示函数名
  export ZETA_DIR="$(dirname "$0")"
else
  # https://git.savannah.gnu.org/cgit/bash.git/refs/tags
  # https://git.savannah.gnu.org/cgit/bash.git/tree/CHANGES
  (( BASH_VERSINFO[0] < 5 )) && return

  # 关于 Bash 的 $0 变量
  # => https://unix.stackexchange.com/questions/144514
  #    /bin/bash -c 'echo "[$0] [$1]"' foo bar xyz
  #    /bin/bash -c 'echo "[$0] [$@]"' foo bar xyz
  # => 直接执行脚本时则 $0 自动设置为脚本文件名(包括路径)
  export ZETA_DIR="$(dirname "${BASH_SOURCE[0]}")"
fi

# echo "${LINENO}: BS=[${BASH_SOURCE[@]}] \$0=[$0] \$@=[$@]"
# echo "${LINENO}: PID=$$, UID=${UID}, GID=${GID}, PWD=${PWD}"

ZETA_REPO_URL="https://github.com/xwlc/zeta"
if command -v git > /dev/null && [ -d "${ZETA_DIR}/.git" ]; then
  ZETA_COMMIT="$(cd "${ZETA_DIR}" && git rev-parse HEAD)"
  ZETA_REPO_DIR="$(cd "${ZETA_DIR}" && git rev-parse --show-toplevel)"
fi

source "${ZETA_DIR}/xsh/inits.xsh"
source "${ZETA_DIR}/xsh/utils.xsh"
source "${ZETA_DIR}/xsh/export.xsh"
source "${ZETA_DIR}/xsh/colors.xsh"
source "${ZETA_DIR}/xsh/alias.xsh"
source "${ZETA_DIR}/xsh/memo.xsh"
source "${ZETA_DIR}/xsh/main.xsh"

if [[ -f "/me/priv/${USER}/${USER}.xsh" ]]; then
  source "/me/priv/${USER}/${USER}.xsh"
fi

# 1s = 1000ms, 1ms = 1000μs, 1us = 1000ns, 1ns = 1000ps
# ms(millisecond), μs(microsecond), ns(nanosecond), ps(picosecond)
_xnow2_=$(date +%s%N) # 简单计算 Shell 大概的启动加载耗时
_xused_=" => $(@R3 $(( (${_xnow2_} - ${_xnow1_}) / 1000000 )))$(@D9 ms)"
echo
echo "$(@D9 '#################################')"
echo "$(@D9 '#') 👽 $(@Y9 莫道君行早) · $(@G9 更有早行人) 👽 $(@D9 '#')${_xused_}"
echo "$(@D9 '#################################')"
echo
unset -v _xnow1_  _xnow2_  _xused_

if [[ -n "${ZETA_ENABLE_STARTUP_LOG}" ]]; then
  unsetopt xtrace
  exec  2>&3  3>&-
fi

alias lsz-vars='ls-sh-vars | grep -i zeta'     # 环境变量
alias lsz-func='ls-sh-func-names | grep zeta:' # 函数列表

alias lsz-util='ls-sh-func-names | grep util:' # 通用函数 @zeta:util:
alias lsz-auto='ls-sh-func-names | grep auto:' # 自动加载 @zeta:auto:
alias lsz-lazy='ls-sh-func-names | grep lazy:' # 延迟加载 @zeta:lazy: 模块名 PKG

alias lsz-comp='ls-sh-func-names | grep comp:' # 补全  @zeta:comp:  «PKG»comp:
alias lsz-hook='ls-sh-func-names | grep hook:' # 回调  @zeta:hook:  «PKG»hook:
alias lsz-priv='ls-sh-func-names | grep priv:' # 内部  @zeta:priv:  «PKG»priv:

alias lsz-bugs='ls-sh-func-names | grep temp±' # 用完清理
alias lsz-once='ls-sh-func-names | grep once±' # 临时函数
alias lsz-todo='ls-sh-func-names | grep todo±' #
