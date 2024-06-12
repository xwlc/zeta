# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charlie WONG <charlie-wong@outlook.com>
# Created By: Charlie WONG 2023-11-29T20:13:29+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# TODO A Guide to Zsh Completion System with Examples
# https://thevaluable.dev/zsh-completion-guide-examples
autoload -Uz compaudit  compinit  zrecompile

zstyle ':completion:*:sudo:*' command-path \
  /usr/{s,}bin  /{s,}bin  "${ZETA_DIR}/3rd/bin"

zcd_refresh=1
zcd_fpath="# Zsh fpath: ${fpath}"
zcd_rhash="# Repo Hash: ${ZETA_COMMIT:-}"
zcd_times="# Timestamp: $(date --iso-8601=seconds)"

if [[ -f "${ZSH_COMPDUMP}" ]]; then # 默认值 IFS=' '$'\t'$'\n'$'\0'
  { IFS=$'\n'; zcd_last2=( $(tail -2 "${ZSH_COMPDUMP}") ); unset IFS; }
  if [[ ${#zcd_last2[@]} -eq 2 ]]; then
    [[ "${zcd_rhash}" == "${zcd_last2[1]}" ]] && \
    [[ "${zcd_fpath}" == "${zcd_last2[2]}" ]] && zcd_refresh=0
  fi
fi

# cmd-comp metadata changed, delete & re-create
(( zcd_refresh )) && command rm -f "${ZSH_COMPDUMP}"

# NOTE 先更新 fpath 然后执行 compinit 命令
compinit -i -d "${ZSH_COMPDUMP}" # 加载: compdef

if (( zcd_refresh )); then
  echo >> "${ZSH_COMPDUMP}"
  echo "${zcd_times}" >> "${ZSH_COMPDUMP}"
  echo "${zcd_rhash}" >> "${ZSH_COMPDUMP}"
  echo "${zcd_fpath}" >> "${ZSH_COMPDUMP}"

  zrecompile -q -p "${ZSH_COMPDUMP}"
  command rm -f "${ZSH_COMPDUMP}.zwc.old"
fi

unset -v zcd_{fpath,rhash,times,last2,refresh}
