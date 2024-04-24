# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-25T09:50:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

alias c='clear'   ;   alias rd='rmdir'
alias j='jobs -l' ;   alias md='mkdir -p'

alias cp='cp -i'  ;   alias -- -='cd -'
alias mv='mv -i'  ;   alias   ..='cd ../'
alias rm='rm -i'  ;   alias  ...='cd ../../'

# NOTE https://unix.stackexchange.com/questions/272965
# diff between `pushd` `popd` `cd` `cd -` for bash & zsh
# NOTE zsh -> `echo ${dirstack[@]}`, bash -> `echo ${DIRSTACK[@]}`
# `dirs -v` shell builtin command to show current directory stack
# 当前 shell 会话目录栈列表, 左起第一项(0)表示当前目录, 往后依次类推
alias d='dirs -v'

# `env | grep PATH`
# `sudo env | grep PATH`
# 二者运行时的 PATH 设置不同，用户独有的命令 sudo 无法执行
# 添加 Shell 别名，临时修改执行 sudo 时的环境变量 PATH 的值
alias sudo='sudo env PATH=$PATH'

# Show report message if two files are identical
alias diff='diff --color=auto --report-identical-files'

# -Ax   左侧地址 offset 十六进制   -ta  输出: 命名字符且忽略第8位
# -w16  每行显示 16 个字节         -tc  输出: 可打印字符或反斜线转移
#       --format=x1zu1o1
# -to1  输出: 每个数字 1 个字节, 八进制
# -tu1  输出: 每个数字 1 个字节, 十进制, 无符号
# -tx1z 输出: 每个数字 1 个字节, 十六进制, z 表示左侧显示源文件可打印内容
alias od='od  -Ax  -w16  -tx1z  -tu1  -to1'

_list_='.git,.github,.vscode,.bundle,node_modules,build,cache,3rdparty,todo,wip'
alias  grep="grep  --color=auto --exclude-dir={${_list_}}" # grep -G, the default
alias egrep="egrep --color=auto --exclude-dir={${_list_}}" # grep -E, extend regexp
alias fgrep="fgrep --color=auto --exclude-dir={${_list_}}" # grep -F, fixed strings
unset -v _list_

# https://www.baeldung.com/linux/find-command-regex
# 显示 find 有效的正则表达式名称 => find -regextype help
# .   period          matches any character once, except a newline character
# *   asterisk        matches zero or more preceding char/regular-expression
# \   backslash       escapes special characters
# []  square-brackets matches any character in the square-brackets, only once
# ^   caret           negates the content within square-brackets
#                     matches the beginning of lines when searching in a file
# NOTE Shell Glob Special Char
# .   represents a literal period
# *   zero or more of any characters
@zeta:xsh:no-cmd ff && alias ff='find . -type f -name'
@zeta:xsh:no-cmd fd && alias fd='find . -type d -name'
# find . -maxdepth 1 -type f -regex '.*\.js'
# find . -maxdepth 1 -type d -regex 'foo[0-9]'
# -maxdepth 1 => just start point folder, no recursively
@zeta:xsh:no-cmd duf && alias duf='du -sh *'
@zeta:xsh:no-cmd dud && alias dud='du -d 1 -h'

# https://unix.stackexchange.com/questions/367547
# http://www.makelinux.net/ldd3/chp-3-sect-2.shtml
# 关于 ls -l /dev/null /dev/zero /dev/tty 显示结果的解释
# => crw-rw-rw- 1 root root 1, 3 2023-12-17T13:42:41 /dev/null
# => crw-rw-rw- 1 root tty  5, 0 2023-12-18T12:38:24 /dev/tty
# => crw-rw-rw- 1 root root 1, 5 2023-12-17T13:42:41 /dev/zero
# 文件-  目录d  软链接l  字符设备c  块设备b
# 1,3 -> 第五列 Major 设备号, 第六列 Minor 次设备号

alias ls='command ls --color=auto --time-style="+%FT%T"'
# https://unix.stackexchange.com/questions/50377
#alias dir='command dir --color=auto' # compatibility
# https://unix.stackexchange.com/questions/217757
#alias vdir='vdir --color=auto' # almost the same as ls

# -h   human readable format     -r   reverse order while sorting
# -i   show inode index number   -R   list subdirectories recursively
# -l   use long listing format   -d   only folders, not their contents
# -s   allocated blocks size     -S   sort by file size, largest first

alias  l='ls -hl'       # 按名称排序(字母表), 显示 mtime
alias ll='ls -hlS'      # 按文件大小排序,  largest first

alias la='ls -hlu'      # 按名称排序(字母表), 显示 atime
alias las='ls -hlut'    # 按 atime 排序 the newest first

alias lc='ls -hlc'      # 按名称排序(字母表), 显示 ctime
alias lcs='ls -hlct'    # 按 ctime 排序 the newest first

alias lm='ls -hl'       # 按名称排序(字母表), 显示 mtime
alias lms='ls -hlt'     # 按 mtime 排序 the newest first

# Shell Glob Pattern Expansion
# -> Bash 手册  3.5.8  Filename Expansion
# -> FindUtils  2.3.4  Shell Pattern Matching
# NOTE 点非特殊字符; 双引号或单引号内的字符串不进行扩展
# ? 仅单字符  * 多个或零个字符  [] 仅括号内单字符  \ 转义(不扩展)
#
# https://unix.stackexchange.com/questions/204803
# NOTE `nullglob` shell option not enable default
# - 14.8.7 Glob Qualifiers
# - (N) sets the NULL_GLOB option for current pattern only

# 仅显示隐藏文件, 按名称排序(字母表), 显示 ctime
if [[ -n "${ZSH_VERSION:-}" ]]; then
  alias lh='ls -hlcd .*(N)'
else
  alias lh='ls -hlcd .*'
fi

function ls-dot-files() {
  local _here_="$1"
  [[ -z "${_here_}" ]] && _here_="${PWD}"
  [[ ! -d "${_here_}" ]] && return 1
  # NOTE 引号之外的 .* 用于 Shell Glob File Name Match
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    builtin eval "ls -hlcd '${_here_}'/.*(N)"
  else
    ls -hlcd "${_here_}"/.*
  fi
}

alias ls-x509-crt='openssl x509 -noout -text -in' # path/to/ca.crt 查看证书信息
alias ls-x509-csr='openssl req  -noout -text -in' # path/to/ca.csr 查看签名请求
alias ls-x509-crl='openssl crl  -noout -text -in' # path/to/ca.crl 查看注销列表

# 显示网址/域名的 HTTPS 证书链
function ls-x509-https-cert-chain() {
  [[ $# -eq 0 ]] && {
    echo "ls-x509-skid-rsa www.baidu.com"
    return
  }
  openssl s_client -showcerts -connect $1:443
}

# https://security.stackexchange.com/questions/128944
# https://www.openssl.org/docs/manmaster/man5/x509v3_config.html
# 计算 SKID(Subject Key Identifier) 和 AKID(Authority Key Identifier)
# 显示证书导出公钥文件中的 BIT STRING 数据部分的偏移量
# => RSA 算法类密钥公钥偏移 19字节, ED25519 算法则偏移 9 字节
# openssl x509 -noout -in ca.crt -pubkey | openssl asn1parse
function ls-x509-skid-rsa() {
  [[ $# -eq 0 || ! -f "$1" ]] && {
    echo "ls-x509-skid-rsa path/to/RSA.crt"
    return
  }
  openssl x509 -noout -pubkey -in $1 | openssl asn1parse -strparse 19 -noout -out - | openssl dgst -c -sha1
}

function ls-x509-skid-ed25519() {
  [[ $# -eq 0 || ! -f "$1" ]] && {
    echo "ls-x509-skid-ed25519 path/to/ED25519.crt"
    return
  }
  openssl x509 -noout -pubkey -in $1 | openssl asn1parse -strparse 9 -noout -out - | openssl dgst -c -sha1
}

# - /dev/sdXY         driver `ide-scsi`  => SCSI/SATA/USB disks
# - /dev/nvmeXnYpZ    driver `nvme`      => NVMe or SSD devices
# 显示磁盘分区详细信息 => ls-disk-layout /dev/nvme0n1
alias ls-disk-layout='lsblk -o NAME,FSTYPE,FSSIZE,FSUSE%,FSUSED,MOUNTPOINT,LABEL,UUID,PARTLABEL,PARTUUID'

if @zeta:xsh:has-cmd dpkg; then
  alias dpkg-ls-rc='dpkg -l | grep "^rc"'
  alias dpkg-rm-rc='dpkg -l | grep "^rc" | awk "{print \$2}" | sudo xargs dpkg --purge'
fi

# ISO-8601 格式时间标签
# -> date +'%F %T %z'              date +'%FT%T%Z'
# -> date +'%Y-%m-%d %H:%M:%S %z'  date +'%Y-%m-%dT%H:%M:%S%Z'
@zeta:xsh:no-cmd now && alias now=timestap-iso-8601
function timestap-iso-8601() {
  case "$1" in
        date) date --iso-8601         ;; # 2023-12-29
       hours) date --iso-8601=hours   ;; # 2023-12-29T05+08:00
     minutes) date --iso-8601=minutes ;; # 2023-12-29T05:22+08:00
     seconds) date --iso-8601=seconds ;; # 2023-12-29T05:22:46+08:00
    compress) date '+%Y%m%d%H%M%S%z'  ;; # 20231229053537+0800
           *) date --iso-8601=seconds ;;
  esac
}


# 默认安装 https://www.rsyslog.com
# apt show rsyslog 和 ps aux | grep syslog
# 配置文件 /etc/rsyslog.conf 和 /etc/rsyslog.d/*.conf
#
# 日志管理工具 https://github.com/logrotate/logrotate
# 配置文件 /etc/logrotate.conf 和 /etc/logrotate.d/*
#
# 关于日志文件 https://superuser.com/questions/565927
alias admin-journalctl-rm-all-logs='sudo journalctl --rotate --vacuum-time=1s'
function admin-rm-all-system-logs() {
  # journalctl --disk-usage             显示日志文件占用空间大小
  # journalctl --verify                 检测日志功能及日志文件完整性
  # journalctl --vacuum-size=8M         仅保留最新的 8 MiB 压缩后的日志
  # systemctl status systemd-journald   查看后台日志服务守护进程的状态
  echo "Delete all journalctl log $(@G3 '/var/log/journal/*')"
  sudo journalctl --rotate --vacuum-time=1s

  function once±clean-reset-system-log() {
    [ ! -f "$1" ] && return

    echo "Clean/Reset system log of $(@G3 $1)"
    #sudo sh -c "echo > $1"

    local xlog

    for xlog in $1.*.gz; do
      [[ ! -f "${xlog}" ]] && continue
      echo "Delete the compressed log $(@G3 ${xlog})"
      sudo rm -f "${xlog}"
    done

    for xlog in $1.{[0-9],old}; do
      [[ ! -f "${xlog}" ]] && continue
      echo "Delete old/numbers log of $(@G3 ${xlog})"
      sudo rm -f "${xlog}"
    done
  }

  # /var/log/dist-upgrade/    系统版本升级日志
  once±clean-reset-system-log "/var/log/dpkg.log"
  once±clean-reset-system-log "/var/log/bootstrap.log" # 软件包管理日志
  once±clean-reset-system-log "/var/log/apt/term.log" # 软件包安装/配置记录
  once±clean-reset-system-log "/var/log/apt/history.log" # 软件包的更新记录
  once±clean-reset-system-log "/var/log/unattended-upgrades/unattended-upgrades.log"
  once±clean-reset-system-log "/var/log/unattended-upgrades/unattended-upgrades-dpkg.log"
  once±clean-reset-system-log "/var/log/unattended-upgrades/unattended-upgrades-shutdown.log"

  # 应用程序崩溃日志
  once±clean-reset-system-log "/var/log/apport.log"
  # 默认程序管理命令 update-alternatives 的执行记录
  once±clean-reset-system-log "/var/log/alternatives.log"

  # https://www.cups.org/doc/man-cupsd-logs.html
  # 日志显示调试 https://wiki.archlinux.org/title/CUPS
  once±clean-reset-system-log "/var/log/cups/page_log"
  once±clean-reset-system-log "/var/log/cups/error_log"
  once±clean-reset-system-log "/var/log/cups/access_log"

  # /var/log/utmp     二进制, 用户 Login/Logout 历史记录, 查看命令 who
  # /var/log/wtmp     二进制, 用户 Login/Logout 历史记录, 查看命令 who
  # /var/log/btmp     二进制, 失败的 Login 记录, 查看命令 last -f /var/log/btmp
  # /var/log/faillog  二进制, 失败的 Login 记录, 查看命令 faillog
  # /var/log/lastlog  二进制, 用户最近的登陆状态, 查看命令 lastlog
  once±clean-reset-system-log "/var/log/auth.log" # 用户认证记录

  # journalctl ... 命令执行后自动清空 /var/log/boot.log 启动日志
  # 内核日志的区别 https://askubuntu.com/questions/26237
  once±clean-reset-system-log "/var/log/syslog" # 系统日志
  once±clean-reset-system-log "/var/log/kern.log" # 内核日志
  # /var/log/dmesg 每次重启后自动覆盖(硬件驱动相关日志)

  once±clean-reset-system-log "/var/log/mail.log"   # 系统邮件服务日志
  once±clean-reset-system-log "/var/log/cron.log"   # 周期性 cron 任务日志
  once±clean-reset-system-log "/var/log/daemon.log" # 系统后台守护进程日志

  # https://wiki.archlinux.org/title/SDDM
  once±clean-reset-system-log "/var/log/sddm.log" # 图形用户界面管理器日志
  once±clean-reset-system-log "/var/log/fontconfig.log" # 系统字体配置日志

  once±clean-reset-system-log "/var/log/Xorg.0.log" # X 系统日志(0 号显示器)

  # 多显卡 GPU 管理器
  once±clean-reset-system-log "/var/log/gpu-manager.log"
  once±clean-reset-system-log "/var/log/gpu-manager-switch.log"

  once±clean-reset-system-log "/var/log/prime-supported.log"
  once±clean-reset-system-log "/var/log/ubuntu-advantage.log"

  unset -f once±clean-reset-system-log
}

alias to-upper1='@zeta:xsh:to-upper1'
alias to-uppera='@zeta:xsh:to-uppera'
alias to-lowera='@zeta:xsh:to-lowera'

alias is-binnum='@zeta:util:is-binnum'
alias is-octnum='@zeta:util:is-octnum'
alias is-decnum='@zeta:util:is-decnum'
alias is-hexnum='@zeta:util:is-hexnum'
alias is-number='@zeta:util:is-number'
