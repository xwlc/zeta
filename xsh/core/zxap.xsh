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

# $1 非空则<启用命令自动补全功能>
#    非空有效值 => 字母(大小写), 数字,下划线
# $2 规范 -> 示例 "+S1,:S2|L2,~|L3"
#    参数<规范> => ~短,+短|长,:|长 -> +必需  :可选  ~开关
# $3 ... 等待解析的位置参数
#
# - return 0 正常, 其它值则错误
function @zeta:zxap:parser() {
  [[ $# -eq 0 || $# -eq 1 || -z "$1" ]] && return 1
  local _xSpec_="$1"; shift 1; local _xMAX_=$#
  local _IdxV_  _xNxtV_  __zIDX__=0  _idx_
  local _oS_ _oL_ _oI_  _val_ _xit_  _bF1_ _bF2_ _rob_

  ! declare -p ZXAP__InitSpec > /dev/null 2>&1 && {
    declare -g ZXAP__InitSpec=0
    declare -ga ZXAP__{S,L}__ # 短选项(S) 长选项(L)
    if ! declare -p ZXAP_IDX > /dev/null 2>&1; then
      declare -g ZXAP_{IDX=0,NXT=1,ERR,ARG,VAL}
    fi
  }

  function zxap±done() {
    unset -v ZXAP__InitSpec
    unset -v ZXAP__{S,L}__
    unset -v ZXAP_{IDX,NXT,ERR,ARG,VAL}
    [[ $# -ge 2 ]] && { # Bash/Zsh 预定义变量 LINENO 更具可读性
      # NOTE Bash 的 LINENO 值忽略纯注释(空白)行, 行号 22 函数定义
      local lineNo=$1 xLN; shift; (( lineNo += 22 ))
      xLN="LN=${lineNo} "; @zeta:xsh:wmsg -T zxap "${xLN}$@"
    }; unset -f zxap±done
  }; (( ZXAP_IDX = ZXAP_NXT, ZXAP_NXT++ ))

  # NOTE Zsh 数组索引 1 开始, Bash 数组索引 0 开始
  [[ -n "${ZSH_VERSION:-}" ]] && __zIDX__=1

  ##################
  # 参数<规范>解析 #
  ###################
  (( ZXAP__InitSpec == 0 )) && {
    _xSpec_="$(builtin printf "${_xSpec_}" | sed 's/,/\t/g')"
    if [[ -z "${_xSpec_}" ]]; then
      zxap±done ${LINENO} "invalid empty args-spec"; return 1;
    fi

    if [[ -n "${ZSH_VERSION:-}" ]]; then
      @zeta:xsh:opt-if-off-then-on shwordsplit; [[ $? -ne 0 ]] && {
        zxap±done ${LINENO} "try enable $(@G3 shwordsplit) failed!"; return 1
      }
    fi

    (( _idx_ = __zIDX__ )); for _xit_ in ${_xSpec_}; do
      _rob_="${_xit_:0:1}" # 第 1 个字节表示类型
      case "${_rob_}" in
        "+") _val_="${_xit_:1}" ;; # 必须
        ":") _val_="${_xit_:1}" ;; # 可选
        "~") _val_="${_xit_:1}" ;; # 开关
          *) _val_="${_xit_}"; _rob_="~" ;;
      esac
      # echo "调试 [${_rob_}] -> [${_xit_}]"

      # NOTE 删除<开头>最短匹配符 #    删除<结尾>最短匹配符 %
      _oS_="${_val_%|*}"; _oL_="${_val_#*|}"

      if [[ -z "${_oS_}" && -z "${_oL_}" ]]; then
        zxap±done ${LINENO} "invalid args-spec $(@R3 ${_xit_})"; return 1
      elif [[ "${_oS_}" == "${_oL_}" && "${_oS_}" == "${_val_}" ]]; then
        _oL_="" # 规范 => +短选项   :短选项   ~短选项
      elif [[ "${_val_:0:1}" == "|" && "${_oL_}" == "${_val_:1}" ]]; then
        _oS_="" # 规范 => +|长选项  :|长选项  ~|长选项
      fi
      # 规范 => +短选项|长选项  :短选项|长选项  ~短选项|长选项
      [[ -n "${_oL_}" && "${_oS_}" != "${_val_%|${_oL_}}" ]] && {
        zxap±done ${LINENO} "invalid args-spec $(@R3 ${_xit_})"; return 1
      }
      [[ -n "${_oS_}" && "${_oL_}" != "${_val_#${_oS_}|}" ]] && {
        if [[ "${_oS_}" != "${_val_}" ]]; then
          zxap±done ${LINENO} "invalid args-spec $(@R3 ${_xit_})"; return 1
        fi
      }
      # echo "调试 [${_rob_}] -> S[${_oS_}] L[${_oL_}]"; echo

      # ␜ 数组内容有效性检测字符(Magic Byte)
      ZXAP__S__[${_idx_}]="␜${_rob_}${_oS_}"
      ZXAP__L__[${_idx_}]="␜${_rob_}${_oL_}"; (( _idx_++ ))
    done; ZXAP__InitSpec=1 # 参数规范解析初始化完成

    # echo "调试 ZXAP__S__ => [${ZXAP__S__[@]}]"
    # echo "调试 ZXAP__L__ => [${ZXAP__L__[@]}]"

    if [[ -n "${ZETA_XSH_OPT_shwordsplit:-}" ]]; then
      eval   "${ZETA_XSH_OPT_shwordsplit}"
    fi
  }

  ######################
  # 解析扫描命令行参数 #
  ######################
  [[ ${ZXAP_IDX} -gt ${_xMAX_} || ${ZXAP_IDX} -lt 0 ]] && {
    zxap±done; return 1
  }
  [[ -n "${BASH_VERSION}" ]] && {
    eval '_IdxV_="'${!ZXAP_IDX}'"'
    if (( ZXAP_NXT <= _xMAX_ )); then
      eval '_xNxtV_="'${!ZXAP_NXT}'"'
    else
      ZXAP_NXT=-1; _xNxtV_=
    fi
  }
  [[ -n "${ZSH_VERSION}"  ]] && {
    eval '_IdxV_="'${(P)ZXAP_IDX}'"'
    if (( ZXAP_NXT <= _xMAX_ )); then
      eval '_xNxtV_="'${(P)ZXAP_NXT}'"'
    else
      ZXAP_NXT=-1; _xNxtV_=
    fi
  }

  # ZXAP_ERR 非空表示出错终止
  # ZXAP_IDX              ZXAP_NXT
  # ZXAP_ARG -> _IdxV_    ZXAP_VAL -> _xNxtV_
  ZXAP_ARG="${_IdxV_}"; ZXAP_VAL="${_xNxtV_}"
  [[ -z "${_IdxV_}" ]] && {
    zxap±done ${LINENO} "invalid empty argument"; return 1
  }

  # 获取选项字符串的第 1 个字节和第 2 个字节
  _bF1_="${_IdxV_:0:1}"; _bF2_="${_IdxV_:1:1}"
  # echo "调试 AB1=[${_bF1_}] AB2=[${_bF2_}]"
  [[ "${_bF1_}" != - ]] && {
    zxap±done ${LINENO} "argument must begin with dash, but got $(@R3 ${_bF1_})"
    return 1
  }
  if [[ "${_bF2_}" == - ]]; then
    _IdxV_="${_IdxV_:2}" # 长选项 --XXX
    [[ -z "${_IdxV_}" ]] && {
      zxap±done ${LINENO} "invalid empty long argument"; return 1
    }
    (( _idx_ = __zIDX__ )); while (( _idx_ < ${#ZXAP__L__[@]} )); do
      _val_="${ZXAP__L__[${_idx_}]}"
      [[ "${_val_:2}" == "${_IdxV_}" ]] && {
        (( _oI_ = _idx_ )); _rob_="${_val_:1:1}"; break
      }; (( _idx_++ ))
    done
  else
    _IdxV_="${_IdxV_:1}" # 短选项 -XXX
    [[ -z "${_IdxV_}" ]] && {
      zxap±done ${LINENO} "invalid empty short argument"; return 1
    }
    (( _idx_ = __zIDX__ )); while (( _idx_ < ${#ZXAP__S__[@]} )); do
      _val_="${ZXAP__S__[${_idx_}]}"
      [[ "${_val_:2}" == "${_IdxV_}" ]] && {
        (( _oI_ = _idx_ )); _rob_="${_val_:1:1}"; break
      }; (( _idx_++ ))
    done
  fi
  [[ -z "${_oI_}" ]] && { ZXAP_ERR="Unknown option ${_IdxV_}"; return; }

  ZXAP_ARG="${_IdxV_}"; ZXAP_VAL="${_xNxtV_}"
  case "${_rob_}" in
    "+") # 必须
      if [[  -z "${_xNxtV_}" || "${_xNxtV_:0:1}" == - ]]; then
        zxap±done ${LINENO} "$(@R3 ${_IdxV_}) required value"; return 1
      fi; (( ZXAP_NXT++ ))
      ;;
    ":") # 可选
      if [[ "${_xNxtV_:0:1}" == - ]]; then
        ZXAP_VAL=
      else
        (( ZXAP_NXT++ ))
      fi
      ;;
    "~") ZXAP_VAL= ;; # 开关
    *) zxap±done ${LINENO} "internal error"; return 1 ;;
  esac; # ZXAP_ERR="STOP"
}

function @zeta:zxap:sample() {
  local _opts_="+S1,:S2|L2,~|L3,S4,S5|L5,|L6,+X1|X1"
  [[ $# -eq 0 ]] && { echo "=> ${_opts_}"; return; }

  local ZXAP_{IDX=0,NXT=1,ERR,ARG,VAL}
  while @zeta:zxap:parser "${_opts_}"  "$@"; do
    printf "IDX=[%02d] ARG=[${ZXAP_ARG}] ERR=[${ZXAP_ERR}]\n" ${ZXAP_IDX}
    printf "NXT=[%02d] VAL=[${ZXAP_VAL}]\n" ${ZXAP_NXT}; echo
    [[ -n "${ZXAP_ERR}" ]] && break
  done
}
