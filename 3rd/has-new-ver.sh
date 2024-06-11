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
    head -28 | tail -1
  )
  [[ $? -ne 0 ]] && return
  echo "${xdata}" | sed 's/[",:]//g' | sed 's/tag_name//' | sed 's/ //g'
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
  [[ ! -x "${THIS_DIR}/bin/ack" ]] && return
  local new_version="$(github-latest-tag-of beyondgrep/ack3)"
  local old_version=$(ack --version | head -1 | cut -d' ' -f2)
  print-version-info ack "${old_version}" "${new_version}"
}

# https://gitlab.com/saalen/astyle
function check-bin/astyle() {
  [[ ! -x "${THIS_DIR}/bin/astyle" ]] && return
  local old_version=$(astyle --version | cut -d' ' -f4)
  local noteHTML=https://astyle.sourceforge.net/notes.html
  local new_version=$(curl --silent ${noteHTML} | head -17 | tail -1)
  new_version="${new_version#*<h3>}" # 删除开头
  new_version=$(echo "${new_version}" | cut -d' ' -f3)
  print-version-info astyle "${old_version}" "${new_version}"
}

# https://github.com/ccache/ccache
function check-bin/ccache() {
  [[ ! -x "${THIS_DIR}/bin/ccache" ]] && return
  local new_version="$(github-latest-release-of ccache/ccache)"
  local old_version=$(ccache --version | head -1 | cut -d' ' -f3)
  print-version-info ccache "v${old_version}" "${new_version}"
}

# https://github.com/junegunn/fzf
function check-bin/fzf() {
  [[ ! -x "${THIS_DIR}/bin/fzf" ]] && return
  local new_version="$(github-latest-release-of junegunn/fzf)"
  local old_version=$(fzf --version | cut -d' ' -f1)
  print-version-info fzf "${old_version}" "${new_version}"
}

# https://github.com/sharkdp/hexyl
function check-bin/hexyl() {
  [[ ! -x "${THIS_DIR}/bin/hexyl" ]] && return
  local new_version="$(github-latest-release-of sharkdp/hexyl)"
  local old_version=$(hexyl --version | cut -d' ' -f2)
  print-version-info hexyl "v${old_version}" "${new_version}"
}

# https://github.com/gohugoio/hugo
function check-bin/hugo() {
  [[ ! -x "${THIS_DIR}/bin/hugo" ]] && return
  local new_version="$(github-latest-release-of gohugoio/hugo)"
  local old_version=$(hugo version | cut -d'-' -f1 | cut -d' ' -f2)
  print-version-info hugo "${old_version}" "${new_version}"
}

# https://github.com/Tomas-M/iotop
function check-bin/iotop() {
  [[ ! -x "${THIS_DIR}/bin/iotop" ]] && return
  local new_version="$(github-latest-release-of Tomas-M/iotop)"
  local old_version=$(iotop --version | cut -d' ' -f2)
  print-version-info iotop "v${old_version}" "${new_version}"
}

# https://github.com/jesseduffield/lazygit
function check-bin/lazygit() {
  [[ ! -x "${THIS_DIR}/bin/lazygit" ]] && return
  local new_version="$(github-latest-release-of jesseduffield/lazygit)"
  local old_version=$(lazygit --version | cut -d',' -f4 | cut -d'=' -f2)
  print-version-info lazygit "v${old_version}" "${new_version}"
}

# https://github.com/nxtrace/NTrace-core
function check-bin/nxtrace() {
  [[ ! -x "${THIS_DIR}/bin/nxtrace" ]] && return
  local new_version="$(github-latest-release-of nxtrace/NTrace-core)"
  local old_version=$(nxtrace --version | head -1 | cut -d' ' -f2)
  print-version-info nxtrace "${old_version}" "${new_version}"
}

# https://github.com/ninja-build/ninja
function check-bin/ninja() {
  [[ ! -x "${THIS_DIR}/bin/ninja" ]] && return
  local new_version="$(github-latest-release-of ninja-build/ninja)"
  local old_version=$(ninja --version)
  print-version-info ninja "v${old_version}" "${new_version}"
}

check-bin/ack
check-bin/astyle
check-bin/ccache
check-bin/fzf
check-bin/hexyl
check-bin/hugo
check-bin/iotop
check-bin/lazygit
check-bin/ninja
check-bin/nxtrace
