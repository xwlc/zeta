# Awesome Application & Library

- https://github.com/durgeshsamariya/awesome-github-profile-readme-templates
- 首次运行 `sudo` 成功后创建 `~/.sudo_as_admin_successful` 文件, `man sudo_root`

```bash
# 关于 Permission denied 的问题
sudo echo XYZ > /some/file
# 输出重定向由 shell 执行, 其非 echo 命令部分, sudo 仅作用于 echo
# 解决方式一: 执行 sudo -i 获取 root 权限
# 解决方式二: echo XYZ | sudo tee /some/file
# 解决方式三: sudo bash -c "echo XYZ > /some/file"

# Shell 脚本的 Here 文档
cat << EOF >> output.file
# The output file contents
EOF

# GBK 编码 => UTF-8 编码
iconv -f GBK -t UTF-8 输入文件 -o 输出文件
```

- Dotfiles
  * https://dotfiles.github.io
  * https://wiki.archlinux.org/title/Dotfiles
  * https://github.com/webpro/awesome-dotfiles


- 系统管理
  - https://github.com/dylanaraps/neofetch
    * `sudo apt install neofetch`
  - https://github.com/linuxmint/timeshift
    * `sudo apt install timeshift`
  - https://htop.dev/index.html
    * `sudo apt install htop` or `pacman -S htop`
    * https://linuxhandbook.com/top-vs-htop
    * https://itsfoss.com/linux-system-monitoring-tools
  - https://gitlab.com/OldManProgrammer/unix-tree
    * `sudo apt install tree`
    * https://www.linuxfromscratch.org/blfs/view/svn/general/tree.html
  - Monitor Disk I/O by [sysstat](https://sysstat.github.io)
    * https://www.baeldung.com/linux/monitor-disk-io
    * `apt show iotop` vs `apt show iotop-c`
    * [iotop](https://github.com/Tomas-M/iotop) 下载源码然后编译安装
    * `sudo apt install sysstat` contains `iostat`, `vmstat`, and `sar`


- 开发工具及库
  - The Ubuntu live CD installer
    * `apt show ubiquity`
  - https://invisible-island.net/ncurses
    * `sudo apt install libncurses-dev`
  - All-in-one Linux command line, like [BusyBox](https://www.busybox.net)
    * https://landley.net/toybox
    * https://github.com/landley/toybox
