alias c=clear

alias ls='command ls --color=auto --time-style="+%FT%T"'

alias  l='ls -hl'       # 按名称排序(字母表), 显示 mtime
alias ll='ls -hlS'      # 按文件大小排序,  largest first

alias la='ls -hlu'      # 按名称排序(字母表), 显示 atime
alias las='ls -hlut'    # 按 atime 排序 the newest first

alias lc='ls -hlc'      # 按名称排序(字母表), 显示 ctime
alias lcs='ls -hlct'    # 按 ctime 排序 the newest first

alias lm='ls -hl'       # 按名称排序(字母表), 显示 mtime
alias lms='ls -hlt'     # 按 mtime 排序 the newest first

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

alias diff='diff --color=auto --report-identical-files'

# 显示 X509 证书信息 => ls-x509 path/to/x509/key.der
alias ls-x509='openssl x509 -noout -text -in'

# - /dev/sdXY         driver `ide-scsi`  => SCSI/SATA/USB disks
# - /dev/nvmeXnYpZ    driver `nvme`      => NVMe or SSD devices
# 显示磁盘分区详细信息 => ls-partitions /dev/nvme0n1
alias ls-partitions='lsblk -o NAME,FSTYPE,FSSIZE,FSUSE%,FSUSED,MOUNTPOINT,LABEL,UUID,PARTLABEL,PARTUUID'
