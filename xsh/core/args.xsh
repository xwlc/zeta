# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-10-19T20:13:29+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# 解析 Bash/Zsh 位置参数(支持长选项 & 短选项)
# => https://github.com/Anvil/bash-argsparse
# => https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html

# 解析 Shell 位置参数的候选工具
# 不推荐 /usr/bin/getopt
# Bash & Zsh 内置的 built-in 命令 getopts 无法解析长选项
# zparseopts 源码 Src/Modules/zutil.c, 模块 zmodload zsh/zutil

# 函数/脚本自定义参数初始化后加载命令补全
function @zeta:args:comp-for() {
  local _xcmd_=$1
  eval "
  if @zeta:xsh:is-zsh; then
    function @zeta:comp:args:${_xcmd_}() {
      echo comp:todo:zsh
    }
    compdef @zeta:comp:args:${_xcmd_} ${_xcmd_}
  elif @zeta:xsh:is-bash; then
    function @zeta:comp:args:${_xcmd_}() {
      echo comp:todo:bash
    }
    complete -F @zeta:comp:args:${_xcmd_} ${_xcmd_}
  fi
  "
}

# $1 全局变量前缀   $2 规范
# $3 ... 等待解析的位置参数
# 参数<规范> => 短,短|长
# 参数<规范> => 短|长,短|长
# 参数<规范> => 布尔型~, 可选值:, 必须值+
function @zeta:args:parser() {
  [[ $# -le 2 ]] && return 1
  local _xid_=$1 _spec_="$2"; shift 2
  eval "declare -ag ${_xid_}_zxParserArgsS=(S1: S2+ S3~)" # 短选项(全局变量)
  eval "declare -ag ${_xid_}_zxParserArgsL=(L1: L2+ L3~)" # 长选项(全局变量)
  eval "declare -ag ${_xid_}_zxParserArgsV=(V11 V22 V33)" # 选项值(全局变量)
}

# NOTE 解析正常 return 0 解析异常 return > 0
# 布尔型: 未启用 echo OFF   已启用 echo   ON
# 可选值: 未设置 echo  ""   已设置 echo 真实值
# 必须值: 未设置 echo  ""   已设置 echo 真实值
function @zeta:args:checker() {
  [[ $# -ne 2 && $# -ne 3 ]] && return 1
  [[ -z "$1" || (-z "$2" && -z "$3") ]] && return 2

  # $1=全局数组变量前缀  $2=短选项  $3=长选项
  local -a  _caS_  _caL_  _caV_ # 拷贝选项数组
  local _xid_=$1 _xoS_=$2 _xoL_=$3 _ok_=0 _xval_

  _xval_=${_xid_}_zxParserArgsS; _caS_=( $(@zeta:xsh:ind-exp-ia _xval_) ); (( _ok_ += $? ))
  _xval_=${_xid_}_zxParserArgsL; _caL_=( $(@zeta:xsh:ind-exp-ia _xval_) ); (( _ok_ += $? ))
  _xval_=${_xid_}_zxParserArgsV; _caV_=( $(@zeta:xsh:ind-exp-ia _xval_) ); (( _ok_ += $? ))

  [[ ${_ok_} -ne 0 ]] && {
    @zeta:xsh:emsg "xparser internal index-array error"; return 3
  }
  # NOTE 计算数组长度 ${#ARR}    => Bash 错误, Zsh 正确
  # NOTE 计算数组长度 ${#ARR[@]} => Bash 正确, Zsh 正确
  [[ ${#_caS_[@]} != ${#_caL_[@]} || ${#_caL_[@]} != ${#_caV_[@]} ]] && {
    @zeta:xsh:emsg "xparser internal index-array error"; return 4
  }
  # echo "S[${_caS_[@]}], L[${_caL_[@]}], V[${_caV_[@]}]"

  local last1bS  last1bL  typebyte # 检测最后字节是否相等
  # X1=2; X2=5; for XV in {$X1..$X2..1};    do echo $XV; done # 仅对 Zsh 有效
  # X1=2; X2=5; for XV in $(seq $X1 1 $X2); do echo $XV; done # Zsh/Bash 有效
  local isvalid=0 _idxS_ _idxL_ _idx_=0; [[ -n "${ZSH_VERSION:-}" ]] && _idx_=1
  [[ -n "${_xoS_}" ]] && { # Bash 索引从 0 开始, Zsh 索引从 1 开始
    for _idx_ in $(seq ${_idx_} 1 ${#_caS_[@]}); do
      _xval_=${_caS_[${_idx_}]}
      # echo "S: IDX=[${_idx_}], VAL=[${_xval_}]"
      [[ "${_xoS_}" == "${_xval_}" ]] && { isvalid=1; break; }
    done
    if (( isvalid != 1 )); then
      @zeta:xsh:emsg "xparser unknown short opt ${_xoS_}"; return 5
    fi
    (( _idxS_ = _idx_ )) # 重置(为后续可能的<长选项>检测做准备)
    isvalid=0; _idx_=0; [[ -n "${ZSH_VERSION:-}" ]] && _idx_=1
    last1bS=$(builtin printf "${_xoS_}" | tail -c 1); typebyte=${last1bS}
  }

  [[ -n "${_xoL_}" ]] && {
    for _idx_ in $(seq ${_idx_} 1 ${#_caL_[@]}); do
      _xval_=${_caL_[${_idx_}]}
      # echo "L: IDX=[${_idx_}], VAL=[${_xval_}]"
      [[ "${_xoL_}" == "${_xval_}" ]] && { isvalid=1; break; }
    done
    if (( isvalid != 1 )); then
      @zeta:xsh:emsg "xparser unknown long opt ${_xoL_}"; return 6
    fi
    last1bL=$(builtin printf "${_xoL_}" | tail -c 1)
    (( _idxL_ = _idx_ )); typebyte=${last1bL}
  }

  [[ -n "${_xoS_}" && -n "${_xoL_}" ]] && {
    if (( _idxS_ != _idxL_ )); then
      @zeta:xsh:emsg "xparser internal index-array error"; return 7
    fi

    if [[ "${last1bS}" != "${last1bL}" ]]; then
      @zeta:xsh:emsg "xparser last-byte not match for ${_xoS_} and ${_xoL_}"
      return 8
    fi
  }

  # 特殊字符占位符号还原
  _xval_="${_caV_[${_idx_}]}"
  _xval_="$(@zeta:util:space-resets   "${_xval_}")" # 空格 ␟
  _xval_="$(@zeta:util:tab-resets     "${_xval_}")" # 制表 ␞
  _xval_="$(@zeta:util:newline-resets "${_xval_}")" # 换行 ␝

  # echo "xS[${last1bS}] xL[${last1bL}] xF[${typebyte}] xV=[${_xval_}]"
  case "${typebyte}" in
    ':') ;; # 可选 :    必须 +    开关 ~
    '+') [[ -z "${_xval_}" ]] && return 1 ;;
    '~') _xval_=ON; [[ -z "${_xval_}" ]] && _xval_=OFF ;;
  esac

  builtin printf "${_xval_}"
}
