# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-25T09:50:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# By default, most Linux Distro set it to 002, focus on sharing
# 002 -> new file with 664, and new folder with 775 permissions
# 022 -> new file with 644, and new folder with 755 permissions
umask -S u=rwx,g=rx,o=rx > /dev/null # 新文件=0644, 新目录=0755

# Make less more friendly for non-text input files
# https://manpages.debian.org/bookworm/less/lesspipe.1.en.html
# TODO https://github.com/wofr06/lesspipe 版和 debian 版的关系
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"
#echo "LESSOPEN=[$LESSOPEN], LESSCLOSE=[$LESSCLOSE]"

# NOTE ls and grep color support
# --color=never  never emits color codes, this is ls default configure
# --color=auto   emits color codes only when stdout connected to terminal
# https://www.gnu.org/software/coreutils/manual/coreutils.html#Directory-listing
# LS_COLORS Gererator => https://geoff.greer.fm/lscolors
# LS_COLORS is used to configure ls color theme, use `dircolors` to set it
if [ -x /usr/bin/dircolors ]; then
  if [ -r "${ZETA_DIR}/xsh/extra/dircolors" ]; then
    eval "$(dircolors -b "${ZETA_DIR}/xsh/extra/dircolors")"
  else
    eval "$(dircolors -b)"
  fi
fi

# Lazy Loading Just for Simple Plugins
source "${ZETA_DIR}/xsh/core/lazy.xsh"

@zeta:lazy:register bd
#@zeta:lazy:register goto
@zeta:lazy:register replace
@zeta:lazy:register color-pipe
@zeta:lazy:register cursor-style
@zeta:lazy:register ssh-add-keys
@zeta:lazy:register xcmd $(command ls "${ZETA_DIR}/xsh/bin")

if [[ -n "${BASH_VERSION:-}" ]]; then
  @zeta:lazy:register repeat
fi
