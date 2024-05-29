# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-24T20:01:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# Cherry pick toolchain & tools, ignore if not exist
path-head-add "${ZETA_DIR}/3rd/bin/java"  # OpenJDK/bin
path-head-add "${ZETA_DIR}/3rd/bin/gems"  # GEM_HOME/bin
path-head-add "${ZETA_DIR}/3rd/bin/rust"  # rust/core/bin
path-head-add "${ZETA_DIR}/3rd/bin/cmk"   # CMake/bin
path-head-add "${ZETA_DIR}/3rd/bin/js"    # NodeJS/bin
path-head-add "${ZETA_DIR}/3rd/bin"

# `go env` 显示当前 Go 环境变量设置
if @zeta:xsh:has-cmd go; then
  GOROOT="$(realpath "${ZETA_DIR}/3rd/bin/go")"
  export GOROOT="${GOROOT%/bin/go}" # 安装目录

  # 第三方依赖模块下载保存位置
  export GOPATH="${GOROOT%/*}/xspace"

  # 启用 module-aware 模式
  export GO111MODULE=on

  # Go 模块代理下载地址(国内加速镜像)
# export GOPROXY="https://goproxy.io,direct" # 官方地址
  export GOPROXY="https://goproxy.cn,direct" # 七牛 CDN
# export GOPROXY="https://mirrors.aliyun.com/goproxy,direct" # 阿里云
fi

if @zeta:xsh:has-cmd npm; then
  # 获取 NODE 安装位置 $ npm config get prefix
  NODE_PATH="$(readlink "${ZETA_DIR}/3rd/bin/js")"
  export NODE_PATH="${NODE_PATH%/*}/lib/node_modules"
fi

# RubyGems Package Install Location GEM_HOME
# https://jekyllrb.com/docs/installation/ubuntu
if [[ -d "${ZETA_DIR}/3rd/vendor/gems" ]]; then
  export GEM_HOME="${ZETA_DIR}/3rd/vendor/gems"
fi

# 保存已安装的 toolchain 及 config
# 默认值 ~/.rustup 或 %USERPROFILE%/.rustup
# https://rust-lang.github.io/rustup/environment-variables.html
if [[ -d "${ZETA_DIR}/3rd/vendor/rust/rustup" ]]; then
  export RUSTUP_HOME="${ZETA_DIR}/3rd/vendor/rust/rustup"
fi

# 保存项目下载的依赖包(缓存)
# 默认值 ~/.cargo 或 %USERPROFILE%/.cargo
# https://doc.rust-lang.org/stable/cargo/reference/environment-variables.html
if [[ -d "${ZETA_DIR}/3rd/vendor/rust/cargo" ]]; then
  export CARGO_HOME="${ZETA_DIR}/3rd/vendor/rust/cargo"
fi

function @zeta:3rd:get-pkg-version() {
  local app="${ZETA_DIR}/3rd/vendor/$1"
  # --hide='PATTERN' --ignore='PATTERN' 可多次使用
  if [[ -d "${app}" ]]; then
   command ls --hide='*'{.zip,.bz2,.gz,.xz} --hide='[^0-9]*' "${app}"
  fi
}

function @zeta:3rd:update-symlink() {
  local sym="${ZETA_DIR}/3rd/bin/$1"
  local app="${ZETA_DIR}/3rd/vendor/$2"
  if [[ -f "${app}" || -d "${app}" ]]; then
    ln -sTf "${app}" "${sym}"
    echo "Create $(@G3 $1) $(@D9 '->') $(@Y3 "$(readlink "${sym}")")"
  fi
}

function @zeta:3rd:switch-to() {
  local bin="${ZETA_DIR}/3rd/bin"
  local pkg="$1" pick="$2" app version exe
  shift; shift
  for version in $(@zeta:3rd:get-pkg-version ${pkg}); do
    [[ "${pick}" == "${version}" ]] && {
      app="${pkg}/${version}/bin"
      if [[ $# -eq 1 ]]; then
        @zeta:3rd:update-symlink $1 "${app}"
      else
        for exe in $@; do
          @zeta:3rd:update-symlink ${exe} "${app}/${exe}"
        done
      fi
      return
    }
  done
  echo "=> no $(@G3 ${pkg}) version $(@R3 ${pick}) found"
  return 1
}

function @zeta:3rd:usage-help() {
  local _PkgName_=( go  rust  cmake  java  nodejs )
  echo
  echo -e "-> $(@C3 switch-to) $(@R3 'sys-default')"
  echo
  local app version count=0 cfn
  for app in ${_PkgName_[@]}; do
    cfn=@G3; (( count++, count%2 == 0 )) && cfn=@B3
    for version in $(@zeta:3rd:get-pkg-version ${app}); do
      echo "-> $(@C3 switch-to) $(${cfn} ${app}) $(@Y3 ${version})"
    done
  done
  echo
}

function switch-to() {
  [[ $# -eq 0 ]] && { @zeta:3rd:usage-help; return; }
  case "$1" in
    sys-default)
      local bin="${ZETA_DIR}/3rd/bin" sln
      local SymLinkNames=( js cmk rust gems java go gofmt )
      for sln in ${SymLinkNames}; do
        [[ -h "${bin}/${sln}" ]] && {
          printf "Remove $(@Y3 ${sln}) $(@D9 '->') "
          echo "$(@G3 "$(readlink -m "${bin}/${sln}")")"
          rm -f "${bin}/${sln}"
        }
      done
      ;;
    go)
      @zeta:3rd:switch-to go "$2"  go  gofmt
      export GOROOT="${ZETA_DIR}/3rd/vendor/$1/$2"
      ;;
    rust)
      @zeta:3rd:switch-to rust "$2" rust    # rust/$2/bin
      ;;
    cmake)
      @zeta:3rd:switch-to cmake "$2" cmk    # cmake/$2/bin
      ;;
    java)
      @zeta:3rd:switch-to java "$2" java    # java/$2/bin
      ;;
    nodejs)
      @zeta:3rd:switch-to nodejs "$2" js    # nodejs/$2/bin
      export NODE_PATH="${ZETA_DIR}/3rd/vendor/$1/$2/lib/node_modules"
      ;;
    *)
      echo "=> not found package of $(@R3 $1)"
      ;;
  esac
}

if [[ -n "${ZSH_VERSION:-}" ]]; then
  function @zeta:comp:switch-to() {
    local -A opt_args
    local context state state_descr line

    function @zeta:once±top-cmds() {
      local -a apps=( sys-default  cmake  go  rust  nodejs  java )
      _describe 'command' apps
    }

    _arguments ':app:@zeta:once±top-cmds' ':version:->todo'
    if [[ "todo" == "${state[1]}" ]]; then
      local -a verlist
      verlist=( $(@zeta:3rd:get-pkg-version ${line[1]}) )
      _describe 'command' verlist
    fi

    unset -f @zeta:once±top-cmds
  }
  compdef @zeta:comp:switch-to switch-to
elif [[ -n "${BASH_VERSION:-}" ]]; then
  function @zeta:comp:switch-to() {
    local -a apps=( sys-default  cmake  go  rust  nodejs  java )
    if [[ "switch-to" == "$3" ]]; then
      COMPREPLY=($(compgen -W "${apps[*]}" -- "$2"))
    else
      COMPREPLY=($(compgen -W "$(@zeta:3rd:get-pkg-version "$3")" -- "$2"))
    fi
  }
  complete -o nosort -F @zeta:comp:switch-to switch-to
fi
