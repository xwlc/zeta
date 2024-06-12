# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charlie WONG <charlie-wong@outlook.com>
# Created By: Charlie WONG 2023-04-08T13:47:32+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

function @D3() { echo -ne "\e[0;30m$*\e[0m"; } # 黑色
function @R3() { echo -ne "\e[0;31m$*\e[0m"; } # 红色
function @G3() { echo -ne "\e[0;32m$*\e[0m"; } # 绿色
function @Y3() { echo -ne "\e[0;33m$*\e[0m"; } # 黄色
function @B3() { echo -ne "\e[0;34m$*\e[0m"; } # 蓝色
function @P3() { echo -ne "\e[0;35m$*\e[0m"; } # 紫色
function @C3() { echo -ne "\e[0;36m$*\e[0m"; } # 青色
function @W3() { echo -ne "\e[0;37m$*\e[0m"; } # 白色

function @D9() { echo -ne "\e[0;90m$*\e[0m"; } # 灰色
function @R9() { echo -ne "\e[0;91m$*\e[0m"; } # 浅红
function @G9() { echo -ne "\e[0;92m$*\e[0m"; } # 浅绿
function @Y9() { echo -ne "\e[0;93m$*\e[0m"; } # 浅黄
function @B9() { echo -ne "\e[0;94m$*\e[0m"; } # 浅蓝
function @P9() { echo -ne "\e[0;95m$*\e[0m"; } # 浅紫
function @C9() { echo -ne "\e[0;96m$*\e[0m"; } # 浅青
function @W9() { echo -ne "\e[0;97m$*\e[0m"; } # 浅白

WorkShell="$(basename $(readlink /proc/$$/exe))"
function is-workshell-zsh()  { [[ "${WorkShell}" == "zsh"  ]]; }
function is-workshell-bash() { [[ "${WorkShell}" == "bash" ]]; }

echo -n "$(@D9 PID) $(@R3 $$) $(@D9 WorkShell) $(@G3 ${WorkShell})"
if is-workshell-bash; then
  BV0="$(@R3 ${BASH_VERSINFO[0]})" # Major
  BV1="$(@Y9 ${BASH_VERSINFO[1]})" # Minor
  BV2="$(@G9 ${BASH_VERSINFO[2]})" # Patch
  BBV="$(@C3 ${BASH_VERSINFO[3]})" # Build Version
  BRS="$(@P3 ${BASH_VERSINFO[4]})" # Release Status
  BMT="$(@B9 ${BASH_VERSINFO[5]})" # Machine Type
  echo " $(@D9 'v')${BV0}.${BV1}.${BV2}$(@D9 -)${BBV}$(@D9 +)${BRS}"
  echo "$(@D9 Host Machine) ${BMT}"
elif is-workshell-zsh; then
  ZV0="$(@R3 $(echo "$ZSH_VERSION" | cut -d. -f1))"
  ZV1="$(@Y9 $(echo "$ZSH_VERSION" | cut -d. -f2))"
  ZV2="$(@G9 $(echo "$ZSH_VERSION" | cut -d. -f3))"
  echo " $(@D9 'v')${ZV0}.${ZV1}.${ZV2}"
fi

# NOTE ZSH supports absolutely any string as a function
# name, because absolutely any string can be a file name

echo "=> 函数名中的特殊字符"
function :IsOk() { echo "$(@D9 01) $(@R3 ':') $(@G3 ok) $(@D9 '=>') :IsOk() -> $*"; }; :IsOk "$(@G9 Bash)" '&' "$(@Y3 Zsh)"
function -IsOk() { echo "$(@D9 02) $(@R3 '-') $(@G3 ok) $(@D9 '=>') -IsOk() -> $*"; }; -IsOk "$(@G9 Bash)" '&' "$(@Y3 Zsh)"
function +IsOk() { echo "$(@D9 03) $(@R3 '+') $(@G3 ok) $(@D9 '=>') +IsOk() -> $*"; }; +IsOk "$(@G9 Bash)" '&' "$(@Y3 Zsh)"
function @IsOk() { echo "$(@D9 04) $(@R3 '@') $(@G3 ok) $(@D9 '=>') @IsOk() -> $*"; }; @IsOk "$(@G9 Bash)" '&' "$(@Y3 Zsh)"

function ^IsOk() { echo "$(@D9 05) $(@R3 '^') $(@G3 ok) $(@D9 '=>') ^IsOk() -> $*"; }; ^IsOk "$(@G9 Bash)" '&' "$(@Y3 Zsh)"
function /IsOk() { echo "$(@D9 07) $(@R3 '/') $(@G3 ok) $(@D9 '=>') /IsOk() -> $*"; }; /IsOk "$(@G9 Bash)" '&' "$(@Y3 Zsh)"
function .IsOk() { echo "$(@D9 07) $(@R3 '.') $(@G3 ok) $(@D9 '=>') .IsOk() -> $*"; }; .IsOk "$(@G9 Bash)" '&' "$(@Y3 Zsh)"
function !IsOk() { echo "$(@D9 06) $(@R3 '!') $(@G3 ok) $(@D9 '=>') !IsOk() -> $*"; }; !IsOk "$(@G9 Bash)" '&' "$(@Y3 Zsh)"

function ±IsOk() { echo "$(@D9 03) $(@R3 '±') $(@G3 ok) $(@D9 '=>') ±IsOk() -> $*"; }; ±IsOk "$(@G9 Bash)" '&' "$(@Y3 Zsh)"
function »IsOk() { echo "$(@D9 03) $(@R3 '»') $(@G3 ok) $(@D9 '=>') »IsOk() -> $*"; }; »IsOk "$(@G9 Bash)" '&' "$(@Y3 Zsh)"

if is-workshell-bash; then
  echo
  function  ?IsOk()  { echo "$(@D9 20) $(@R3 '?') $(@G3 ok) $(@D9 '=>') ?IsOk() -> $*"; }; ?IsOk "$(@G9 Bash)"
elif is-workshell-zsh; then
  echo
  function \?IsOk()  { echo "$(@D9 20) $(@R3 '?') $(@G3 ok) $(@D9 '=>') ?IsOk() -> $*"; }; \?IsOk "$(@Y3 Zsh)"
  function '?IsOk'() { echo "$(@D9 21) $(@R3 '?') $(@G3 ok) $(@D9 '=>') ?IsOk() -> $*"; }; '?IsOk' "$(@Y3 Zsh)"
fi

if is-workshell-zsh; then
  echo
#function \#IsOk() { echo "$(@D9 XX) $(@R3 '#') $(@G3 ok) $(@D9 '=>') #IsOk()"; }; \#IsOk
  x='' cnt=50  CHARS=(
    '`'  '$'  '*'
    ','  ';'  "'"  '"'  '?'
    '#'  '~'  '%'  '&'  '\'
    '<'  '>'  '('  ')'  '['  ']'  '{'  '}'
  );
  for c in "${CHARS[@]}"; do
    function "${c}IsOk"() {
      if [[ "${c}" == '\' ]]; then x='\'; else x=''; fi
      echo -n "$(@D9 ${cnt}) $(@R3 "${x}${c}") $(@G3 ok) $(@D9 '=>') $0() -> $*"
    }
    function ${c}XY() { echo "$0($(@G3 ok))"; }
    "${c}IsOk" "$(@Y3 Zsh)$(@D9 ':') "; ${c}XY
    (( cnt++ ))
  done

  $'\0'() {
    echo "$(@G3 ok) $(@D9 '=>') function name is $(@R3 NUL) char"
  }; echo; $'\0'; echo
fi
