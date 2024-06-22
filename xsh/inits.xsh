# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-25T09:50:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

function @zeta:xsh:is-zsh()  { [[ -n "${ZSH_VERSION:-}"  ]]; }
function @zeta:xsh:is-bash() { [[ -n "${BASH_VERSION:-}" ]]; }

# NOTE `which` can not found alias or shell function
function @zeta:xsh:has-cmd() {  command -v "$1" > /dev/null 2>&1; }
function @zeta:xsh:no-cmd() { ! command -v "$1" > /dev/null 2>&1; }

function @zeta:xsh:req-cmd() {
  if ! command -v "$1" > /dev/null 2>&1; then # 红色 \e[31m
    printf "\e[90mzeta:\e[0m not found required \e[31m$1\e[0m command\n" >&2
    return 1
  fi
}

if [[ -n "${ZSH_VERSION:-}" ]]; then
  # 启动参数包含 l 表示 login
  if [[ $- == *l* ]]; then
    function @zeta:xsh:is-login() { true; }
  else
    function @zeta:xsh:is-login() { false; }
  fi
else
  if shopt -q login_shell; then
    function @zeta:xsh:is-login() { true; }
  else
    function @zeta:xsh:is-login() { false; }
  fi
fi

function @zeta:xsh:is-color-enable() {
  case "${TERM}" in
    xterm-color|*-256color) return ;;
  esac

  # assume it's compliant with Ecma-48 (ISO/IEC-6429).
  # Lack of such support is extremely rare, and such
  # a case would tend to support setf rather than setaf
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    return
  fi

  return 1
}

# https://github.com/termstandard/colors
function @zeta:xsh:is-truecolor() {
  case "${COLORTERM}" in
    truecolor|24bit) return ;;
  esac

  case "${TERM}" in
    iterm|*-truecolor) return ;;
  esac

  return 1
}

# 关于 TTY 和终端
# => Ubuntu 22.04.3 LTS
#    Ctrl + Alt + F1     Ubuntu(KDE) 图像桌面, /dev/tty1
#    Ctrl + Alt + F2~6   /dev/tty2, ..., /dev/tty6
# => TTY(TeleTYpewrite) 电传打字电报机
#    `tty` is a regular terminal device
#    `pty` is a pseudo terminal, master device, `man pty`
#    `pts` is a pseudo terminal, slave  device, `man pts`
# => https://www.tecmint.com/linux-tty-tty0-and-console
# => https://thevaluable.dev/guide-terminal-shell-console
#    /dev/tty[N] are virtual consoles that you can switch to from main terminal
#    if you are running in a GUI system, where N represents the TTY number.
#    By default, /dev/tty0 is the default virtual console. tty1 through tty63
#    are virtual terminals, alternatively known as VTs or Virtual Consoles.
# => https://askubuntu.com/questions/902998
# => https://unix.stackexchange.com/questions/734242
#    zsh -c 'echo $TTY', ZSH/Bash 均可用命令 tty, who, who am i

# NOTE 0 = stdin, 1 = stdout, 2 = stderr
# NOTE The [ -t 0 ] check only works when it is not called from a
# subshell, like `$(...)` or `(...)`, so this hack defines the function
# at top level to make sure always return false when stdin is not a tty.
if [ -t 0 ]; then # true if `stdin` is connected to a terminal
  function @zeta:xsh:is-stdin-tty() { true;  }
else
  function @zeta:xsh:is-stdin-tty() { false; }
fi

if [ -t 1 ]; then # true if `stdout` is connected to a terminal
  function @zeta:xsh:is-stdout-tty() { true;  }
else
  function @zeta:xsh:is-stdout-tty() { false; }
fi

if [ -t 2 ]; then # true if `stderr` is connected to a terminal
  function @zeta:xsh:is-stderr-tty() { true;  }
else
  function @zeta:xsh:is-stderr-tty() { false; }
fi

source "${ZETA_DIR}/xsh/core/path.xsh"
source "${ZETA_DIR}/xsh/core/host.xsh"

# 管理 3rd/pick/* 应用软连接(版本切换)
source "${ZETA_DIR}/3rd/zeta-switch.xsh"
