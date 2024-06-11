#!/usr/bin/bash

# 检查 3rd/bin/* 应用是否有新版本

if [[ "$0" == "has-new-ver.sh" ]]; then
  THIS_DIR="${PWD}"
else
  THIS_DIR="$(realpath "${0%/*}")"
fi

source "${THIS_DIR}/../xsh/colors.xsh"
function has-cmd() { command -v "$1" > /dev/null; }
function no-cmd() { ! command -v "$1" > /dev/null; }

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
function check-version/ack() {
  no-cmd ack && return
  local new_version="$(github-latest-tag-of beyondgrep/ack3)"
  local old_version=$(ack --version | head -1 | cut -d' ' -f2)
  print-version-info ack "${old_version}" "${new_version}"
}

# https://gitlab.com/saalen/astyle
function check-version/astyle() {
  no-cmd astyle && return
  local old_version=$(astyle --version | cut -d' ' -f4)
  local noteHTML=https://astyle.sourceforge.net/notes.html
  local new_version=$(curl --silent ${noteHTML} | head -17 | tail -1)
  new_version="${new_version#*<h3>}" # 删除开头
  new_version=$(echo "${new_version}" | cut -d' ' -f3)
  print-version-info astyle "${old_version}" "${new_version}"
}

# https://github.com/ccache/ccache
function check-version/ccache() {
  no-cmd ccache && return
  local new_version="$(github-latest-release-of ccache/ccache)"
  local old_version=$(ccache --version | head -1 | cut -d' ' -f3)
  print-version-info ccache "v${old_version}" "${new_version}"
}

# https://github.com/junegunn/fzf
function check-version/fzf() {
  no-cmd fzf && return
  local new_version="$(github-latest-release-of junegunn/fzf)"
  local old_version=$(fzf --version | cut -d' ' -f1)
  print-version-info fzf "${old_version}" "${new_version}"
}

# https://github.com/sharkdp/hexyl
function check-version/hexyl() {
  no-cmd hexyl && return
  local new_version="$(github-latest-release-of sharkdp/hexyl)"
  local old_version=$(hexyl --version | cut -d' ' -f2)
  print-version-info hexyl "v${old_version}" "${new_version}"
}

# https://github.com/gohugoio/hugo    扩展版
# https://www.newbe.pro/Mirrors/Mirrors-Hugo
function check-version/hugo() {
  no-cmd hugo && return
  local new_version="$(github-latest-release-of gohugoio/hugo)"
  local old_version=$(hugo version | cut -d'-' -f1 | cut -d' ' -f2)
  print-version-info hugo "${old_version}" "${new_version}"
}

# https://github.com/Tomas-M/iotop
function check-version/iotop() {
  no-cmd iotop && return
  local new_version="$(github-latest-release-of Tomas-M/iotop)"
  local old_version=$(iotop --version | cut -d' ' -f2)
  print-version-info iotop "v${old_version}" "${new_version}"
}

# https://github.com/jesseduffield/lazygit
function check-version/lazygit() {
  no-cmd lazygit && return
  local new_version="$(github-latest-release-of jesseduffield/lazygit)"
  local old_version=$(lazygit --version | cut -d',' -f4 | cut -d'=' -f2)
  print-version-info lazygit "v${old_version}" "${new_version}"
}

# https://www.nxtrace.org/downloads
# https://github.com/nxtrace/NTrace-core
function check-version/nxtrace() {
  no-cmd nxtrace && return
  local new_version="$(github-latest-release-of nxtrace/NTrace-core)"
  local old_version=$(nxtrace --version | head -1 | cut -d' ' -f2)
  print-version-info nxtrace "${old_version}" "${new_version}"
}

# https://github.com/ninja-build/ninja
function check-version/ninja() {
  no-cmd ninja && return
  local new_version="$(github-latest-release-of ninja-build/ninja)"
  local old_version=$(ninja --version)
  print-version-info ninja "v${old_version}" "${new_version}"
}

# https://github.com/Syllo/nvtop
function check-version/nvtop() {
  no-cmd nvtop && return
  local new_version="$(github-latest-release-of Syllo/nvtop)"
  local old_version=$(nvtop --version | cut -d' ' -f3)
  print-version-info nvtop "${old_version}" "${new_version}"
}

# https://htop.dev
# https://github.com/htop-dev/htop
function check-version/htop() {
  no-cmd htop && return
  local new_version="$(github-latest-release-of htop-dev/htop)"
  local old_version=$(htop --version | cut -d' ' -f2)
  print-version-info htop "${old_version}" "${new_version}"
}

# https://github.com/noborus/ov
function check-version/ov() {
  no-cmd ov && return
  local new_version="$(github-latest-release-of noborus/ov)"
  local old_version=$(ov --version | cut -d' ' -f3)
  print-version-info ov "v${old_version}" "${new_version}"
}

# https://github.com/Old-Man-Programmer/tree
# https://oldmanprogrammer.net/source.php?dir=projects/tree
function check-version/tree() {
  no-cmd tree && return
  local new_version="$(github-latest-tag-of Old-Man-Programmer/tree)"
  local old_version=$(tree --version | cut -d' ' -f2)
  print-version-info tree "${old_version}" "v${new_version}"
}

# https://github.com/ymattw/ydiff

check-version/hugo

check-version/ov
check-version/ack
check-version/fzf
check-version/tree
check-version/hexyl
check-version/lazygit

check-version/ninja
check-version/astyle
check-version/ccache

check-version/htop
check-version/nvtop
check-version/iotop
check-version/nxtrace
