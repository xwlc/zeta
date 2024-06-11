# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-24T20:01:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# Only Support Bash or Zsh Shell
# https://gitlab.gnome.org/GNOME/vte/-/blob/master/src/vte.sh.in
if [[ -z "${ZSH_VERSION:-}" && -z "${BASH_VERSINFO[*]:-}" ]]; then
  return
fi

# `$-` 表示当前 SHELL 启动参数
# Zsh/Bash 启动参数若包含 i 则表示 Interactive Shell
# NOTE Bash can only `return` from function or sourced script,
# but it works well in ZSH for none function or sourced script
[[ $- == *i* ]] || return # Interactive or NOT

if [[ -n "${ZSH_VERSION:-}" ]]; then
  # https://zsh.sourceforge.io/releases.html
  # https://sourceforge.net/p/zsh/code/ref/master/tags/
  autoload is-at-least && { is-at-least 5.8.0 || return; }
  zmodload zsh/zprof

  # ZSH 的 $0 动态变化, 函数中表示函数名
  export ZETA_DIR="$(dirname "$0")"
else
  # https://git.savannah.gnu.org/cgit/bash.git/refs/tags
  # https://git.savannah.gnu.org/cgit/bash.git/tree/CHANGES
  (( BASH_VERSINFO[0] < 5 )) && return

  # Bash 的 $0 变量
  # => https://unix.stackexchange.com/questions/144514
  #    /bin/bash -c 'echo "[$0] [$1]"' foo bar xyz
  #    /bin/bash -c 'echo "[$0] [$@]"' foo bar xyz
  # => 直接执行脚本时则 $0 自动设置为脚本文件名(包括路径)
  export ZETA_DIR="$(dirname "${BASH_SOURCE[0]}")"
fi

ZETA_REPO="https://github.com/xwlc/zeta"
if command -v git > /dev/null && [ -d "${ZETA_DIR}/.git" ]; then
  ZETA_COMMIT="$(cd "${ZETA_DIR}" && git rev-parse HEAD 2> /dev/null)"
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
