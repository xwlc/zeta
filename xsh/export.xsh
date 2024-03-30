# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-25T09:50:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

if [ -d "/me/zeta/3rd/bin" ]; then
  export PATH="/me/zeta/3rd/bin:${PATH}"
fi

# `gpg-agent` is a daemon to manage private keys for GnuPG
export GPG_TTY=$(tty)

if [ -d "/media/${USER}/Super/keysrepo/gnupg" ]; then
  export GNUPGHOME="/media/${USER}/Super/keysrepo/gnupg"
fi

if command -v nvim > /dev/null; then
  export VISUAL=nvim
elif command -v nano > /dev/null; then
  export VISUAL=nano
fi

if [ -n "${VISUAL}" ]; then
  export EDITOR="${VISUAL:-}"

  # Git 编辑器优先级 GIT_EDITOR > core.editor > VISUAL > EDITOR > 默认值 vi
  export GIT_EDITOR="${VISUAL:-}"
fi

# https://wiki.archlinux.org/title/Locale  显示当前本地化设置 locale
# 格式文件 => /usr/share/i18n/locales      显示可用本地化设置 locale -a
# 值的格式: [语言[_地域][.字符集][@修正值] 显示当前本地化设置 localectl status
# NOTE POSIX 规范, 7 Locale
# => https://pubs.opengroup.org/onlinepubs/9699919799/
# LANG=C 设置的起源 https://superuser.com/questions/219945
# NOTE 显示当前时间格式信息 locale -k LC_TIME
# 当前命令指定时间格式 LC_TIME=zh_CN.UTF-8 date

# NOTE LC_* 系列变量未显示设置时 LANG 的值则使用其默认值
# LANG=C 或 POSIX 则表示关闭本地化, 关闭后终端中文显示异常
export LANG=en_US.UTF-8
# gettext 翻译器的备选语言列表; 左->右(左侧优先); git 的消息翻译器
# NOTE 大部分应用程序将英语 locale 作为默认 locale, 即 C, 若列表中
# 非英语 locale 位于英语 locale 之后, 即 en_US:zh_CN, 则英语 locale
# 通常被忽略, 而使用非英语 locale 进行翻译显示
# NOTE 若 LC_ALL 或 LANG 设置为 C, 则忽略 LANGUAGE
#unset -v LANGUAGE            # NOTE 方式1: 禁止翻译[英文] -> [中文]
#export LANGUAGE=en_US        # NOTE 方式2: 禁止翻译[英文] -> [中文]
export LANGUAGE=en_US:C:zh_CN # NOTE 方式3: 禁止翻译[英文] -> [中文]

if command -v ov > /dev/null; then
  if [ -z "${PAGER}" ]; then
    export PAGER="ov --quit-if-one-screen"
  fi
else
  # 优先级: $GIT_PAGER > core.pager > $PAGER > 编译时指定值(less)
  export GIT_PAGER="less --no-init --quit-if-one-screen --RAW-CONTROL-CHARS"
fi
