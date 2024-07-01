#!/usr/bin/env bash

THIS_AFP="$(realpath "${0}")"        # 当前文件绝对路径(含名)
THIS_FNO="$(basename "${THIS_AFP}")" # 仅包含当前文件的文件名
THIS_DIR="$(dirname  "${THIS_AFP}")" # 当前文件所在的绝对路径

sudo cp "${THIS_DIR}/journald.conf" /etc/systemd/journald.conf

exit

################
### 备忘信息 ###
################

if false; then
  man journald.conf # 配置文件语法
  systemd-analyze cat-config systemd/journald.conf # 显示配置
  journalctl --disk-usage # 日志占有存储空间大小
fi

############################
### 编译时的设置的默认值 ###
############################
Storage=auto
Compress=yes
Seal=yes
SplitMode=uid
SyncIntervalSec=5m
RateLimitIntervalSec=30s
RateLimitBurst=10000

SystemMaxUse=
SystemKeepFree=
SystemMaxFileSize=
SystemMaxFiles=100

RuntimeMaxUse=
RuntimeKeepFree=
RuntimeMaxFileSize=
RuntimeMaxFiles=100

MaxRetentionSec=
MaxFileSec=1month

ForwardToKMsg=no
ForwardToWall=yes
ForwardToSyslog=no
ForwardToConsole=no
TTYPath=/dev/console

MaxLevelStore=debug
MaxLevelSyslog=debug
MaxLevelWall=emerg
MaxLevelKMsg=notice
MaxLevelConsole=info

Audit=yes
ReadKMsg=yes
LineMax=48K
