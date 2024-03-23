# Disk

- https://wiki.archlinux.org/title/Fstab
- https://wiki.archlinux.org/title/Parted
- https://wiki.archlinux.org/title/GPT_fdisk
- https://www.rodsbooks.com/gdisk/index.html

- https://wiki.debian.org/udev
- https://wiki.archlinux.org/title/Udev
- https://www.reactivated.net/writing_udev_rules.html
- https://wiki.archlinux.org/title/Persistent_block_device_naming

- http://storaged.org
- https://github.com/storaged-project/udisks
- https://wiki.archlinux.org/title/Udisks
- https://www.freedesktop.org/wiki/Software/udisks
- https://wiki.archlinux.org/title/Solid_state_drive
- https://wiki.archlinux.org/title/Solid_state_drive/NVMe

- `~/.config/kded_device_automounterrc`
  * `[System Settings] -> [Removable Storage] -> [Removable Devices]`
  * `/dev/disk/by-uuid/*` 替换 `/org/freedesktop/UDisks2/block_devices/*`

```shell
# => 内核支持(加载)的文件系统
modinfo ntfs
modinfo ntfs3
modinfo exfat

# => 查询硬盘信息
sudo blkid

sudo parted --list
cat /proc/partitions
sudo fdisk -l /dev/nvme0n1
sudo gdisk -l /dev/nvme0n1

lsblk --help
lsblk -f # lsblk -t
lsblk -o NAME,FSTYPE,LABEL,FSSIZE,FSUSE%,FSUSED,PARTLABEL,MOUNTPOINT  /dev/nvme0n1
lsblk -o NAME,FSTYPE,FSSIZE,FSUSE%,LABEL,UUID,PARTLABEL,PARTUUID      /dev/nvme0n1

udisksctl status
udisksctl info -b /dev/nvme0n1p3
udevadm info --name=/dev/nvme0n1p3
journalctl -b | grep "udisks daemon version"

# => 磁盘 I/O 监控
# http://guichaz.free.fr/iotop
sudo apt install iotop

# 内存及 SWAP 状态
free
cat /proc/swaps

# 避免频繁使用 SWAP 空间
# https://help.ubuntu.com/community/SwapFaq
# https://github.com/systemd/zram-generator

# swappiness 控制 RAM 数据转移到 SWAP 的倾向性(百分比)
# 0   -> 尽量避免将 RAM 数据转移到 SWAP 分区/文件
# 100 -> 尽量    将 RAM 数据转移到 SWAP 分区/文件
# 减小 swappiness 将提高系统性能(RAM 数据读取更快)
cat /proc/sys/vm/swappiness   # Ubuntu 默认值 60
sudo sysctl vm.swappiness=10  # 临时修改, 仅本次有效
# 永久性修改 => 添加 vm.swappiness=10
sudo nano /etc/sysctl.conf
```

## NVMe 固态磁盘

- https://www.kingston.com.cn/cn/blog/pc-performance/overprovisioning
- https://www.kingston.com.cn/cn/blog/pc-performance/difference-between-slc-mlc-tlc-3d-nand
- https://nvmexpress.org/open-source-nvme-management-utility-nvme-command-line-interface-nvme-cli
- https://semiconductor.samsung.com/cn/consumer-storage/support/faqs/internalssd-product-information

```bash
# NVMe SSD 固态磁盘管理
# https://github.com/linux-nvme/nvme-cli
sudo apt install nvme-cli
# 显示系统 NVMe 固态磁盘
sudo nvme list
# 检查 NVMe 控制器及支持的功能
sudo nvme id-ctrl --human-readable /dev/nvme0

sudo apt install smartmontools
# 检查 NVMe 健康状态 S.M.A.R.T. 信息
sudo nvme smart-log /dev/nvme0
sudo smartctl --all /dev/nvme0
# 显示 S.M.A.R.T. 错误日志信息
sudo smartctl -l error /dev/nvme0

# 检查 firmware 日志
sudo nvme fw-log    /dev/nvme0
# 显示 NVMe 错误日志
sudo nvme error-log /dev/nvme0
```
