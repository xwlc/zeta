# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-25T09:50:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# 权限, POSIX ACL(Access Control Lists)
# - https://savannah.nongnu.org/projects/acl
# - https://wiki.archlinux.org/title/Access_Control_Lists
# - https://wiki.archlinux.org/title/File_permissions_and_attributes
# - 软件包 apt show acl 包含的命令 getfacl, setfacl 和 chacl
# - NOTE 若 ls -l 命令显示的权限标志中包含 + 则表示已设置 ACL
#
# FAQs ^_^ https://www.redhat.com/sysadmin/suid-sgid-sticky-bit
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

_xsh_=zsh
[[ -n "${BASH_VERSION:-}" ]] && _xsh_=bash
for _it_ in "${ZETA_DIR}/xsh/core/${_xsh_}/"*; do
  source "${_it_}" # 先更新 fpath 然后执行 compinit 命令
done; unset -v  _xsh_  _it_

# Lazy Loading Just for Simple Plugins
source "${ZETA_DIR}/xsh/core/lazy.xsh"
@zeta:lazy:register bd
@zeta:lazy:register goto
@zeta:lazy:register replace
@zeta:lazy:register color-pipe
@zeta:lazy:register cursor-style
@zeta:lazy:register ssh-add-keys
@zeta:lazy:register xcmd $(command ls "${ZETA_DIR}/xsh/bin")
[[ -n "${BASH_VERSION:-}" ]] && @zeta:lazy:register repeat

# Bash/Zsh 的位置参数解析
source "${ZETA_DIR}/xsh/core/zxap.xsh"
# Shell 查询帮助快捷工具函数
source "${ZETA_DIR}/xsh/core/help.xsh"
# 需 ROOT 权限的系统管理快捷工具函数
source "${ZETA_DIR}/xsh/core/admin.xsh"
# 管理 3rd/pick 目录的软连接(版本切换)
source "${ZETA_DIR}/3rd/switch-to.xsh"
