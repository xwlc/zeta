# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2023 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2023-11-25T09:50:43+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# 临时变量 _ycmd_ _yarg_ _yvar_ _ymsg_ _ytmp_ _yidx_ _ycnt_ _ynum_ _yval_ _flag_
# 临时变量 _zcmd_ _zarg_ _zvar_ _zmsg_ _ztmp_ _zidx_ _zcnt_ _znum_ _zval_ _isok_

alias c='clear'   ;   alias j='jobs -l'

alias cp='cp -i'  ;   alias -- -='cd -'
alias mv='mv -i'  ;   alias   ..='cd ../'
alias rm='rm -i'  ;   alias  ...='cd ../../'

# NOTE https://unix.stackexchange.com/questions/272965
# diff between `pushd` `popd` `cd` `cd -` for bash & zsh
# NOTE zsh -> `echo ${dirstack[@]}`, bash -> `echo ${DIRSTACK[@]}`
# `dirs -v` shell builtin command to show current directory stack
# 当前 shell 会话目录栈列表, 左起第一项(0)表示当前目录, 往后依次类推
alias d='dirs -v'

# Show report message if two files are identical
alias diff='diff --color=auto --report-identical-files'

# -Ax   左侧地址 offset 十六进制   -ta  输出: 命名字符且忽略第8位
# -w16  每行显示 16 个字节         -tc  输出: 可打印字符或反斜线转移
#       --format=x1zu1o1
# -to1  输出: 每个数字 1 个字节, 八进制
# -tu1  输出: 每个数字 1 个字节, 十进制, 无符号
# -tx1z 输出: 每个数字 1 个字节, 十六进制, z 表示左侧显示源文件可打印内容
alias od='od  -Ax  -w16  -tx1z  -tu1  -to1'

_zvar_=".git,.github,.vscode,.bundle,.cache,node_modules"
_zvar_="${_zvar_},out,dist,build,cache,3rd,3rdparty,todo,wip"

_zcmd_="$(command -v grep)"  # grep 默认等同于 grep -G
alias  grep="${_zcmd_} --color=auto --exclude-dir={${_zvar_}}"
_zcmd_="$(command -v egrep)" # grep -E extend regexp
alias egrep="${_zcmd_} --color=auto --exclude-dir={${_zvar_}}"
_zcmd_="$(command -v fgrep)" # grep -F fixed strings
alias fgrep="${_zcmd_} --color=auto --exclude-dir={${_zvar_}}"

if @zeta:xsh:has-cmd ack; then
  _ztmp_=; _zcmd_="$(command -v ack)"
  for _zval_ in $(echo "${_zvar_}" | sed 's/,/ /g'); do
    _ztmp_+=" --ignore-dir=${_zval_}"
  done
  _ztmp_+=" --ignore-file=ext:log"
  _ztmp_+=" --ignore-file=match:history"
  _ztmp_+=" --ignore-file=match:zcompdump"
  alias ack="${_zcmd_} ${_ztmp_}"
fi

# https://dystroy.org/broot/install-br
@zeta:xsh:has-cmd broot && BR_INSTALL=no

@zeta:xsh:no-cmd zduf && alias zduf='du -h -s'
@zeta:xsh:no-cmd zdud && alias zdud='du -h -d 1'

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
@zeta:xsh:no-cmd zff && alias zff='find . -type f -name'
@zeta:xsh:no-cmd zfd && alias zfd='find . -type d -name'

# 示例命令 touch ok > 'it ok'; echo "it ok" | esc-space | xargs cat
alias esc-space='sed -e "s/ /\\\\ /g"' # 反斜杠数目: 四 -> 二 -> 一

# 示例 find . -maxdepth 1 -type f -regex '.*\.js'
# 示例 find . -maxdepth 1 -type d -regex 'foo[0-9]'
function find-file-regex() {
  local _it_ _items_
  case $# in
    1) _items_=( $(command find ./ -type f -name "*$1*" -print) ) ;;
    2) _items_=( $(command find $1 -type f -name "*$2*" -print) ) ;;
    *) return 1 ;;
  esac
  for _it_ in ${_items_}; do realpath ${_it_}; done
}

function find-dirs-regex() {
  local _it_ _items_
  case $# in
    1) _items_=( $(command find ./ -type d -name "*$1*" -print) ) ;;
    2) _items_=( $(command find $1 -type d -name "*$2*" -print) ) ;;
    *) return 1 ;;
  esac
  for _it_ in ${_items_}; do realpath ${_it_}; done
}

# https://unix.stackexchange.com/questions/367547
# http://www.makelinux.net/ldd3/chp-3-sect-2.shtml
# 关于 ls -l /dev/null /dev/zero /dev/tty 显示结果的解释
# => crw-rw-rw- 1 root root 1, 3 2023-12-17T13:42:41 /dev/null
# => crw-rw-rw- 1 root tty  5, 0 2023-12-18T12:38:24 /dev/tty
# => crw-rw-rw- 1 root root 1, 5 2023-12-17T13:42:41 /dev/zero
# 文件-  目录d  软链接l  字符设备c  块设备b
# 1,3 -> 第五列 Major 设备号, 第六列 Minor 次设备号

# https://www.baeldung.com/linux/ls-ignore-hide-files
_zvar_="--hide='System Volume Information'" # NTFS 格式系统卷信息
_zvar_="${_zvar_} --hide='\$RECYCLE.BIN'" # NTFS 回收站
_zvar_="${_zvar_} --hide='lost+found'" # EXT4 数据恢复元数据
alias ls="/usr/bin/ls --color=auto --time-style=+%FT%T ${_zvar_}"

if @zeta:xsh:has-cmd eza; then
  _zcmd_=$(command -v eza) # 忽略 glob 分割符 |
  _zvar_="--ignore-glob='System Volume Information"
  _zvar_="${_zvar_}|\$RECYCLE.BIN|lost+found'"
  alias eza="${_zcmd_} --color=auto --time-style=+%FT%T ${_zvar_}"
fi

if @zeta:xsh:has-cmd lsd; then
  _zcmd_=$(command -v lsd)
  _zvar_="--ignore-glob='System Volume Information'"
  _zvar_="${_zvar_} --ignore-glob='\$RECYCLE.BIN'"
  _zvar_="${_zvar_} --ignore-glob='lost+found'"
  _zvar_="${_zvar_} --icon=always --icon-theme=unicode"
  alias lsd="${_zcmd_} --color=auto --date=+%FT%T ${_zvar_}"
fi

# https://unix.stackexchange.com/questions/50377
#alias dir='command dir --color=auto' # compatibility
# https://unix.stackexchange.com/questions/217757
#alias vdir='vdir --color=auto' # almost the same as ls

# -h   human readable format     -r   reverse order while sorting
# -i   show inode index number   -R   list subdirectories recursively
# -l   use long listing format   -d   only folders, not their contents
# -s   allocated blocks size     -S   sort by file size, largest first

alias  l='ls -hl'       # 按名称排序(字母表), 显示 mtime(inode modify time)
alias ll='ls -hlS'      # 按文件大小排序,  largest first

alias la='ls -hlu'      # 按名称排序(字母表), 显示 atime(inode access time)
alias las='ls -hlut'    # 按 atime 排序 the newest first

alias lc='ls -hlc'      # 按名称排序(字母表), 显示 ctime(inode change time)
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
  alias lh='ls -hld .*(N) 2> /dev/null'
else
  alias lh='ls -hld .* 2> /dev/null'
fi

function ls-dot-files() {
  local folder="$1"
  [[ -z "${folder}" ]] && folder="${PWD}"
  folder="$(realpath "${folder}")"
  [[ ! -d "${folder}" ]] && return 1
  # NOTE 引号之外的 .* 用于 Shell Glob File Name Match
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    builtin eval "ls -hld '${folder}'/.*(N)" 2> /dev/null
  else
    ls -hld "${folder}"/.* 2> /dev/null
  fi
}

function ls-gpg-keys() {
  if [[ $# -eq 0 ]]; then
    gpg -k; return # 显示本地公钥
  fi

  local key=$1 type=$2
  [[ ! -f "${key}" ]] && return 1
  [[ -z "${type}" ]] && type=short

  # -k,--list-public-keys 和 --with-subkey-fingerprint
  case ${type} in
    short) gpg --show-keys "${key}" ;;
     long) gpg --no-default-keyring --show-keys "${key}" ;;
        *) gpg --show-keys --with-colons "${key}" ;;
  esac
}

alias ls-x509-crt='openssl x509 -noout -text -in' # path/to/ca.crt 查看证书信息
alias ls-x509-csr='openssl req  -noout -text -in' # path/to/ca.csr 查看签名请求
alias ls-x509-crl='openssl crl  -noout -text -in' # path/to/ca.crl 查看注销列表

# 显示网址/域名的 HTTPS 证书链
function ls-x509-https-cert-chain() {
  [[ $# -eq 0 ]] && {
    echo "$(@D9 ls-x509-https-cert-chain) www.baidu.com"; return
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
    echo "$(@D9 ls-x509-skid-rsa) path/to/RSA.crt"; return
  }
  openssl x509 -noout -pubkey -in $1 \
    | openssl asn1parse -strparse 19 -noout -out - \
    | openssl dgst -c -sha1
}

function ls-x509-skid-ed25519() {
  [[ $# -eq 0 || ! -f "$1" ]] && {
    echo "$(@D9 ls-x509-skid-ed25519) path/to/ED25519.crt"; return
  }
  openssl x509 -noout -pubkey -in $1 \
    | openssl asn1parse -strparse 9 -noout -out - \
    | openssl dgst -c -sha1
}

# 列表格式化显示 /etc/passwd
alias ls-etc-passwd='column -t -s : /etc/passwd'

# 显示系统配置的默认应用程序及相关库文件
alias ls-alt-selections="update-alternatives --get-selections"

# 显示磁盘分区详细信息 => ls-disk-layout /dev/nvme0n1
# - /dev/sdXY         driver `ide-scsi`  => SCSI/SATA/USB disks
# - /dev/nvmeXnYpZ    driver `nvme`      => NVMe or SSD devices
alias ls-disk-layout='lsblk -o NAME,FSTYPE,FSSIZE,FSUSE%,FSUSED,MOUNTPOINT,LABEL,UUID,PARTLABEL,PARTUUID'
alias ls-disk-block-size='stat -fc %s .' # 显示磁盘 Block Size 字节

# ISO-8601 格式时间标签
# -> date +'%F %T %z'              date +'%FT%T%Z'
# -> date +'%Y-%m-%d %H:%M:%S %z'  date +'%Y-%m-%dT%H:%M:%S%Z'
@zeta:xsh:no-cmd now && alias now=timestamp-iso-8601-now
function timestamp-iso-8601-now() {
  case "$1" in
        date|d|D) date --iso-8601         ;; # 2023-12-29
       hours|h|H) date --iso-8601=hours   ;; # 2023-12-29T05+08:00
     minutes|m|M) date --iso-8601=minutes ;; # 2023-12-29T05:22+08:00
     seconds|s|S) date --iso-8601=seconds ;; # 2023-12-29T05:22:46+08:00
    compress|c|C) date '+%Y%m%d%H%M%S'    ;; # 20231229053537
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

unset -v _ycmd_ _yarg_ _yvar_ _ymsg_ _ytmp_   _yidx_ _ycnt_ _ynum_ _yval_ _flag_
unset -v _zcmd_ _zarg_ _zvar_ _zmsg_ _ztmp_   _zidx_ _zcnt_ _znum_ _zval_ _isok_
