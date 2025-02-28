# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2024 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2024-04-25T07:23:48+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# 临时切换到 Root 权限的交互式终端
alias login-as-root='/bin/sudo -i'

# `env | grep PATH` 和 `sudo env | grep PATH`
# 二者运行时的 PATH 不同(普通用户非标准命令 sudo 无法执行)
# 修改 sudo 执行时的环境变量 PATH 的值(包含非标准命令路径)
alias sudo-env-path='sudo env PATH=${PATH}'

# NOTE 当前内核文件系统 cat /proc/filesystems
# https://www.kernel.org/doc/html/latest/filesystems
# 文件系统内核模块 ls /lib/modules/$(uname -r)/kernel/fs
# /etc/mtab -> /proc/self/mounts 和 /proc/mounts -> self/mounts
#
# 查看已经加载文件系统的命令 cat /etc/mtab 或 findmnt
# 卸载已经加载文件系统的命令 sudo umount /dev/nvme0n1p1

# https://docs.kernel.org/filesystems/vfat.html
# https://docs.kernel.org/filesystems/ntfs3.html
function @zeta:admin:mount-partition() {
  local fstype=auto device="$2" mountpoint="$3" owner_only="$4" opts umask0077
  [[ -n "${owner_only}" ]] && umask0077=',umask=0077'

  case "$1" in
    fat16|FAT16|fat32|FAT32|vfat|VFAT) fstype=vfat ;;
    ntfs|NTFS|ntfs3|NTFS3) fstype=ntfs3 ;;
    *) return 1 ;;
  esac

  # nosuid    禁用 SUID 权限标志位
  # nodev     可创建字符/块设备文件, 但文件将失去特殊作用
  # noexec    执行标志位可设置, 但可执行文件不允许直接运行
  #           禁止 $ path/demo.sh 允许 $ bash path/demo.sh
  # noatime   禁止更新文件的访问时间属性 access-time
  opts="rw,nosuid,nodev,noexec,noatime"

  # https://www.baeldung.com/linux/user-ids-reserved-values
  opts="${opts},uid=$(id -u),gid=$(id -g)" # 当前用户 ID 和 用户组 ID
  opts="${opts},fmask=0122,dmask=0022${umask0077}" # 设置文件及目录的权限

  # https://www.baeldung.com/linux/mount-owner
  # https://www.baeldung.com/linux/mount-user-rights
  sudo mount --onlyonce --types ${fstype} -o ${opts} \
    --source "${device}" --target "${mountpoint}"
}

function @zeta:admin:mount-ntfs() {
  local disk_label="$1" dir_name="$2" owner_only="$3" block_device

  block_device=$(realpath "/dev/disk/by-label/${disk_label}")
  if [[ $? != 0 || ${block_device} == "/dev/disk/by-label/${disk_label}" ]]; then
    echo "no block device $(@R3 "/dev/disk/by-label/${disk_label}")"
    return 1
  fi

  if [[ ! -d "/media/${USER}" ]]; then
    sudo mkdir "/media/${USER}"
    sudo chown ${USER}:${USER} "/media/${USER}"
    chmod 0750 /media/${USER}

    # 关于 POSIX ACL(Access Control Lists) Permissions
    # => 设置 POSIX ACL 权限
    #    setfacl -m u:${USER}:r-x "/media/${USER}" # User
    #    setfacl -m g:${USER}:r-x "/media/${USER}" # Group
    #    setfacl -m other:---     "/media/${USER}" # Others
    # => 删除 POSIX ACL 权限
    #    setfacl --remove-all "/media/${USER}"
    # => 查看 POSIX ACL 权限
    #    getfacl /media/${USER}
    #    ls -l /media/${USER} # 显示 + 已设置 POSIX ACL 权限
  fi

  local mount_point="/media/${USER}/${dir_name}"
  if [[ ! -d "${mount_point}" ]]; then
    mkdir "${mount_point}"
    chmod 0700 "${mount_point}"
  fi

  @zeta:admin:mount-partition NTFS ${block_device} "${mount_point}" "${owner_only}"
}

function admin-eject-usb-disk() {
  if @zeta:xsh:no-cmd udisksctl; then
    echo "$(@R3 udisksctl) command NOT found, exit."
    return 1
  fi

  echo "=> $(@D9 The High-level Disk Info)"
  udisksctl status
  echo
  echo "=> $(@D9 List of Mounted File-systems)"
  findmnt --real
  echo

  if [[ $# -ne 1 || -z "$1" ]]; then
    echo "Usage Example: $(@G3 admin-eject-usb-disk) $(@Y3 /dev/sda)"
    return 0
  fi

  if [[ "$1" != "/dev/"?* ]]; then
    echo "Block device argment should started with $(@R3 /dev/)"
    return 1
  fi

  if findmnt | grep "$1"; then
    echo "$(@R3 $1) disk has partition mounted, exit."
    return 1
  fi

  if [[ ! -b "$1" ]]; then
    echo "$(@R3 $1) is not a block device, exit."
    return 1
  fi

  echo -n "=> $(@D9 'Power-off and eject') $(@R3 $1) $(@D9 'disk, press (')"
  echo -n "$(@G3 Y)$(@D9 ')es to confirm ?') "
  read power_off_confirm
  [[ "${power_off_confirm}" != "Y" ]] && return 1

  echo "   Power-off and eject $(@R3 $1) disk ..."
  sudo udisksctl power-off --block-device $1
}

# https://wiki.linuxfoundation.org/lsb/start
# https://wiki.linuxfoundation.org/lsb/fhs-30

# 默认安装 https://www.rsyslog.com
# apt show rsyslog 和 ps aux | grep syslog
# 配置文件 /etc/rsyslog.conf 和 /etc/rsyslog.d/*.conf
#
# 日志管理工具 https://github.com/logrotate/logrotate
# 配置文件 /etc/logrotate.conf 和 /etc/logrotate.d/*

function admin-show-boot-log() {
  if [ $# -eq 0 ]; then
    echo
    printf "$(@R3 %d)=$(@D9 %-8s)"  0  emerg
    printf "$(@R3 %d)=$(@D9 %-8s)"  1  alert
    printf "$(@R3 %d)=$(@D9 %-8s)"  2  crit
    printf "$(@R3 %d)=$(@D9 %-8s)"  3  err
    printf "$(@R3 %d)=$(@D9 %-8s)"  4  warning
    printf "$(@R3 %d)=$(@D9 %-8s)"  5  notice
    printf "$(@R3 %d)=$(@D9 %-8s)"  6  info
    printf "$(@R3 %d)=$(@D9 %s)\n"  7  debug
    echo
    # -X    最早启动日志 -b 1
    # ...
    # -1    上次启动日志 -b -1
    #  0    当前启动日志 -b 或 -b 0 或 -b -0
    journalctl --list-boots # 显示启动日志记录
    echo
    systemd-analyze # 启动单元耗时
    systemd-analyze blame | head -n 9
    echo
    return
  fi

  case $# in # FROM..TO
    1) journalctl -b --priority=$1 ;;
    2) journalctl -b --priority=$1..$2 ;;
    *) ;;
  esac
}

alias admin-rm-system-logs='sudo journalctl --rotate --vacuum-time=1s'

function @zeta:admin:del-all-sys-logs() {
  local xlog

  function once±clean-reset-system-logs() {
    local reset_clean
    [ ! -f "$1" ] && return
    [ -z "$2" ] && reset_clean=ok

    if [[ "${reset_clean}" == 'ok' ]]; then
      echo "Clean/Reset system log of $(@G3 $1)"
      sudo sh -c "echo > $1"
    fi

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

  # /var 目录结构及标准规范
  # => https://superuser.com/questions/565927
  # => https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch05.html
  # => https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/var.html

  # /var/log/dist-upgrade/    升级 Ubuntu 操作系统的版本日志
  once±clean-reset-system-logs "/var/log/dpkg.log"
  once±clean-reset-system-logs "/var/log/apt/term.log"
  once±clean-reset-system-logs "/var/log/apt/history.log"
# once±clean-reset-system-logs "/var/log/apt/eipp.log.xz"
  once±clean-reset-system-logs "/var/log/unattended-upgrades/unattended-upgrades.log"
  once±clean-reset-system-logs "/var/log/unattended-upgrades/unattended-upgrades-dpkg.log"
  once±clean-reset-system-logs "/var/log/unattended-upgrades/unattended-upgrades-shutdown.log"
  # https://github.com/canonical/ubuntu-pro-client
  once±clean-reset-system-logs "/var/log/ubuntu-advantage.log"
# /var/log/bootstrap.log                安装操作系统时创建的日志文件
# /var/log/installer/initial-status.gz  系统 ISO 镜像包含的软件包列表

  # 应用程序崩溃日志
  once±clean-reset-system-logs "/var/log/apport.log"
  # 默认程序管理命令 update-alternatives 的执行记录
  once±clean-reset-system-logs "/var/log/alternatives.log"

  # https://www.cups.org/doc/man-cupsd-logs.html
  # 日志显示调试 https://wiki.archlinux.org/title/CUPS
  once±clean-reset-system-logs "/var/log/cups/page_log"
  once±clean-reset-system-logs "/var/log/cups/error_log"
  once±clean-reset-system-logs "/var/log/cups/access_log"

  # 登陆和认证
  once±clean-reset-system-logs "/var/log/auth.log" # 认证记录
  once±clean-reset-system-logs "/var/log/utmp"    "no-reset" # 登陆记录, 查看命令 who
  once±clean-reset-system-logs "/var/log/wtmp"    "no-reset" # 登陆记录, 查看命令 who
  once±clean-reset-system-logs "/var/log/btmp"    "no-reset" # 登陆失败记录, last -f /var/log/btmp
  once±clean-reset-system-logs "/var/log/faillog" "no-reset" # 登陆失败记录, 查看命令 faillog
  once±clean-reset-system-logs "/var/log/lastlog" "no-reset" # 最近登陆状态, 查看命令 lastlog

  # 内核日志的区别 https://askubuntu.com/questions/26237
  once±clean-reset-system-logs "/var/log/dmesg"    # 硬件驱动
  once±clean-reset-system-logs "/var/log/syslog"   # 系统日志
  once±clean-reset-system-logs "/var/log/boot.log" # 启动日志
  once±clean-reset-system-logs "/var/log/kern.log" # 内核日志

  once±clean-reset-system-logs "/var/log/mail.log"   # 系统邮件服务日志
  once±clean-reset-system-logs "/var/log/cron.log"   # 周期性 cron 任务日志
  once±clean-reset-system-logs "/var/log/daemon.log" # 系统后台守护进程日志

  # https://wiki.archlinux.org/title/SDDM
  once±clean-reset-system-logs "/var/log/sddm.log" # 图形用户界面管理器日志
  once±clean-reset-system-logs "/var/log/fontconfig.log" # 系统字体配置日志

  # X 桌面图形系统日志, 数字表示显示器的编号
  for xlog in /var/log/Xorg.[0-9].log; do
    once±clean-reset-system-logs ${xlog}
  done

  # 多显卡 GPU 管理器
  # https://github.com/canonical/ubuntu-drivers-common/tree/master/share/hybrid
  once±clean-reset-system-logs "/var/log/gpu-manager.log"
  once±clean-reset-system-logs "/var/log/gpu-manager-switch.log"
  once±clean-reset-system-logs "/var/log/prime-supported.log"

  # journalctl --disk-usage             显示日志文件占用空间大小
  # journalctl --verify                 检测日志功能及日志文件完整性
  # journalctl --vacuum-size=8M         仅保留最新的 8 MiB 压缩后的日志
  # systemctl status systemd-journald   查看后台日志服务守护进程的状态
  echo "Delete all journalctl log $(@G3 '/var/log/journal/*')"
  sudo journalctl --rotate --vacuum-time=1s # 全部清空日志文件

  unset -f once±clean-reset-system-logs
}

function admin-clean-system-trash() {
  if @zeta:xsh:has-cmd apt; then
    sudo apt autoclean # 删除无用包缓存 man apt-get
    sudo apt autoremove # 删除自动安装的不再需要的软件包
    if dpkg -l | grep '^rc'; then # 清理软件卸载后残留的配置文件
       dpkg -l | grep '^rc' | awk '{print $2}' | sudo xargs dpkg --purge
    fi
  fi

  [[ -n "${ZSH_VERSION:-}" ]] && { # 关闭 GLOB 失败报错
    @zeta:xsh:opt-if-off-then-on nullglob; [[ $? -ne 0 ]] && {
      @zeta:xsh:wmsg "try enable $(@G3 nullglob) failed!"; return
    }
  }

  local xfile
  # 应用程序崩溃报告/日志
  for xfile in /var/crash/*.crash; do
    [[ ! -f "${xfile}" ]] && continue
    echo "Delete a crash report $(@G3 ${xfile})"
    sudo rm -f "${xfile}"
  done

  # dpkg 命令的配置文件(默认保存 7 个备份) /etc/cron.daily/dpkg
  # /etc/alternatives/* => 备份文件 /var/backups/alternatives.tar.*
  for xfile in /var/backups/*.gz; do
    [[ ! -f "${xfile}" ]] && continue
    echo "Delete backup tarball $(@G3 ${xfile})"
    sudo rm -f "${xfile}"
  done

  # 关于 /tmp 和 /var/tmp 目录
  # https://systemd.io/TEMPORARY_DIRECTORIES/

  @zeta:admin:del-all-sys-logs # 清空系统日志文件

  if [[ -n "${ZETA_XSH_OPT_nullglob:-}" ]]; then
    eval   "${ZETA_XSH_OPT_nullglob}"
  fi

  echo "Clean/Reset home trash => $(@G3 ~/.xsession-errors)"
  [ -f ~/.xsession-errors ]  &&  echo > ~/.xsession-errors
}
