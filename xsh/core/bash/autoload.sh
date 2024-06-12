# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charlie WONG <charlie-wong@outlook.com>
# Created By: Charlie WONG 2023-12-22T21:04:48+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# https://superuser.com/questions/288714
# https://zhuanlan.zhihu.com/p/464117825
# Bash 源码 examples/functions/autoload.v4
#
# NOTE How To Use, for example, "hello" plugin
# -> `FPATH` is the root to find plugins
# -> <hello> directory should be found in FPATH, like `${FPATH}/hello`
# -> "hello" plugin entry point should be `${FPATH}/hello/hello`
# -> The next is just `source ${FPATH}/hello/hello`
#    "hello/hello" take over all things, like completion setup
#
# - 输入部分命令行名,       一次 Tab 按键, 执行插件名补全
# - 输入完整命令行名, 空格, 一次 Tab 按键, 先加载后触发补全

# 冒号分隔的插件名列表
if [[ -z "${FPATH}" ]]; then
  FPATH="${ZETA_DIR}/xsh/plugin"
fi

function @zeta:auto:loader() {
  # no plugin enabled for autoload
  [[ ${#ZETA_PLUGINS[@]} -eq 0 ]] && return 3

  local -a loadable
  loadable=( $(compgen -W "${ZETA_PLUGINS[*]}" -- "$1") )
  [[ ${#loadable[@]} -eq 0 ]] && return 2 # no match found

  local plg="${loadable[0]}"
  if [[ ${#loadable[@]} -gt 1 || "$1" != "${plg}" ]]; then
    # - more then one found, show candidates
    # - if not exactly match, show completion
    COMPREPLY=( "${loadable[@]}" )
    return 1 # need to pick one, not enough info
  fi

  # 默认字符分隔(IFS), 保持可能的空格
  local _fpath_  copy="${FPATH// /␟}"
  for _fpath_ in ${copy//:/ }; do
    _fpath_="${_fpath_//␟/ }"
    if [[ -f "${_fpath_}/${plg}/${plg}" ]]; then
      source "${_fpath_}/${plg}/${plg}"
      return 0 # return and retry
    fi
  done

  return 4 # plugin is missing
}

# See Bash Repo Source File => pcomplete.h and builtins/complete.def
# NOTE Bash Hardcode Value: _EmptycmD_, _DefaultCmD_, _InitialWorD_
# If `complete` has one of the three value above as the command to
# complete, then the final result is
# -> _EmptycmD_    is replaced by -E
# -> _DefaultCmD_  is replaced by -D
# -> _InitialWorD_ is replaced by -I

# NOTE bash-complete will use `_minimal` as the fallback completion
# function for cmds that do not found related complete specification
# To verify this, on the runtime use `complete -p | grep minimal` to
# see the dynamic binging to `_minimal` for cmds no completion spec.

# NOTE Be carefually, do not make bash-complete overwrite the following
# two complete function for command and command-arguments, which is used
# to autoload plugins on the fly.

# NOTE Bash 手册 8.6 节动态补全
# 返回 124 表示当前补全需要再次尝试

# 参数补全的触发条件 `xxx <Tab>`
# 输入完整命令后, 空格, 按 Tab 键补全命令参数
function @zeta:auto:comp-args() {
  #echo; echo "comp-args cmd=[$1] word=[$2] prev=[$3]"; echo
  if [[ "$1" == "_EmptycmD_" ]]; then
    # _EmptycmD_ is emitted when just press Tab, check
    # it here to show the auto loadable plugins list
    [[ ${#ZETA_PLUGINS[@]} -ne 0 ]] && {
      local plg cnt=0 maxlen=0
      for plg in "${ZETA_PLUGINS[@]}"; do
        (( ${#plg} > maxlen )) && maxlen=${#plg}
      done
      (( maxlen += 2 ))
      for plg in "${ZETA_PLUGINS[@]}"; do
        # left justify, minimal width 15-chars
        builtin printf "%-${maxlen}s" "${plg}"
        (( cnt++, cnt % 8 == 0 )) && echo
      done
      (( cnt % 8 != 0 )) && echo
    }
    return
  elif ! compgen -c "$1" >& /dev/null; then
    # do not has command, try auotload plugins
    @zeta:auto:loader "${1:-}"
    case $? in
      0) return 124 ;;
      1) return  0  ;;
    esac
  fi

  # bash-completion for command arguments complete
  type -t _completion_loader >& /dev/null && {
    _completion_loader "$1" "$2" "$3" && return 124
  }
}

# 命令补全的触发条件 `xxx<Tab>`
# 输入部分命令然后按 Tab 键(命令和Tab按键之间无空格)
function @zeta:auto:comp-cmds() {
  if [[ "$1" == "_InitialWorD_" && -n "$2" && "$2" == "$3" ]]; then
    # 尝试命令补全: alias, shell function, extrnal commands
    COMPREPLY=( $(compgen -c "$2") )
    [[ $? -eq 0 ]] && return # found cmd candidates
    # Try find the plugin and load it if possible
    @zeta:auto:loader "${2:-}"
    case $? in
      0) return 124 ;;
      1) return  0  ;;
    esac
  fi
}

complete -F @zeta:auto:comp-args -D
complete -F @zeta:auto:comp-cmds -I
