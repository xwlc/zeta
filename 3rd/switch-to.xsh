# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-24T20:01:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

function zman() {
  local cmkMAN  jsMAN  rustMAN  javaMAN

  if [[ -h "${ZETA_DIR}/3rd/bin/cmk" ]]; then
    cmkMAN="$(realpath "${ZETA_DIR}/3rd/bin/cmk/../man")"
  fi
  if [[ -h "${ZETA_DIR}/3rd/bin/js" ]]; then
    jsMAN="$(realpath "${ZETA_DIR}/3rd/bin/js/../share/man")"
  fi
  if [[ -h "${ZETA_DIR}/3rd/bin/java" ]]; then
    javaMAN="$(realpath "${ZETA_DIR}/3rd/bin/java/../man")"
  fi
  if [[ -h "${ZETA_DIR}/3rd/bin/rust" ]]; then
    rustMAN="$(realpath "${ZETA_DIR}/3rd/bin/rust/../share/man")"
  fi

  if [[ $# -eq 3 ]]; then
    local xMAN
    case "$1" in
      c|C|cmake) xMAN="${cmkMAN}"  ;;
      j|J|java)  xMAN="${javaMAN}" ;;
      r|R|rust)  xMAN="${rustMAN}" ;;
      *) return ;;
    esac
    if [[ -f "${xMAN}/man$2/$3.$2" ]]; then
      man -l "${xMAN}/man$2/$3.$2"
    fi
    return
  fi

  case "$1" in
    node)  man -l "${jsMAN}/man1/node.1"    ;; # NodeJS
    cmake) man -l "${cmkMAN}/man1/cmake.1"  ;; # CMake
    cpack) man -l "${cmkMAN}/man1/cpack.1"  ;;
    ctest) man -l "${cmkMAN}/man1/ctest.1"  ;;
    jar)   man -l "${javaMAN}/man1/jar.1"   ;; # Java
    java)  man -l "${javaMAN}/man1/java.1"  ;;
    javac) man -l "${javaMAN}/man1/javac.1" ;;
    cargo) man -l "${rustMAN}/man1/cargo.1" ;; # Rust
    rustc) man -l "${rustMAN}/man1/rustc.1" ;;
    *)
      echo
      echo "Usage: $(@C3 zman) $(@Y3 '<C|R|J>') $(@R3 '<1-8>') $(@B3 '<XXX>')"
      echo
      echo "$(@G3 cmake) $(@D9 'Manual Pages')"
      command ls "${cmkMAN}/man1/"
      command ls "${cmkMAN}/man7/"
      echo
      echo "$(@G3 rust) $(@D9 'Manual Pages')"
      command ls "${rustMAN}/man1/"
      echo
      echo "$(@G3 java) $(@D9 'Manual Pages')"
      command ls "${javaMAN}/man1/"
      echo
    ;;
  esac
}

# Cherry pick toolchain & tools, ignore if not exist
path-head-add "${ZETA_DIR}/3rd/bin/gems"  #     GEM_HOME/bin
path-head-add "${ZETA_DIR}/3rd/bin/java"  #   Java/X.Y.Z/bin
path-head-add "${ZETA_DIR}/3rd/bin/rust"  #   Rust/X.Y.Z/bin
path-head-add "${ZETA_DIR}/3rd/bin/nim"   #    Nim/X.Y.Z/bin
path-head-add "${ZETA_DIR}/3rd/bin/cmk"   #  CMake/X.Y.Z/bin
path-head-add "${ZETA_DIR}/3rd/bin/js"    # NodeJS/X.Y.Z/bin
path-head-add "${ZETA_DIR}/3rd/bin"

# NOTE `go env` 显示当前 Go 环境变量
if @zeta:xsh:has-cmd go; then
  GOROOT="$(realpath "${ZETA_DIR}/3rd/bin/go")" # => go/X.Y.Z/bin/go
  export GOROOT="${GOROOT%/bin/go}" # 安装目录  # => go/X.Y.Z

  # 启用 module-aware 模式
  export GO111MODULE=on
  # 模块包下载及安装, 目录结构 bin/ + pkg/ + src/
  export GOPATH="${GOROOT%/*}/modules"

  # Go 模块代理下载地址(国内加速镜像)
# export GOPROXY="https://goproxy.io,direct" # 官方地址
  export GOPROXY="https://goproxy.cn,direct" # 七牛 CDN
# export GOPROXY="https://mirrors.aliyun.com/goproxy,direct" # 阿里云

  # export GOCACHE="" # 编译缓存, 默认值 ~/.cache/go-build
  # export GOENV=""   # 用户配置, 默认值 ~/.config/go/env
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
  local _PkgName_=( cmake  go  nim  rust  nodejs  java )
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
      local SymLinkNames=( gems  cmk  go gofmt  js  nim  rust  java )
      for sln in ${SymLinkNames}; do
        [[ -h "${bin}/${sln}" ]] && {
          printf "Remove $(@Y3 ${sln}) $(@D9 '->') "
          echo "$(@G3 "$(readlink -m "${bin}/${sln}")")"
          rm -f "${bin}/${sln}"
        }
      done
      ;;
    cmake)
      @zeta:3rd:switch-to cmake   "$2"  cmk   ;;  # cmake/$2/bin
    go)
      @zeta:3rd:switch-to go      "$2"  go  gofmt
      export GOROOT="${ZETA_DIR}/3rd/vendor/$1/$2"
      ;;
    nim)
      @zeta:3rd:switch-to nim     "$2"  nim   ;;  #  nim/$2/bin
    rust)
      @zeta:3rd:switch-to rust    "$2"  rust  ;;  # rust/$2/bin
    java)
      @zeta:3rd:switch-to java    "$2"  java  ;;  # java/$2/bin
    nodejs)
      @zeta:3rd:switch-to nodejs  "$2"  js      # nodejs/$2/bin
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
      local -a apps=( sys-default  cmake  go  nim  rust  nodejs  java )
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
    local -a apps=( sys-default  cmake  go  nim  rust  nodejs  java )
    if [[ "switch-to" == "$3" ]]; then
      COMPREPLY=($(compgen -W "${apps[*]}" -- "$2"))
    else
      COMPREPLY=($(compgen -W "$(@zeta:3rd:get-pkg-version "$3")" -- "$2"))
    fi
  }
  complete -o nosort -F @zeta:comp:switch-to switch-to
fi
