# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-24T20:01:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# Cherry pick apps & tools, ignore if path not exist
path-head-add "${ZETA_DIR}/3rd/tools" # Rust/Ruby Apps
path-head-add "${ZETA_DIR}/3rd/pick"  # Symbolic Links
path-head-add "${ZETA_DIR}/3rd/bin"   # Standalone Apps

# RubyGems 第三方依赖软件包的安装位置 GEM_HOME
# https://jekyllrb.com/docs/installation/ubuntu
if [[ -d "${ZETA_DIR}/3rd/vendor/gems" ]]; then
  export GEM_HOME="${ZETA_DIR}/3rd/vendor/gems"
fi
# 中科 https://mirrors.ustc.edu.cn/help/rubygems.html
# 清华 https://mirrors.tuna.tsinghua.edu.cn/help/rubygems

# 终端显示 NodeJS 安装位置 $ npm config get prefix
if @zeta:xsh:has-cmd node; then
  NODE_PATH="$(command -v node)" # NodeJS 模块查找路径
  NODE_PATH="$(realpath -eq "${NODE_PATH}")" # 冒号分割列表
  export NODE_PATH="${NODE_PATH%/bin/node}/lib/node_modules"
fi
# 中科 https://mirrors.ustc.edu.cn/help/node.html
# 清华 https://mirrors.tuna.tsinghua.edu.cn/help/nodejs-release

# 终端显示当前 Go 环境变量 $ go env
if @zeta:xsh:has-cmd go; then
  GOROOT="$(command -v go)" # Go 语言的安装目录
  GOROOT="$(realpath -eq "${GOROOT}")" # => go/X.Y.Z/bin/go
  export GOROOT="${GOROOT%/bin/go}"    # => go/X.Y.Z

  [[ "${GOROOT}" =~ "^${ZETA_DIR}/3rd/vendor/go/[0-9.]*$" ]] && {
    export GO111MODULE=on # 启用 module-aware 模式
    # 模块包下载及安装, 目录结构 bin/ + pkg/ + src/
    export GOPATH="${GOROOT%/*}/modules" # => vendor/go/modules
  }

  # Go 模块代理下载地址(国内加速镜像)
# export GOPROXY="https://goproxy.io,direct" # 官方地址
  export GOPROXY="https://goproxy.cn,direct" # 七牛 CDN
# export GOPROXY="https://mirrors.aliyun.com/goproxy,direct" # 阿里云

  # export GOCACHE="" # 编译缓存, 默认值 ~/.cache/go-build
  # export GOENV=""   # 用户配置, 默认值 ~/.config/go/env
fi

# https://doc.rust-lang.org/stable/cargo/index.html
if [[ -d "${ZETA_DIR}/3rd/vendor/rust/cargo" ]]; then
  # 默认值 ~/.cargo 或 %USERPROFILE%/.cargo
  export CARGO_HOME="${ZETA_DIR}/3rd/vendor/rust/cargo"
fi
# 中科 https://mirrors.ustc.edu.cn/help/crates.io-index.html
# 清华 https://mirrors.tuna.tsinghua.edu.cn/help/crates.io-index

if @zeta:xsh:has-cmd java; then
  JAVA_HOME="$(command -v java)"
  JAVA_HOME="$(realpath -eq "${JAVA_HOME}")"
  export JAVA_HOME="${JAVA_HOME%/bin/java}"
  # Android Studio Java Development Kit
  export STUDIO_JDK="${JAVA_HOME}"
fi

function zman() {
  local cmakeMAN  nodeMAN  rustMAN  javaMAN  xMAN

  cmakeMAN="$(@zeta:3rd:get-vendor-path cmake)"
  [[ -n "${cmakeMAN}" ]] && cmakeMAN="$(realpath -eq "${cmakeMAN}/../man")"

  nodeMAN="$(@zeta:3rd:get-vendor-path node)"
  [[ -n "${nodeMAN}" ]] && nodeMAN="$(realpath -eq "${nodeMAN}/../share/man")"

  javaMAN="$(@zeta:3rd:get-vendor-path java)"
  [[ -n "${javaMAN}" ]] && javaMAN="$(realpath -eq "${javaMAN}/../man")"

  rustMAN="$(@zeta:3rd:get-vendor-path rustc)"
  [[ -n "${rustMAN}" ]] && rustMAN="$(realpath -eq "${rustMAN}/../share/man")"

  if [[ $# -eq 3 ]]; then
    case "$1" in
      c|C|cmake) xMAN="${cmakeMAN}" ;;
      j|J|java)  xMAN="${javaMAN}"  ;;
      r|R|rust)  xMAN="${rustMAN}"  ;;
      *) return ;;
    esac
    if [[ -f "${xMAN}/man$2/$3.$2" ]]; then
      man -l "${xMAN}/man$2/$3.$2"
    fi
    return
  fi

  case "$1" in
    cmake) man -l "${cmakeMAN}/man1/cmake.1" ;; # CMake
    cpack) man -l "${cmakeMAN}/man1/cpack.1" ;;
    ctest) man -l "${cmakeMAN}/man1/ctest.1" ;;
    javac) man -l  "${javaMAN}/man1/javac.1" ;; # Java
     java) man -l  "${javaMAN}/man1/java.1"  ;;
      jar) man -l  "${javaMAN}/man1/jar.1"   ;;
    rustc) man -l  "${rustMAN}/man1/rustc.1" ;; # Rust
    cargo) man -l  "${rustMAN}/man1/cargo.1" ;;
     node) man -l  "${nodeMAN}/man1/node.1"  ;; # NodeJS
    *)
      echo; @zeta:xsh:notes zman '<C|R|J>' '<1-8>' '<Name>'; echo
      [[ -n "${cmakeMAN}" ]] && {
        echo "=> $(@R3 cmake)"
        command ls "${cmakeMAN}/man1/"
        command ls "${cmakeMAN}/man7/"
        echo
      }
      [[ -n "${rustMAN}" ]] && {
        echo "=> $(@R3 rust)"
        command ls "${rustMAN}/man1/"
        echo
      }
      [[ -n "${javaMAN}" ]] && {
        echo "=> $(@R3 java)"
        command ls "${javaMAN}/man1/"
        echo
      }
    ;;
  esac
}

function @zeta:3rd:is-vendor-pkg() {
  [[ "$1" =~ "^${ZETA_DIR}/3rd/vendor/*" ]]
}

function @zeta:3rd:get-vendor-path() {
  local _path_; _path_="$(command -v $1)"
  [[ $? -ne 0 ]] && return
  _path_="$(realpath -eq "${_path_}")"; _path_="${_path_%/*}"
  @zeta:3rd:is-vendor-pkg "${_path_}" && echo "${_path_}"
}

function @zeta:3rd:get-pkg-version() {
  local app="${ZETA_DIR}/3rd/vendor/$1"
  if [[ -d "${app}" ]]; then
    # 参数 --hide='PATTERN' 和 --ignore='PATTERN' 可以多次重复使用
   command ls --hide='*'{.zip,.bz2,.gz,.xz} --hide='[^0-9]*' "${app}"
  fi
}

function @zeta:3rd:create-links() {
  local sym="${ZETA_DIR}/3rd/pick/$1"
  local app="${ZETA_DIR}/3rd/vendor/$2"
  [[ -h "${app}" ]] && app="$(realpath -eq "${app}")"
  if [[ -n "${app}" && -f "${app}" ]]; then
    ln -sTf "${app}" "${sym}" # -s 符号链接 -f 若已存在则删除后重建
    printf "Create $(@D9 '3rd/pick/')$(@G3 "%-12s") " "$1"
    echo "$(@D9 '->') $(@Y3 "${app}")"
  fi
}

function @zeta:3rd:delete-links() {
  local binEXE=$1  pkgBIN
  case $1 in
    rust) binEXE=rustc ;; # pick/rustc
    node) binEXE=node  ;; # pick/node
  esac

  # 读 binEXE 软链接, 找到 pkgBIN 目标路径
  pkgBIN="$(@zeta:3rd:get-vendor-path ${binEXE})"
  [[ -z "${pkgBIN}" ]] && return

  local pickDIR="${ZETA_DIR}/3rd/pick"
  for binEXE in $(ls "${pkgBIN}"); do
    [[ -h "${pickDIR}/${binEXE}" ]] && {
      printf "Delete $(@D9 '3rd/pick/')$(@Y3 %-12s) $(@D9 '->') " ${binEXE}
      echo "$(@G3 "$(realpath -eq "${pickDIR}/${binEXE}")")"
      rm -f "${pickDIR}/${binEXE}"
    }
  done
}

function @zeta:3rd:zeta-switch() {
  [[ "$2" == "reset" ]] && {
    @zeta:3rd:delete-links $1; return
  }
  local app="$1"  selected="$2"  version
  for version in $(@zeta:3rd:get-pkg-version ${app}); do
    [[ "${selected}" == "${version}" ]] && {
      local pkgBIN="${app}/${version}/bin" binEXE
      for binEXE in $(ls "${ZETA_DIR}/3rd/vendor/${pkgBIN}"); do
        @zeta:3rd:create-links ${binEXE} "${pkgBIN}/${binEXE}"
      done; return
    }
  done
}

function @zeta:3rd:update-tools() {
  local -A xskip
  local tools="${ZETA_DIR}/3rd/tools"  prog  xpkg
  if [[ -n "$(command ls "${tools}")" ]]; then
    for prog in $(command ls "${tools}"); do
      local abspath="$(realpath -eq "${tools}/${prog}")"
      if [[ $? -ne 0 || -z "${abspath}" ]]; then
        echo "Delete $(@D9 3rd/tools/)$(@G3 ${prog}) $(@D9 '->') $(@Y3 "${abspath}")"
        rm -f "${tools}/${prog}"
      else
        xskip["${abspath}"]=true
      fi
    done
  fi

  local node="${NODE_PATH#${ZETA_DIR}/3rd/vendor/}"
  node="${node%/lib/node_modules}" # 当前 NODE 版本

  for xpkg in rust/cargo  ${node}  gems; do
    local xbin="${ZETA_DIR}/3rd/vendor/${xpkg}/bin"
    [[ -z "$(command ls "${xbin}")" ]] && continue
    for prog in $(command ls "${xbin}"); do
      [[ "${xpkg}" == "${node}" ]] && {
        case ${prog} in
          node|corepack|npm|npx) continue ;;
        esac
      }
      local abspath="$(realpath -eq "${xbin}/${prog}")"
      [[ $? -ne 0 || -z "${abspath}" || ${xskip["${abspath}"]} ]] && continue
      ln -sTf  "${abspath}"  "${tools}/${prog}"; xskip["${abspath}"]=true
      echo "Update $(@D9 3rd/tools/)$(@G3 ${prog}) $(@D9 '->') $(@Y3 "${abspath}")"
    done
  done
}

function @zeta:3rd:usage-help() {
  local _PKGS_=( cmake  java  node  rust  go  nim ) app version
  echo
  echo "-> $(@D9 zeta-switch) $(@R3 reset)   $(@G3 PKG)"
  echo "-> $(@D9 zeta-switch) $(@R3 update-tools)"
  echo
  for app in ${_PKGS_[@]}; do
    for version in $(@zeta:3rd:get-pkg-version ${app}); do
      printf -v app "%-5s" "${app}"
      echo "-> $(@D9 zeta-switch) $(@G3 "${app}") $(@Y3 ${version})"
    done
  done
  echo
}

function zeta-switch() {
  [[ $# -eq 0 || -z "$1" ]] && { @zeta:3rd:usage-help; return; }

  if [[ "$1" == reset ]]; then
    case "$2" in
      cmake|java|node|rust|go|nim) @zeta:3rd:delete-links $2; return ;;
      *) echo "invalid $(@D9 3rd/vendor/)$(@R3 $2) package"; return 1 ;;
    esac
  elif [[ "$1" == update-tools ]]; then
    @zeta:3rd:update-tools; return
  fi

  case "$1" in
    cmake) @zeta:3rd:zeta-switch cmake "$2" ;; # cmake/$2/bin/*
     java) @zeta:3rd:zeta-switch java  "$2" ;; #  java/$2/bin/*
     node) @zeta:3rd:zeta-switch node  "$2" ;; #  node/$2/bin/*
     rust) @zeta:3rd:zeta-switch rust  "$2" ;; #  rust/$2/bin/*
       go) @zeta:3rd:zeta-switch go    "$2" ;; #    go/$2/bin/*
      nim) @zeta:3rd:zeta-switch nim   "$2" ;; #   nim/$2/bin/*
    *) echo "invalid $(@D9 3rd/vendor/)$(@R3 $1) package"; return 1 ;;
  esac

  if [[ "$1" == go ]]; then
    export GOROOT="${ZETA_DIR}/3rd/vendor/$1/$2"
  elif [[ "$1" == node ]]; then
    export NODE_PATH="${ZETA_DIR}/3rd/vendor/$1/$2/lib/node_modules"
  fi
}

if [[ -n "${ZSH_VERSION:-}" ]]; then
  function @zeta:comp:zeta-switch() {
    local -A opt_args
    local context state state_descr line
    local -a _apps_=( cmake  java  node  rust  go  nim ) _keys_
    function once±zcomp1() {
      _keys_=( reset update-tools ${_apps_[@]} )
      _describe 'command' _keys_; unset -f once±zcomp1
    }
    # 语法 N:Message:Action 表示第 N 个参数执行 Action 行为
    # NOTE Action 可以是普通的 Shell 函数调用
    # NOTE Action 语法 ->XXX 表示将 state 设置为 XXX
    _arguments '1:参数壹:once±zcomp1' '2:参数贰:->todo'
    if [[ "todo" == "${state[1]}" ]]; then
      case "${line[1]}" in
        update-tools) return ;;
        reset) _describe 'command' _apps_; return ;;
      esac
      _keys_=( $(@zeta:3rd:get-pkg-version ${line[1]}) )
      _describe 'command' _keys_
    fi
  }
  # zsh/sched => 延迟 1s 执行, 等待 compinit 完成
  sched +1 compdef @zeta:comp:zeta-switch zeta-switch
elif [[ -n "${BASH_VERSION:-}" ]]; then
  function @zeta:comp:zeta-switch() {
    # $1 待补全命令, 等同于 ${COMP_WORDS[0]}
    # $2 待补全参数, 等同于 ${COMP_WORDS[${COMP_CWORD}]}
    # $3 前一个参数, 等同于 ${COMP_WORDS[${COMP_CWORD}-1]}
    # 按空格分隔数组 COMP_WORDS, 最后输入词索引 COMP_CWORD
    [[ ${COMP_CWORD} -eq 3 ]] && return # 最多 2 个参数
    local -a _apps_=( cmake  java  node  rust  go  nim )

    if [[ ${COMP_CWORD} -eq 1 ]]; then
      COMPREPLY=( $(compgen -W "reset update-tools ${_apps_[*]}" -- "$2") )
      return
    fi

    case "$3" in
      update-tools) return ;;
      reset) COMPREPLY=( $(compgen -W "${_apps_[*]}" -- "$2") ) ;;
      *) COMPREPLY=( $(compgen -W "$(@zeta:3rd:get-pkg-version "$3")" -- "$2") ) ;;
    esac
  }
  complete -o nosort -F @zeta:comp:zeta-switch zeta-switch
fi
