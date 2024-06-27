# Newborn Programming Languages

- https://go.dev
- https://nim-lang.org
- https://www.rust-lang.org

# Favor Applications

  - 硬件驱动 https://gitlab.com/linuxhw/hw-probe
  - 系统备份 https://github.com/linuxmint/timeshift
  - 系统信息 https://github.com/dylanaraps/neofetch

  - 监控进程 https://htop.dev/index.html
  - 显卡性能 https://github.com/Syllo/nvtop
  - 磁盘 IO  https://sysstat.github.io
  - IO 监控  https://github.com/Tomas-M/iotop

  - 逆向工程 https://x64dbg.com
  - Hex 工具 https://github.com/sharkdp/hexyl
  - Hex 工具 https://github.com/WerWolv/ImHex

  - 内核调试 https://github.com/KDAB/hotspot
  - 网络调试 https://github.com/nxtrace/NTrace-core
  - 串口调试 https://github.com/Serial-Studio/Serial-Studio

  - 字体工具 https://github.com/fontforge/fontforge
  - 翻译工具 https://poedit.net
  - 工程文档 https://github.com/marktext/marktext
  - GIF 压缩 https://docs.rs/gifski/latest/gifski

  - 模糊搜索 https://github.com/junegunn/fzf
  - 文本比较 https://github.com/ymattw/ydiff
  - 文本比较 https://github.com/so-fancy/diff-so-fancy
  - 分页工具 https://github.com/noborus/ov
  - 分页工具 https://github.com/dandavison/delta

  - 版本控制 https://github.com/romkatv/gitstatus
  - 版本控制 https://github.com/jesseduffield/lazygit

  - https://dos2unix.sourceforge.io
  - https://gitlab.com/OldManProgrammer/unix-tree
  - https://www.linuxfromscratch.org/blfs/view/svn/general/tree.html

# 开发模块库

  - https://code.launchpad.net/ubiquity
    * Ubuntu live ISO 安装库 `apt show ubiquity`

  - https://invisible-island.net/ncurses/ncurses.html
    * 终端 TUI 开发库 `apt show libncurses-dev`

# FAQs

- Awesome Dotfiles
  * https://dotfiles.github.io
  * https://wiki.archlinux.org/title/Dotfiles
  * https://github.com/webpro/awesome-dotfiles

- https://man.archlinux.org/man/manpath.5
- https://github.com/durgeshsamariya/awesome-github-profile-readme-templates
- 首次运行 `sudo` 成功后创建 `~/.sudo_as_admin_successful` 文件, `man sudo_root`

```bash
# GBK 编码 => UTF-8 编码
iconv -f GBK -t UTF-8 输入文件 -o 输出文件

# Shell 脚本 HERE 文档
cat << EOF >> output.file
# The output file contents
EOF

# 关于 sudo Permission denied 的问题
# 解决方式一: 执行 sudo -i 获取 root 权限
# 解决方式二: echo XYZ | sudo tee /some/file
# 解决方式三: sudo bash -c "echo XYZ > /some/file"
# NOTE 重定向由 shell 执行, 非 echo 命令, sudo 仅作用于 echo 命令
sudo echo XYZ > /some/file
```
