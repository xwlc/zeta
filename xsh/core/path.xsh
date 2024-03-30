# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-10-28T17:18:49+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# 修改 PATH, 不重复添加, 不存在则跳过, 添加到开头
function path-head-add() {
  [[ $# != 1 || ! -d "$1" ]] && return 1
  local _path_
  for _path_ in $(echo "${PATH}" | sed 's/:/\t/g'); do
    [[ "${_path_}" == "$1" ]] && return
  done
  export PATH="$1:${PATH}"
}

function path-head-del() {
  local _PATH_
  _PATH_="$(echo "${PATH}" | cut -d: -f2-)"
  [[ $? -eq 0 ]] && export PATH="${_PATH_}"
}

# 修改 PATH, 不重复添加, 不存在则跳过, 添加到最后
function path-tail-add() {
  [[ $# != 1 || ! -d "$1" ]] && return 1
  local _path_
  for _path_ in $(echo "${PATH}" | sed 's/:/\t/g'); do
    [[ "${_path_}" == "$1" ]] && return
  done
  export PATH="${PATH}:$1"
}

function path-tail-del() {
  local nolast  _PATH_  lcnt
  lcnt=$(echo "${PATH}" | sed 's/:/\n/g' | wc -l)
  [[ $? -ne 0 ]] && return 2
  (( nolast = ${lcnt} - 1 ))
  _PATH_="$(echo "${PATH}" | cut -d: -f1-${nolast})"
  [[ $? -eq 0 ]] && export PATH="${_PATH_}"
}

# 按 Index 删除
function path-del-at() {
  local _path_  idx=1
  [[ $# -ne 1 ]] && {
    echo
    echo -e "$(@D9 Index)\t$(@D9 Value)"
    for _path_ in $(echo "${PATH}" | sed 's/:/\n/g'); do
      echo -e "$(@G3 ${idx})\t$(@Y3 ${_path_})"
      (( idx++ ))
    done
    echo
    return
  }

  ! @zeta:util:is-decnum "$1" && return 1
  [[ $1 -eq 0 || $1 -eq 1 ]] &&  { path-head-del; return; }

  local max _PATH_
  max=$(echo "${PATH}" | sed 's/:/\n/g' | wc -l)
  [[ $? -ne 0 ]] && return 2
  [[ $1 -ge ${max} ]] && { path-tail-del; return; }

  for _path_ in $(echo "${PATH}" | sed 's/:/\t/g'); do
    if [[ ${idx} -ne $1 ]]; then
      if [[ -z "${_PATH_}" ]]; then
        _PATH_="${_path_}"
      else
        _PATH_="${_PATH_}:${_path_}"
      fi
    fi
    (( idx++ ))
  done

  export PATH="${_PATH_}"
}

# clean up PATH, remove the ones which has nothing
function @zeta:once±clean-path() {
  # NOTE `path` is special, space split list for zsh
  local _path_ _PATH_="${PATH// /␟}" # 保持可能的空格
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    _PATH_=( ${=_PATH_//:/ } ) # 强制进行字符分隔, IFS
  else
    _PATH_=( ${_PATH_//:/ } ) # 默认自动进行字符分隔, IFS
  fi

  # https://www.freedesktop.org/wiki/Software/systemd/TheCaseForTheUsrMerge
  unset -v PATH; export PATH="/usr/sbin:/usr/bin"

  _path_="/usr/local/bin" # 仅当路径存在且包含可执行文件时添加
  [[ -d "${_path_}" && -n "$(/usr/bin/ls "${_path_}")" ]] && {
    PATH="${_path_}:${PATH}"
  }

  _path_="/usr/local/sbin"
  [[ -d "${_path_}" && -n "$(/usr/bin/ls "${_path_}")" ]] && {
    PATH="${_path_}:${PATH}"
  }

  _path_="/snap/bin"
  [[ -d "${_path_}" && -n "$(/usr/bin/ls "${_path_}")" ]] && {
    PATH="${_path_}:${PATH}"
  }

  _path_="/usr/local/games"
  [[ -d "${_path_}" && -n "$(/usr/bin/ls "${_path_}")" ]] && {
    PATH="${PATH}:${_path_}"
  }

  _path_="/usr/games"
  [[ -d "${_path_}" && -n "$(/usr/bin/ls "${_path_}")" ]] && {
    PATH="${PATH}:${_path_}"
  }

  # NOTE 调用 SHELL 外程序执行速度较慢
  # => $(echo "${PATH}" | sed 's/:/\t/g')
  for _path_ in "${_PATH_[@]}"; do
    #echo -e "$(ls "${_path_}" | wc -l)\t=> ${_path_}"
    [[ "${_path_}" == /bin ]] && continue
    [[ "${_path_}" == /sbin ]] && continue
    [[ "${_path_}" == /usr/* ]] && continue
    [[ "${_path_}" == /snap/bin ]] && continue

    [[ -d "${_path_}" && -n "$(/usr/bin/ls "${_path_}")" ]] && {
      PATH="${_path_}:${PATH}"
    }
  done

  export PATH="${PATH//␟/ }"
}

@zeta:once±clean-path
unset -f @zeta:once±clean-path
