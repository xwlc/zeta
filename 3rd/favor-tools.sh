#!/usr/bin/env bash

function has-cmd() {  command -v "$1" > /dev/null; }
function no-cmd() { ! command -v "$1" > /dev/null; }

no-cmd apt && exit 1

if [[ "$1" != "INSTALL" ]]; then
  DRY_RUN='--dry-run'
fi

# apt search ^gcc-[0-9][0-9]$
# apt search ^clang-[0-9][0-9]$
sudo apt install ${DRY_RUN} gcc clang git
sudo apt install ${DRY_RUN} build-essential

# APT 包文件搜索/显示工具
sudo apt install ${DRY_RUN} apt-file
[[ -z "${DRY_RUN}" ]] && sudo apt-file update # 更新缓存

IS_DEFAULT_ZSH="$(cat /etc/passwd | grep ${USER} | grep zsh)"
if [[ -z "${IS_DEFAULT_ZSH}" ]]; then
  sudo apt install ${DRY_RUN} zsh # 默认终端 ZSH
  [[ -z "${DRY_RUN}" ]] && chsh --shell /usr/bin/zsh
fi

if false; then # 备份操作系统
  # https://github.com/linuxmint/timeshift
  sudo apt install ${DRY_RUN} timeshift

  # https://github.com/scop/bash-completion
  # https://github.com/zsh-users/zsh-completions
  sudo apt install ${DRY_RUN} bash-completion
fi

# https://www.rodsbooks.com/gdisk
# https://sourceforge.net/projects/gptfdisk/files/gptfdisk
sudo apt install ${DRY_RUN} gdisk
# https://github.com/storaged-project
# https://www.freedesktop.org/wiki/Software/udisks
sudo apt install ${DRY_RUN} udisks2
# https://nvmexpress.org
# https://github.com/linux-nvme/nvme-cli
sudo apt install ${DRY_RUN} nvme-cli
# https://www.smartmontools.org
sudo apt install ${DRY_RUN} smartmontools

if true; then
  sudo apt install ${DRY_RUN} bcompare
else
  sudo apt install ${DRY_RUN} kompare
fi

sudo apt install ${DRY_RUN} neovim
sudo apt install ${DRY_RUN} dos2unix
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

# https://tracker.debian.org/pkg/qtcreator
# https://tracker.debian.org/pkg/qt6-base
# https://tracker.debian.org/pkg/qtbase-opensource-src
if false; then
  sudo apt install ${DRY_RUN} qtcreator
  sudo apt install ${DRY_RUN} qtbase5-dev
fi

exit

#######################
# 下载/解压/编译/配置 #
#######################

# 硬件检查
# https://www.cpuid.com                       CPU-Z
# https://github.com/klauspost/cpuid          Go 语言版
# https://www.etallen.com/cpuid.html          C  语言版
# https://www.sandpile.org/x86/cpuid.htm      信息/整理
# https://github.com/InstLatx64/InstLatx64    信息/整理

# 图片/图像
# https://gif.ski  优化 gif 图片(压缩)
# https://github.com/ImageOptim/gifski
# https://docs.rs/gifski/latest/gifski

#################
# Rust 编程语言 #
#################
# https://rust-lang.github.io/rustup/installation/other.html
# https://forge.rust-lang.org/infra/other-installation-methods.html

# 更新工具链 RUSTUP_DIST_SERVER, 自我更新 RUSTUP_UPDATE_ROOT
# 软件包下载 ${RUSTUP_DIST_SERVER}/dist/channel-rust-stable.toml
export RUSTUP_DIST_SERVER="https://static.rust-lang.org"                # 官方
export RUSTUP_DIST_SERVER="https://mirrors.ustc.edu.cn/rust-static"     # 中科
export RUSTUP_DIST_SERVER="https://mirrors.tuna.tsinghua.edu.cn/rustup" # 清华
# 下载 ${RUSTUP_DIST_SERVER}/rustup/dist/<目标平台>/rustup-init
# 移动 rustup-init -> CARGO_HOME/bin/rustup 添加执行权限
# 安装工具链 rustup --profile minimal toolchain install stable

# https://rust-lang.github.io/rustup/environment-variables.html
if [[ -d "${ZETA_DIR}/3rd/vendor/rust/xmeta" ]]; then
  # 默认值 ~/.rustup 或 %USERPROFILE%/.rustup
  export RUSTUP_HOME="${ZETA_DIR}/3rd/vendor/rust/xmeta"
  export RUSTUP_UPDATE_ROOT="${RUSTUP_DIST_SERVER}/rustup"
fi
# 清华 https://mirrors.tuna.tsinghua.edu.cn/help/rustup
# 中科 https://mirrors.ustc.edu.cn/help/rust-static.html

# => ${RUSTUP_DIST_SERVER}/dist/channel-rust-stable.toml
# => ${RUSTUP_DIST_SERVER}/dist/YYYY-MM-DD/组件-版本-平台.tar.xz
VERSION=1.79.0; Y4M2D2=2024-06-13; URL="${RUSTUP_DIST_SERVER}/dist/${Y4M2D2}"

# 组件 https://forge.rust-lang.org/infra/channel-layout.html
# 组件 https://rust-lang.github.io/rustup/concepts/components.html
# 配置 minimal
#      rustc            编译器和文档工具
#      cargo            依赖管理及构建发布
#      rust-std         标准库组件(交叉编译)
#      rust-mingw       微软 Win 编译链接支持
# 配置 default
#      clippy           风格及质量检测 Lint
#      rustfmt          Rust 代码格式化工具
#      rust-docs        https://doc.rust-lang.org/{stable,beta,nightly}
# 配置 complete
#      rust-src         支持 rust-analyzer 补全标准库
#      rust-analyzer    编辑器(IDE)语法解析(VSCode, Vim)
#                       https://rust-analyzer.github.io
#                       https://github.com/rust-lang/rust-analyzer
#      miri             解析中间产物
COMPONENTS=(rustc  cargo  rust-std  clippy  rustfmt  rust-docs  rust-analyzer)
for pkg in ${COMPONENTS[@]}; do
  echo "${URL}/${pkg}-${VERSION}-x86_64-unknown-linux-gnu.tar.xz"
done
