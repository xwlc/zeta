#!/usr/bin/bash

THIS_AFP="$(realpath "${0}")"        # 当前文件绝对路径(含名)
THIS_FNO="$(basename "${THIS_AFP}")" # 仅包含当前文件的文件名
THIS_DIR="$(dirname  "${THIS_AFP}")" # 当前文件所在的绝对路径

# 更新工具链 RUSTUP_DIST_SERVER, 自我更新 RUSTUP_UPDATE_ROOT
# 软件包下载 ${RUSTUP_DIST_SERVER}/dist/channel-rust-stable.toml
export RUSTUP_DIST_SERVER="https://static.rust-lang.org"                # 官方
export RUSTUP_DIST_SERVER="https://mirrors.ustc.edu.cn/rust-static"     # 中科
export RUSTUP_DIST_SERVER="https://mirrors.tuna.tsinghua.edu.cn/rustup" # 清华
# RUSTUP_DIST_SERVER/rustup/dist/<目标平台>/rustup-init
# 移动 rustup-init -> CARGO_HOME/bin/rustup 添加执行权限
# 安装 rustup --profile minimal toolchain install stable

# 清华 https://mirrors.tuna.tsinghua.edu.cn/help/rustup
# 中科 https://mirrors.ustc.edu.cn/help/rust-static.html
# https://rust-lang.github.io/rustup/environment-variables.html
export RUSTUP_HOME="${ZETA_DIR}/3rd/vendor/rust/xmeta"
export RUSTUP_UPDATE_ROOT="${RUSTUP_DIST_SERVER}/rustup"

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
COMPONENTS=(rustc  cargo  rust-std  clippy  rustfmt  rust-analyzer  rust-docs)

# https://rust-lang.github.io/rustup/installation/other.html
# https://forge.rust-lang.org/infra/other-installation-methods.html
VERSION=1.79.0; Y4M2D2=2024-06-13; DEST_DIR="${THIS_DIR}/${VERSION}"
# => ${RUSTUP_DIST_SERVER}/dist/channel-rust-stable.toml
# => ${RUSTUP_DIST_SERVER}/dist/YYYY-MM-DD/组件-版本-平台.tar.xz
BASE_URL="${RUSTUP_DIST_SERVER}/dist/${Y4M2D2}"

function install-component() {
  local tarball="$1-${VERSION}-${TRIPLET}"
  local url="${BASE_URL}/${tarball}.tar.xz" topdir="${tarball}"
  if [[ ! -f "${THIS_DIR}/${tarball}.tar.xz" ]]; then
    echo "下载 ${url}"
    wget ${url} -O "${THIS_DIR}/${tarball}.tar.xz"
    [[ $? -ne 0 ]] && return
  fi

  [[ "$2" == NoInstall ]] && return

  [[ ! -f "${THIS_DIR}/${tarball}.tar.xz" ]] && return
  if [[ ! -d "${THIS_DIR}/${topdir}" ]]; then
    tar -xf "${THIS_DIR}/${tarball}.tar.xz" -C "${THIS_DIR}"
  fi

  local line file subdir; echo "安装 ${topdir}"
  if [[ $1 == rust-std ]]; then
    subdir="${topdir}/$1-${TRIPLET}/lib/rustlib/${TRIPLET}/lib"
    rmdir "${THIS_DIR}/${subdir}/self-contained"
    mkdir -p "${DEST_DIR}/lib/rustlib/${TRIPLET}/lib"
    mv "${THIS_DIR}/${subdir}/"* "${DEST_DIR}/lib/rustlib/${TRIPLET}/lib"
  else
    local src="${topdir}/$1"; [[ $# -eq 2 ]] && src="${topdir}/$1-$2"
    while read line; do
      file=$(echo ${line} | cut -f2 -d:)
      [[ ${file} =~ share/doc/* ]] && continue; subdir=${file%/*}
      [[ ! -d "${DEST_DIR}/${subdir}" ]] && mkdir -p "${DEST_DIR}/${subdir}"
      if [[ -f "${THIS_DIR}/${src}/${file}" ]]; then
        mv  "${THIS_DIR}/${src}/${file}"  "${DEST_DIR}/${subdir}"
      fi
    done < "${THIS_DIR}/${src}/manifest.in"
  fi

  rm -rf "${THIS_DIR}/${topdir}"
}

TRIPLET=x86_64-unknown-linux-gnu
install-component rustc
install-component cargo
install-component rust-std
install-component clippy          preview
install-component rustfmt         preview
install-component rust-analyzer   preview

install-component rust-docs       NoInstall
