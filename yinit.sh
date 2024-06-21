#!/usr/bin/bash

THIS_AFP="$(realpath "${0}")"        # 当前文件绝对路径(含名)
THIS_FNO="$(basename "${THIS_AFP}")" # 仅包含当前文件的文件名
THIS_DIR="$(dirname  "${THIS_AFP}")" # 当前文件所在的绝对路径
# printf "[${THIS_AFP}]\n[${THIS_DIR}] [${THIS_FNO}]\n"; exit

ZETA_DIR="${THIS_DIR}"

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

if is-host-linux; then
  case "$(lsb_release -is)" in
    ubuntu|Ubuntu) function is-host-ubuntu() { true; } ;;
    debian|Debian) function is-host-debian() { true; } ;;
  esac
else
  if uname -a | grep -iE "MSYS|MinGW|Cygwin" > /dev/null; then
    function is-host-windows() { true; }
  fi
fi

# ${0%/*}  仅删除 $0 结尾文件名(匹配最短)
# ${0##*/} 仅保留 $0 结尾文件名(匹配最长)
source "${ZETA_DIR}/xsh/colors.xsh"

case "$1" in
  bash|zsh) XSH=$1 ;;
  *) echo "$(@B3 ${THIS_FNO}) $(@Y3 bash) $(@D9 or) $(@G3 zsh)"; exit ;;
esac

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

###### 配置选项 ######
# ZETA_ENABLE_STARTUP_LOG=ON   # 保存 ZSH 启动日志(分析性能)
# ZETA_ENABLE_PLUGINS=()       # 激活 xsh/plugin/* 插件列表

######## 入口 ########
[ -f "${ZETA_DIR}/zeta.xsh" ] && source "${ZETA_DIR}/zeta.xsh"

###### 主题风格 ######
# 自带集成主题 /usr/share/zsh/functions/Prompts
#autoload -Uz promptinit; promptinit; prompt adam1
EOF
}

function init-for-bash() {
  echo TODO # .bashrc bash-history
}

init-for-${XSH}
