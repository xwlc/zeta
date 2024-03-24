# 备忘说明

- 首次运行 `sudo` 成功后则创建 `~/.sudo_as_admin_successful` 文件, `man sudo_root`

```shell
# 查看本机网卡/IP信息
ip addr

# 查看屏幕可用分辨率
xrandr

# 查看当前分辨率
xrandr | grep '*'
xdpyinfo  | grep 'dimensions:'

# 关于 Permission denied 的问题
sudo echo XYZ > /some/file
# 输出重定向由 shell 执行, 其非 echo 命令部分, sudo 仅作用于 echo
# 解决方式一: 执行 sudo -i 获取 root 权限
# 解决方式二: echo XYZ | sudo tee /some/file
# 解决方式三: sudo bash -c "echo XYZ > /some/file"

# 系统恢复命令
sudo timeshift --list
sudo timeshift --list-devices
sudo timeshift \
  --restore \
  --skip-grub \
  --target /dev/nvme0n1p4 \
  --snapshot '2024-02-22_08-20-50'

# GBK 编码 => UTF-8 编码
iconv -f GBK -t UTF-8 输入文件 -o 输出文件

# 重命名 Github 分支后
# The default branch has been renamed! master is now named trunk, If you
# have local clone, you can update it by running the following commands.
git branch -m master trunk
git fetch origin
git branch -u origin/trunk trunk
git remote set-head origin -a

# 如何删除本地 git b -a 显示的
remotes/origin/master
```
