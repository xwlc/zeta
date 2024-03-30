# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-24T20:01:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# Cherry pick tools, ignore if folder not exist
path-head-add "${ZETA_DIR}/3rd/bin/ruby" # -> GEM_HOME/bin
path-head-add "${ZETA_DIR}/3rd/bin/jdk"  # -> OpenJDK/bin
path-head-add "${ZETA_DIR}/3rd/bin/js"   # -> NodeJS/bin
path-head-add "${ZETA_DIR}/3rd/bin"

# `go env` 显示当前 Go 环境变量设置
if command -v go > /dev/null; then
  # GOROOT 表示 Go 的安装目录
  GOROOT="$(realpath "${ZETA_DIR}/3rd/bin/go")"
  export GOROOT="${GOROOT%/bin/go}"

  # 第三方依赖模块下载保存位置
  export GOPATH="${GOROOT%/*}/xspace"

  # 启用 module-aware 模式
  export GO111MODULE=on

  # Go 模块代理下载地址(国内加速镜像)
# export GOPROXY="https://goproxy.io,direct" # 官方地址
  export GOPROXY="https://goproxy.cn,direct" # 七牛 CDN
# export GOPROXY="https://mirrors.aliyun.com/goproxy,direct" # 阿里云
fi

if command -v npm > /dev/null; then
  # npm config get prefix
  NODE_PATH="$(readlink "${ZETA_DIR}/3rd/bin/js")"
  export NODE_PATH="${NODE_PATH%/*}/lib/node_modules"
fi

# RubyGems Package Install Location GEM_HOME
# https://jekyllrb.com/docs/installation/ubuntu
if [[ -d "${ZETA_DIR}/3rd/vendor/rubygems" ]]; then
  export GEM_HOME="${ZETA_DIR}/3rd/vendor/rubygems"
fi

function @zeta:3rd:get-versions() {
  local app="${ZETA_DIR}/3rd/vendor/$1"
  # --hide='PATTERN' --ignore='PATTERN' 可多次使用
  [[ -d "${app}" ]] && command ls --hide='*'{.zip,.bz2,.gz,.xz}'*' "${app}"
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
  for version in $(@zeta:3rd:get-versions ${pkg}); do
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
  echo "=> no $(@G3 ${pkg}) version $(@R3 ${pick}) found"; return 1;
}

function switch-to() {
  [[ $# -eq 1 ]] && {
    case "$1" in
      os-default)
        local sln symlinks=(
          nvim
          ccache
          cppcheck
          graph-easy
          go  gofmt
          cmake cpack  ccmake  ctest  cmake-gui
          js
          jdk
          ruby
        )
        local bin="${ZETA_DIR}/3rd/bin"
        for sln in ${symlinks}; do
          [[ -h "${bin}/${sln}" ]] && {
            echo -n "Remove $(@Y3 ${sln}) $(@D9 '->') "
            echo "$(@G3 "$(readlink -m "${bin}/${sln}")")"
            rm -f "${bin}/${sln}"
          }
        done
        return
        ;;
      cherry-pick)
        @zeta:3rd:update-symlink nvim "nvim/bin/nvim"
        @zeta:3rd:update-symlink ccache "ccache/ccache"
        @zeta:3rd:update-symlink cppcheck "cppcheck/bin/cppcheck"
        # Graph-Easy ASCII Art Graphic
        # https://metacpan.org/pod/Graph::Easy
        # https://github.com/ironcamel/Graph-Easy
        # 方式一 sudo apt install libgraph-easy-perl
        # 方式二 下载压缩包, 解压缩，设置 PATH 路径
        @zeta:3rd:update-symlink graph-easy "graph-easy/bin/graph-easy"

        @zeta:3rd:update-symlink ruby "rubygems/bin"
        return
        ;;
    esac
  }

  local app version _PKGS_=(
    go  cmake  java  nodejs
  )
  [[ $# -eq 0 || $# -ne 2 ]] && {
    echo
    echo -e "-> $(@C3 switch-to) $(@R3 'os-default')"
    echo -e "-> $(@C3 switch-to) $(@R3 'cherry-pick')"
    echo
    for app in ${_PKGS_[@]}; do
      for version in $(@zeta:3rd:get-versions ${app}); do
        echo -e "-> $(@C3 switch-to) $(@G3 ${app}) $(@Y3 ${version})"
      done
      echo
    done
    return
  }

  case "$1" in
    go)
      @zeta:3rd:switch-to go "$2" go gofmt
      export GOROOT="${ZETA_DIR}/3rd/vendor/$1/$2"
      ;;
    cmake)
      @zeta:3rd:switch-to cmake "$2" cmake ccmake cpack ctest cmake-gui
      ;;
    java)
      @zeta:3rd:switch-to java "$2" jdk # java/$2/bin
      ;;
    nodejs)
      @zeta:3rd:switch-to nodejs "$2" js # nodejs/$2/bin
      export NODE_PATH="${ZETA_DIR}/3rd/vendor/$1/$2/lib/node_modules"
      ;;
    *)
      echo -e "=> no $(@R3 $1) application found"
      return 2
      ;;
  esac
}

if [[ -n "${ZSH_VERSION:-}" ]]; then
  function @zeta:comp:switch-to() {
    local -A opt_args
    local context state state_descr line

    function @zeta:once±top-cmds() {
      local -a apps=(
        os-default  cherry-pick
        go  cmake  java  nodejs
      )
      _describe 'command' apps
    }

    _arguments ':app:@zeta:once±top-cmds' ':version:->todo'
    if [[ "todo" == "${state[1]}" ]]; then
      local -a verlist
      verlist=( $(@zeta:3rd:get-versions ${line[1]}) )
      _describe 'command' verlist
    fi

    unset -f @zeta:once±top-cmds
  }
  compdef @zeta:comp:switch-to switch-to
elif [[ -n "${BASH_VERSION:-}" ]]; then
  function @zeta:comp:switch-to() {
    local -a apps=(
      os-default  cherry-pick
      go  cmake  java  nodejs
    )
    if [[ "switch-to" == "$3" ]]; then
      COMPREPLY=($(compgen -W "${apps[*]}" -- "$2"))
    else
      COMPREPLY=($(compgen -W "$(@zeta:3rd:get-versions "$3")" -- "$2"))
    fi
  }
  complete -o nosort -F @zeta:comp:switch-to switch-to
fi
