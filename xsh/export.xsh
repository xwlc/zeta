# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-25T09:50:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

export GPG_TTY=$(tty)

if [ -d "/media/${USER}/Super/keysrepo/gnupg" ]; then
  export GNUPGHOME="/media/${USER}/Super/keysrepo/gnupg"
fi

if [ -d "/me/zeta/3rd/bin" ]; then
  export PATH="/me/zeta/3rd/bin:${PATH}"
fi

if @zeta:xsh:has-cmd nvim; then
  export VISUAL=nvim
elif @zeta:xsh:has-cmd nano; then
  export VISUAL=nano
fi

if [ -n "${VISUAL}" ]; then
  export EDITOR="${VISUAL:-}"

  # Git 编辑器优先级 GIT_EDITOR > core.editor > VISUAL > EDITOR > 默认值 vi
  export GIT_EDITOR="${VISUAL:-}"
fi
