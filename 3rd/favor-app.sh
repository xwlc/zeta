#!/usr/bin/env bash

function has-cmd() {  command -v "$1" > /dev/null; }
function no-cmd() { ! command -v "$1" > /dev/null; }

if [[ "$1" != "INSTALL" ]]; then
  DRY_RUN='--dry-run'
fi

# apt show gcc clang
# apt search ^gcc-[0-9][0-9]$
# apt search ^clang-[0-9][0-9]$
sudo apt install ${DRY_RUN} build-essential

# APT 包文件搜索/显示工具
# apt-show-versions
sudo apt install ${DRY_RUN} apt-file
[[ -z "${DRY_RUN}" ]] && sudo apt-file update # 更新缓存

# https://www.rodsbooks.com/gdisk
# https://sourceforge.net/projects/gptfdisk/files/gptfdisk
sudo apt install ${DRY_RUN} gdisk
# https://github.com/storaged-project
# https://www.freedesktop.org/wiki/Software/udisks
sudo apt install ${DRY_RUN} udisks2
# https://www.smartmontools.org
sudo apt install ${DRY_RUN} smartmontools
# https://nvmexpress.org
# https://github.com/linux-nvme/nvme-cli
sudo apt install ${DRY_RUN} nvme-cli

if false; then
  # https://github.com/linuxmint/timeshift
  sudo apt install ${DRY_RUN} timeshift # 操作系统备份
fi

IS_DEFAULT_ZSH="$(cat /etc/passwd | grep ${USER} | grep zsh)"
if [[ -z "${IS_DEFAULT_ZSH}" ]]; then
  sudo apt install ${DRY_RUN} git zsh
  # 用户默认终端设置为 ZSH
  [[ -z "${DRY_RUN}" ]] && chsh --shell /usr/bin/zsh
fi

# https://github.com/scop/bash-completion
# https://github.com/zsh-users/zsh-completions
sudo apt install ${DRY_RUN} bash-completion

# LF/CRLF/CR 换行符转换
sudo apt install ${DRY_RUN} dos2unix

if true; then
  sudo apt install ${DRY_RUN} bcompare
else
  sudo apt install ${DRY_RUN} kompare
fi

sudo apt install ${DRY_RUN} neovim
sudo apt install ${DRY_RUN} curl wget
sudo apt install ${DRY_RUN} asciidoctor
sudo apt install ${DRY_RUN} 7zip 7zip-rar
sudo apt install ${DRY_RUN} microsoft-edge-stable

# https://ccache.dev
# https://ccache.dev/download.html
no-cmd ccache && sudo apt install ${DRY_RUN} ccache

# https://astyle.sourceforge.net/notes.html
no-cmd astyle && sudo apt install ${DRY_RUN} astyle

# https://github.com/Old-Man-Programmer/tree
# https://gitlab.com/OldManProgrammer/unix-tree
# https://oldmanprogrammer.net/source.php?dir=projects/tree
no-cmd tree && sudo apt install ${DRY_RUN} tree

# https://htop.dev
# https://github.com/htop-dev/htop
no-cmd htop && sudo apt install ${DRY_RUN} htop

if true; then
  # https://github.com/Tomas-M/iotop
  # 下载 deb 解压提取 sbin/iotop-c 文件
  no-cmd iotop && sudo apt install ${DRY_RUN} iotop-c
else
  # http://guichaz.free.fr/iotop
  # https://repo.or.cz/w/iotop.git
  no-cmd iotop && sudo apt install ${DRY_RUN} iotop
fi

# TUI 二进制编辑器
# https://github.com/sharkdp/hexyl
# 下载 deb 解压提取 bin/hexyl 文件
no-cmd hexyl && sudo apt install ${DRY_RUN} hexyl
# GUI 二进制编辑器
# https://github.com/WerWolv/ImHex
# https://apps.kde.org/en/okteta

# https://beyondgrep.com
# https://github.com/beyondgrep/ack3
no-cmd ack && sudo apt install ${DRY_RUN} ack

# https://github.com/junegunn/fzf
no-cmd fzf && sudo apt install ${DRY_RUN} fzf

# https://sourceforge.net/p/cppcheck
no-cmd cppcheck && sudo apt install ${DRY_RUN} cppcheck

# https://sourceware.org/elfutils
# sudo apt install ${DRY_RUN} elfutils

######################
# 手动下载/解压/配置 #
######################

# https://gif.ski  优化 gif 图片(压缩)
# https://github.com/ImageOptim/gifski
# https://docs.rs/gifski/latest/gifski

# https://nodejs.org/dist
# https://mirrors.ustc.edu.cn/golang
# https://github.com/ninja-build/ninja/releases
# https://forge.rust-lang.org/infra/other-installation-methods.html

# 网络调试      https://www.nxtrace.org/downloads
# 解压扩展版    https://github.com/gohugoio/hugo/releases
# TUI 工具      https://github.com/jesseduffield/lazygit/releases
# 二进制比较    https://github.com/ymattw/ydiff/blob/master/ydiff.py
