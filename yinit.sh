#!/usr/bin/bash

THIS_AFP="$(realpath "${0}")"        # 当前文件绝对路径(含名)
THIS_FNO="$(basename "${THIS_AFP}")" # 仅包含当前文件的文件名
THIS_DIR="$(dirname  "${THIS_AFP}")" # 当前文件所在的绝对路径
# printf "[${THIS_AFP}]\n[${THIS_DIR}] [${THIS_FNO}]\n"; exit

ZETA_DIR="${THIS_DIR}"
# ${0%/*}  仅删除 $0 结尾文件名(匹配最短)
# ${0##*/} 仅保留 $0 结尾文件名(匹配最长)
source "${ZETA_DIR}/xsh/colors.xsh"

case "$1" in
  bash|zsh) XSH=$1 ;;
  *) echo "$(@B3 ${THIS_FNO}) $(@Y3 bash) $(@D9 or) $(@G3 zsh)"; exit ;;
esac

function has-cmd() {  command -v "$1" > /dev/null; }
function no-cmd() { ! command -v "$1" > /dev/null; }

function is-host-macos()   { false; }
function is-host-linux()   { false; }
function is-host-windows() { false; }

function is-host-arch()    { false; }
function is-host-debian()  { false; }
function is-host-ubuntu()  { false; }

# 预定义变量 HOSTTYPE, OSTYPE, MACHTYPE, HOSTNAME
case "${OSTYPE}" in
  darwin*)  function is-host-macos()   { true; } ;;
  linux*)   function is-host-linux()   { true; } ;;
  msys*)    function is-host-windows() { true; } ;;
  cygwin*)  function is-host-windows() { true; } ;;
  *) ;; # SunOS(solaris), FreeBSD(bsd), ...
esac

if is-host-linux && has-cmd lsb_release; then
  case "$(lsb_release -is)" in
    Ubuntu) function is-host-ubuntu() { true; } ;;
    Debian) function is-host-debian() { true; } ;;
  esac
else
  if uname -a | grep -iE "MSYS|MinGW|Cygwin" > /dev/null; then
    function is-host-windows() { true; }
  fi
fi

function init-for-zsh() {
  cp "${ZETA_DIR}/xsh/startup/1shenv" "${HOME}/.zshenv"
  cat > "${HOME}/.zshrc" <<EOF
###### 命令历史 ######
HISTFILE="${ZETA_DIR}/xsh/assets/zsh-history"
HISTSIZE=3000 # 终端会话最多可保留历史命令行数
SAVEHIST=3000 # 历史命令 HISTFILE 最大保留行数

# 显示当前已启用选项 setopt   显示当前未启用选项 unsetopt
setopt hist_ignore_dups       # ignore commands that was just recorded
setopt hist_ignore_all_dups   # delete old recorded if new entry is a duplicate one
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_save_no_dups      # delete older commands that duplicate newer ones in HISTFILE
setopt hist_reduce_blanks     # delete superfluous blanks before write to HISTFILE
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data between all shell sessions
setopt extended_history       # Write HISTFILE file in ":start:elapsed;command" format

###### 自动补全 ######
# 命令补全 completion dump 缓存文件的保存位置
ZSH_COMPDUMP="${ZETA_DIR}/xsh/assets/zsh-compdump"

###### 主题风格 ######
if true; then
  # 自带集成主题 /usr/share/zsh/functions/Prompts
  autoload -Uz promptinit; promptinit; prompt adam1
fi

###### Zeta配置 ######
# ZETA_ENABLE_STARTUP_LOG=ON   # 保存 ZSH 启动日志(分析性能)
# ZETA_ENABLE_PLUGINS=()       # 激活 xsh/plugin/* 插件列表

###### ZetaMain ######
[[ -f "${ZETA_DIR}/zeta.xsh" ]] && source "${ZETA_DIR}/zeta.xsh"
EOF
}

function init-for-bash() {
  cat > "${HOME}/.bashrc" <<EOF
###### 命令历史 ######
HISTFILE="${ZETA_DIR}/xsh/assets/bash-history"
HISTSIZE=3000       # 终端会话最多可保留历史命令行数
HISTFILESIZE=3000   # 历史命令 HISTFILE 最大保留行数

HISTCONTROL=ignoreboth    # no add duplicate lines or lines start with space
shopt -s histappend       # append to history file not overwrite the history

###### 特性选项 ######
shopt -s checkwinsize     # 执行命令后检测窗口大小(更新 LINES 和 COLUMNS)
if false; then
  shopt -s globstar       # 启用 ** 递归(子目录)匹配<零>或<多>文件(目录)名
fi

###### 主题风格 ######
if true; then
  _colorterm_=0; _zchroot_="\${debian_chroot:+(\${debian_chroot})}"
  case "\${TERM}" in
    iterm|xterm-color|*-256color|*-truecolor) _colorterm_=1 ;;
  esac
  case "\${COLORTERM}" in
    truecolor|24bit) _colorterm_=1 ;;
  esac
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    _colorterm_=1
  fi

  PS1="\${_zchroot_}\u@\h \w \\$ "
  (( _colorterm_ )) && { # 终端转义序列 man console_codes
    _zX_='\[\e[00m\]'; _zG_='\[\e[92m\]' # 关/绿/黄/青/灰
    _zY_='\[\e[93m\]'; _zB_='\[\e[94m\]'; _xG_='\[\e[90m\]'
    PS1="\${_zG_}\u\${_xG_}@\${_zY_}\h \${_zB_}\w\${_zX_} \\$ "
    unset -v _zX_  _zG_  _zY_  _zB_  _xG_
  }

  case "\${TERM}" in
    xterm*|rxvt*) # set title to user@host:dir for XTerm
      PS1="\[\e]0;\u@\h - \w\a\]\${PS1}" ;;
  esac

  unset -v _zchroot_  _colorterm_
fi

###### Zeta配置 ######
# ZETA_ENABLE_STARTUP_LOG=ON   # 保存 ZSH 启动日志(分析性能)
# ZETA_ENABLE_PLUGINS=()       # 激活 xsh/plugin/* 插件列表

###### ZetaMain ######
[[ -f "${ZETA_DIR}/zeta.xsh" ]] && source "${ZETA_DIR}/zeta.xsh"
EOF
}

init-for-${XSH}
