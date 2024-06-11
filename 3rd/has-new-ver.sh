#!/usr/bin/bash

# 检查 3rd/bin/* 应用是否有新版本

if [[ "$0" == "has-new-ver.sh" ]]; then
  THIS_DIR="${PWD}"
else
  THIS_DIR="$(realpath "${0%/*}")"
fi

source "${THIS_DIR}/../xsh/colors.xsh"
function has-cmd() { command -v "$1" > /dev/null; }

if [[ -z "${GITHUB_ACCESS_TOKEN}" ]]; then
  @D9 '################################### -> '; @G9 'https://docs.github.com/en/rest'; echo
  echo "$(@D9 '#') $(@R3 'No GitHub Personal Access Token') $(@D9 '# =>') $(@Y3 GITHUB_ACCESS_TOKEN)"
  @D9 '################################### -> '; @G9 'https://github.com/settings/tokens'; echo
  exit 1
fi

ApiVersion="2022-11-28"
# https://docs.github.com/en/rest/repos/repos
# https://docs.github.com/en/rest/releases/releases

function github-latest-tag-of() {
  local OwnerRepo=$1 xdata
  # https://api.github.com/repos/拥有者/仓库名/tags
  xdata=$(curl -s -H "Accept: application/json" \
    -H "X-GitHub-Api-Version: ${ApiVersion}" \
    -H "Authorization: Bearer ${GITHUB_ACCESS_TOKEN}" \
    -L  https://api.github.com/repos/${OwnerRepo}/tags | head -3 | tail -1
  )
  [[ $? -ne 0 ]] && return
  echo "${xdata}" | sed 's/[",:]//g' | sed 's/name//' | sed 's/ //g'
}

function github-latest-release-of() {
  local OwnerRepo=$1 xdata
  # https://api.github.com/repos/拥有者/仓库名/releases
  xdata=$(curl -s -H "Accept: application/json" \
    -H "X-GitHub-Api-Version: ${ApiVersion}" \
    -H "Authorization: Bearer ${GITHUB_ACCESS_TOKEN}" \
    -L  https://api.github.com/repos/${OwnerRepo}/releases/latest | \
    head -30 | tail -1
  )
  [[ $? -ne 0 ]] && return
  echo "${xdata}" | sed 's/[",:]//g' | sed 's/name//' | sed 's/ //g'
}

function print-version-info() {
  if [[ "$2" == "$3" ]]; then
    echo "$(@B3 "$1") $(@D9 "$2")"
  else
    echo "$(@B3 "$1") $(@D9 "$2") $(@R3 '=>') $(@G3 "$3")"
  fi
}

# https://github.com/beyondgrep/ack3
function check-bin/ack() {
  if [[ -x "${THIS_DIR}/bin/ack" ]]; then
    local new_version="$(github-latest-tag-of beyondgrep/ack3)"
    local old_version=$(ack --version | head -1 | cut -d' ' -f2)
    print-version-info ack "${old_version}" "${new_version}"
  fi
}

# https://gitlab.com/saalen/astyle
function check-bin/astyle() {
  local old_version=$(astyle --version | cut -d' ' -f4)
  local noteHTML=https://astyle.sourceforge.net/notes.html
  local new_version=$(curl --silent ${noteHTML} | head -17 | tail -1)
  new_version="${new_version#*<h3>}" # 删除开头
  new_version=$(echo "${new_version}" | cut -d' ' -f3)
  print-version-info astyle "${old_version}" "${new_version}"
}

# https://github.com/ccache/ccache
function check-bin/ccache() {
  if [[ -x "${THIS_DIR}/bin/ccache" ]]; then
    local new_version="$(github-latest-release-of ccache/ccache)"
    local old_version=$(ccache --version | head -1 | cut -d' ' -f3)
    print-version-info ccache "${old_version}" "${new_version}"
  fi
}

# https://github.com/junegunn/fzf
function check-bin/fzf() {
  if [[ -x "${THIS_DIR}/bin/ccache" ]]; then
    local new_version="$(github-latest-release-of junegunn/fzf)"
    local old_version=$(fzf --version | cut -d' ' -f1)
    print-version-info fzf "${old_version}" "${new_version}"
  fi
}

# https://github.com/sharkdp/hexyl
function check-bin/hexyl() {
  if [[ -x "${THIS_DIR}/bin/ccache" ]]; then
    local new_version="$(github-latest-release-of sharkdp/hexyl)"
    local old_version=$(hexyl --version | cut -d' ' -f2)
    print-version-info hexyl "v${old_version}" "${new_version}"
  fi
}

check-bin/ack
check-bin/astyle
check-bin/ccache
check-bin/fzf
check-bin/hexyl
