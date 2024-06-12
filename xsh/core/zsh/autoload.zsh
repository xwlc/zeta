# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charlie WONG <charlie-wong@outlook.com>
# Created By: Charlie WONG 2023-04-08T13:47:32+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# NOTE 默认补全脚本位置
# - /usr/share/zsh/*
# - /usr/local/share/zsh/site-functions/*

if [[ -d  "${ZETA_DIR}/3rd/bin/comps/zsh" ]]; then
  fpath=( "${ZETA_DIR}/3rd/bin/comps/zsh" ${fpath[@]} )
fi

# autoload -Uz hello
# -U  加载文件时禁用别名  -X 立即加载并执行
# -k  KSH 风格: 首次加载  执行 hello() 函数
# -z  ZSH 风格: 首次加载不执行 hello() 函数
# hello() { autoload -X; } 效果类似于 autoload -Uk hello

for _it_ in "${ZETA_ENABLE_PLUGINS[@]}"; do
  [[ ${_it_} == lazy ]] && continue
  if [[ -f "${ZETA_DIR}/xsh/plugin/${_it_}/${_it_}" ]]; then
    autoload -Uz "${ZETA_DIR}/xsh/plugin/${_it_}/${_it_}"
  fi
done; unset -v _it_
