# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charlie WONG <charlie-wong@outlook.com>
# Created By: Charlie WONG 2023-11-29T20:13:29+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# https://github.com/scop/bash-completion.git
# Enable programmable completion features for interactive shells.
if ! shopt -oq posix; then # apt show bash-completion
  # NOTE It maybe enabled by /etc/bash.bashrc or /etc/profile
  [[ -z "${BASH_COMPLETION_VERSINFO[@]}" ]] && {
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
      source /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]]; then
      source /etc/bash_completion
    fi
  }
fi
