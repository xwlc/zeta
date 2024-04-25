# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2024 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2024-04-25T07:23:48+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# https://wiki.linuxfoundation.org/lsb/start
# https://wiki.linuxfoundation.org/lsb/fhs-30

# 默认安装 https://www.rsyslog.com
# apt show rsyslog 和 ps aux | grep syslog
# 配置文件 /etc/rsyslog.conf 和 /etc/rsyslog.d/*.conf
#
# 日志管理工具 https://github.com/logrotate/logrotate
# 配置文件 /etc/logrotate.conf 和 /etc/logrotate.d/*

alias admin-journalctl-rm-all-logs='sudo journalctl --rotate --vacuum-time=1s'

function admin-rm-all-system-logs() {
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
  if command -v apt > /dev/null; then
    sudo apt autoclean # 删除无用包缓存 man apt-get
    sudo apt autoremove # 删除自动安装的不再需要的软件包
    if dpkg -l | grep '^rc'; then # 清理软件卸载后残留的配置文件
       dpkg -l | grep '^rc' | awk '{print $2}' | sudo xargs dpkg --purge
    fi
  fi

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

  admin-rm-all-system-logs # 清空系统日志文件

  echo "Clean/Reset home trash => $(@G3 ~/.xsession-errors)"
  [ -f ~/.xsession-errors ] && echo > ~/.xsession-errors
}
