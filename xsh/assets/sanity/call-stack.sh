#!/usr/bin/bash
# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charlie WONG <charlie-wong@outlook.com>
# Created By: Charlie WONG 2023-11-29T20:13:29+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# LINENO 表示当前行号
# NOTE 启动 Shell 后 立即执行 echo $LINENO, 则显示结果为 1
# - Shell 启动后的等待用户输入命令的行, 在当前会话中是第 1 行
# - 后续在当前会话中仅计算等命令输入的行, 即忽略任何命令的输出行

# 关于使用 PS4 和 set -x 调试/解析 Bash 补全功能
# https://unix.stackexchange.com/questions/672844
# NOTE 函数内行号或文件内绝对行号混合在一起
# => set -x 开启调试追踪, set +x 关闭调试追踪
# => PS4='+'$'\t''$LINENO'$'\t'
# => PS4='+'$'\t''[$LINENO]'$'\t''[${BASH_SOURCE[1]}]'$'\t''[${BASH_LINENO[0]}]'$'\t''[${FUNCNAME[0]}]'$'\t'

# 数组项堆栈式管理 FUNCNAME, BASH_LINENO, BASH_SOURCE
# -> 用 FS 表示 ${BASH_SOURCE[${i}+1]}
# -> 用 LN 表示 ${BASH_LINENO[${i}]}
# -> 用 FN 表示 ${FUNCNAME[${i}]}
#    函数 FN 在 FS 脚本的 LN 行被调用

# 用法: 直接放在待调试的函数中执行即可
# - 脚本中调试: 行号就是脚本文件中的绝对行号
# - 交互式会话: 行号相对会话及函数内相对行号
function call-stack() {
#echo "[${#FUNCNAME[@]}][${FUNCNAME[@]}]"
#echo "[${#BASH_LINENO[@]}][${BASH_LINENO[@]}]"
#echo "[${#BASH_SOURCE[@]}][${BASH_SOURCE[@]}]"

  local idx  fname  linen  sfile  mwidth=$1
  [[ -z "$1" || -n "${1//[0-9]/}" ]] && {
    mwidth=${BASH_SOURCE[0]#${PWD}/}
    mwidth=${#mwidth}
  }

  local XX='\e[0m' R3='\e[31m' D9='\e[90m' Y9='\e[93m'
  # 内置命令 caller 显示内容扭曲不直观!
  # for (( idx=0; idx < ${#FUNCNAME[@]}; idx++ )); do caller ${idx}; done

  # => % [Flags] [Width] [.Precision] [Modifier]Specifier
  # https://cplusplus.com/reference/cstdio/printf/
  for (( idx=0; idx < ${#FUNCNAME[@]}; idx++ )); do
    fname=${FUNCNAME[${idx}]}
    printf -v fname "%s" ${fname}
    linen=${BASH_LINENO[${idx}]}
    printf -v linen "%0.3d"  ${linen}
    if (( (idx + 1) < ${#FUNCNAME[@]} )); then
      sfile=${BASH_SOURCE[${idx}+1]#${PWD}/}
      printf -v sfile "%${mwidth}s" "${sfile}"
    else
      printf -v sfile "%${mwidth}s" " "
    fi
    echo -e "${sfile}:${R3}${linen} ${D9}invoke ${Y9}${fname}${XX}()"
  done
}
