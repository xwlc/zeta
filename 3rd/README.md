# FAQs + Memo

- Awesome
  * https://github.com/ibraheemdev/modern-unix
  * https://dotfiles.github.io
  * https://wiki.archlinux.org/title/Dotfiles
  * https://github.com/webpro/awesome-dotfiles
  * https://github.com/durgeshsamariya/awesome-github-profile-readme-templates

- https://man.archlinux.org/man/manpath.5
- 首次执行 `sudo` 后创建 `~/.sudo_as_admin_successful` 文件, `man sudo_root`

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

## Favor Tools

```bash
# apt search   ^gcc-[0-9][0-9]$
# apt search ^clang-[0-9][0-9]$
sudo apt install  gcc  clang  git
sudo apt install  build-essential

# APT 包文件搜索/显示工具
sudo apt install apt-file
sudo apt-file update # 更新缓存

# 默认 shell 切换到 Zsh
IS_DEFAULT_ZSH="$(cat /etc/passwd | grep ${USER} | grep zsh)"
if [[ -z "${IS_DEFAULT_ZSH}" ]]; then
  sudo apt install zsh; chsh --shell /usr/bin/zsh
fi

sudo apt install bcompare;        sudo apt install kompare
sudo apt install neovim;          sudo apt install curl wget
sudo apt install 7zip 7zip-rar;   sudo apt install microsoft-edge-stable
```

## 硬件/驱动/系统

- 检测 CPU 信息 https://www.cpuid.com
  * https://github.com/klauspost/cpuid
  * https://www.etallen.com/cpuid.html
  * https://www.sandpile.org/x86/cpuid.htm
  * https://github.com/InstLatx64/InstLatx64

- 驱动检测 https://gitlab.com/linuxhw/hw-probe
- 系统信息 https://github.com/dylanaraps/neofetch
- 系统备份 https://github.com/linuxmint/timeshift

- 磁盘工具 https://www.rodsbooks.com/gdisk
  * https://sourceforge.net/projects/gptfdisk/files/gptfdisk
  * `apt show gdisk`
- 磁盘工具 https://github.com/storaged-project
  * https://www.freedesktop.org/wiki/Software/udisks
  * `apt show udisks2`
- 磁盘工具 https://nvmexpress.org
  * https://github.com/linux-nvme/nvme-cli
  * `apt show nvme-cli`
- 磁盘工具 https://www.smartmontools.org
  * `apt show smartmontools`

- 监控进程 https://htop.dev/index.html
  * https://github.com/htop-dev/htop
  * `apt show htop`
- 显卡性能 https://github.com/Syllo/nvtop
- 磁盘 IO  https://sysstat.github.io
- IO 监控  https://github.com/Tomas-M/iotop
  * 下载 deb 解压提取 sbin/iotop-c 文件
  * `apt show iotop-c`
- IO 监控  http://guichaz.free.fr/iotop
  * https://repo.or.cz/w/iotop.git
  * `apt show iotop`

## 工具/组件

- https://cmake.org/files
- https://mirrors.ustc.edu.cn/golang
- https://www.newbe.pro/Mirrors/Mirrors-Hugo
- https://mirrors.tuna.tsinghua.edu.cn/nodejs-release
- https://jdk.java.net
- https://www.oracle.com/java/technologies/downloads

- 自动补全 https://github.com/zsh-users/zsh-completions
- 自动补全 https://github.com/scop/bash-completion
  * `apt show bash-completion`

- 版本控制 https://github.com/romkatv/gitstatus
- 版本控制 https://github.com/jesseduffield/lazygit

- 内核调试 https://github.com/KDAB/hotspot
- 网络调试 https://github.com/nxtrace/NTrace-core
- 串口调试 https://github.com/Serial-Studio/Serial-Studio

- https://ccache.dev
- https://dos2unix.sourceforge.io
- https://sourceforge.net/p/cppcheck
- https://astyle.sourceforge.net/notes.html
- https://gitlab.com/OldManProgrammer/unix-tree
  * https://github.com/Old-Man-Programmer/tree
  * https://oldmanprogrammer.net/source.php?dir=projects/tree
  * https://www.linuxfromscratch.org/blfs/view/svn/general/tree.html
- https://sourceware.org/elfutils

- 逆向工程 https://x64dbg.com
- Hex 工具 https://github.com/sharkdp/hexyl
  * 下载 deb 解压提取 bin/hexyl 文件
  * `apt show hexyl`
- Hex 工具 https://github.com/WerWolv/ImHex
- Hex 工具 https://apps.kde.org/en/okteta

- 模糊搜索 https://github.com/junegunn/fzf
  * `apt show fzf`
- 搜索工具 https://beyondgrep.com
  * https://github.com/beyondgrep/ack3
  * `apt show ack`
- TUI 比较 https://github.com/ymattw/ydiff
- TUI 比较 https://github.com/so-fancy/diff-so-fancy
- 分页工具 https://github.com/noborus/ov
- 分页工具 https://github.com/dandavison/delta

- 翻译工具 https://poedit.net
- 文档工具 https://asciidoctor.org
  * `apt show asciidoctor`
- 文档工具 https://github.com/marktext/marktext
- 字体工具 https://github.com/fontforge/fontforge

- GIF 压缩 https://gif.ski
  * https://docs.rs/gifski/latest/gifski
  * https://github.com/ImageOptim/gifski
- SVG 工具 https://inkscape.org/zh-hans
- 3D/2D 工具 https://www.blender.org

# 模块库

- Qt 图形库
  * Qt Creator https://tracker.debian.org/pkg/qtcreator
  * Qt Creator https://archlinux.org/packages/extra/x86_64/qtcreator

  * Qt 5 https://archlinux.org/packages/extra/x86_64/qt5-base
  * Qt 5 https://tracker.debian.org/pkg/qtbase-opensource-src

  * Qt 6 https://archlinux.org/packages/extra/x86_64/qt6-base
  * Qt 6 https://tracker.debian.org/pkg/qt6-base

- https://code.launchpad.net/ubiquity
  * Ubuntu Live ISO 安装库 `apt show ubiquity`

- https://invisible-island.net/ncurses/ncurses.html
  * 终端 TUI 开发库 `apt show libncurses-dev`
