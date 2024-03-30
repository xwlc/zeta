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

# 显示 X509 证书信息 => ls-x509 path/to/x509/key.der
alias ls-x509='openssl x509 -noout -text -in'

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

alias to-upper1='@zeta:xsh:to-upper1'
alias to-uppera='@zeta:xsh:to-uppera'
alias to-lowera='@zeta:xsh:to-lowera'

alias is-binnum='@zeta:util:is-binnum'
alias is-octnum='@zeta:util:is-octnum'
alias is-decnum='@zeta:util:is-decnum'
alias is-hexnum='@zeta:util:is-hexnum'
alias is-number='@zeta:util:is-number'
