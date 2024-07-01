#!/usr/bin/bash
# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2024 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2024-05-26T00:01:02+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# ${0%/*}  仅删除 $0 结尾文件名(匹配最短)
# ${0##*/} 仅保留 $0 结尾文件名(匹配最长)
THIS_AFP="$(realpath "${0}")"        # 当前文件绝对路径(含名)
THIS_FNO="$(basename "${THIS_AFP}")" # 仅包含当前文件的文件名
THIS_DIR="$(dirname  "${THIS_AFP}")" # 当前文件所在的绝对路径

ZETA_DIR="$(realpath "${THIS_DIR}/..")"
source "${ZETA_DIR}/xsh/colors.xsh"

function is-arch()    { false; }
function is-ubuntu()  { false; }

function has-cmd() {  command -v "$1" > /dev/null; }
function no-cmd() { ! command -v "$1" > /dev/null; }

if [[ "$(lsb_release -is)" == 'Ubuntu' ]]; then
  function is-ubuntu() { true; }
fi

if ! is-ubuntu && ! is-arch; then
  exit 1
fi

function tree-like-status() {
  local xDIR="$2" orgSRC="$3" dstSYS="$4" MAX=$5 hashZ hashS
  [[ ! -f "${ZETA_DIR}/etc/${xDIR}/${orgSRC}" ]] && return

  hashZ=$(md5sum "${ZETA_DIR}/etc/${xDIR}/${orgSRC}" | cut -d' ' -f1)
  [[ -f "${dstSYS}" ]] && hashS=$(md5sum "${dstSYS}" | cut -d' ' -f1)

  local symbol
  case "$1" in
    BEG) symbol="  ┌─ " ;;
    MID) symbol="  ├─ " ;;
    END) symbol="  └─ " ;;
    ONE) symbol="  ┹─ " ;;
      *) return ;;
  esac

  [[ -z "${MAX}" ]] && MAX=35

  if [[ ! -f "${dstSYS}" ]]; then
    printf "${symbol}$(@R3 diff) $(@Y3 "%-${MAX}s") -> $(@D9 ${dstSYS})\n" "${orgSRC}"
  elif [[ "${hashZ}" == "${hashS}" ]]; then
    printf "${symbol}$(@G3 sync) $(@Y3 "%-${MAX}s") -> $(@C3 ${dstSYS})\n" "${orgSRC}"
  else
    printf "${symbol}$(@R3 diff) $(@Y3 "%-${MAX}s") -> $(@C3 ${dstSYS})\n" "${orgSRC}"
  fi
}

function etc-sys-apt() {
  ! is-ubuntu && return
  echo "$(@D9 ${ZETA_DIR}/etc/)$(@B3 sys/apt)"

  local srcZ="$(lsb_release -sr)-$(lsb_release -sc)"
  local srcR="${ZETA_DIR}/etc/sys/apt/${srcZ}"
  [[ ! -d "${srcR}" ]] && return

  local maxcnt count orgSRC dstSYS

  maxcnt=$(ls "${srcR}" | wc -l); count=0
  for it in $(ls "${srcR}"); do
    orgSRC="${srcR}/${it}"
    dstSYS="$(cat "${orgSRC}" | head -1 | cut -d' ' -f2)"
    if (( count++, count == maxcnt )); then
        tree-like-status END "sys/apt" "${srcZ}/${it}" "${dstSYS}"
    else
      if (( count == 1 )); then
        tree-like-status BEG "sys/apt" "${srcZ}/${it}" "${dstSYS}"
      else
        tree-like-status MID "sys/apt" "${srcZ}/${it}" "${dstSYS}"
      fi
    fi
  done
  echo
  srcZ="gpg-keyrings"
  srcR="${ZETA_DIR}/etc/sys/apt/${srcZ}"
  maxcnt=$(ls "${srcR}" | wc -l); count=0
  for it in $(ls "${srcR}"); do
    orgSRC="${srcR}/${it}"
    dstSYS="/etc/apt/keyrings/${it}"
    if (( count++, count == maxcnt )); then
        tree-like-status END "sys/apt" "${srcZ}/${it}" "${dstSYS}"
    else
      if (( count == 1 )); then
        tree-like-status BEG "sys/apt" "${srcZ}/${it}" "${dstSYS}"
      else
        tree-like-status MID "sys/apt" "${srcZ}/${it}" "${dstSYS}"
      fi
    fi
  done
  echo
}

function etc-sys-fstab() {
  if ! is-ubuntu && ! is-arch; then
    return
  fi

  local srcZ="ubuntu"
  if is-arch; then
    srcZ="arch"
  fi

  echo "$(@D9 ${ZETA_DIR}/etc/)$(@B3 sys/fstab)"
  tree-like-status ONE "sys/fstab" "${srcZ}" "/etc/fstab"
  echo
}

function etc-sys-hosts() {
  echo "$(@D9 ${ZETA_DIR}/etc/)$(@B3 sys/hosts)"
  tree-like-status ONE "sys/hosts" hosts "/etc/hosts"
  echo
}

function ect-sys-files() {
  echo "$(@D9 ${ZETA_DIR}/etc/)$(@B3 'sys/*.*')"
  local orgSRC dstSYS

  orgSRC="fcitx5.punc"
  dstSYS="/usr/share/fcitx5/punctuation/punc.mb.zh_CN"
  tree-like-status BEG "sys" "${orgSRC}" "${dstSYS}"

  orgSRC="journald.conf"
  dstSYS="/etc/systemd/journald.conf"
  tree-like-status MID "sys" "${orgSRC}" "${dstSYS}"

  orgSRC="sysctl.conf"
  dstSYS="/etc/sysctl.conf"
  tree-like-status MID "sys" "${orgSRC}" "${dstSYS}"

  orgSRC="updatedb.conf"
  dstSYS="/etc/updatedb.conf"
  tree-like-status END "sys" "${orgSRC}" "${dstSYS}"
  echo
}

function show-home-symlink() {
  local symlink="$1" linksrc

  if [[ -h "${HOME}/${symlink}" ]]; then
    linksrc="$(readlink "${HOME}/${symlink}")"
    printf "$(@D9 "${HOME}/")$(@G3 ${symlink}) -> $(@Y3 "${linksrc}")\n"
  else
    echo "$(@D9 "${HOME}/")$(@D9 ${symlink})"
  fi
}

etc-sys-apt
etc-sys-fstab
etc-sys-hosts
ect-sys-files

show-home-symlink ".ssh"
show-home-symlink ".gnupg"
show-home-symlink ".npmrc"
show-home-symlink ".gitconfig"
show-home-symlink ".hidden"
show-home-symlink ".inputrc"
echo
show-home-symlink ".config/git"
show-home-symlink ".config/nvim"
show-home-symlink ".config/ov/config.yaml"
show-home-symlink ".config/Code/User/settings.json"
echo
show-home-symlink ".local/share/icons"
show-home-symlink ".local/share/fonts"
show-home-symlink ".local/share/konsole"
show-home-symlink ".local/share/applications"
