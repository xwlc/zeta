# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2024 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2024-06-17T10:34:50+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# NOTE `which` can not found alias or shell function
function @zeta:xsh:has-cmd() {  command -v "$1" > /dev/null 2>&1; }
function @zeta:xsh:no-cmd() { ! command -v "$1" > /dev/null 2>&1; }

function zeta-required-cmd() {
  if @zeta:xsh:no-cmd "$1"; then # 红色 \e[31m
    printf "zeta: required \e[31m$1\e[0m (command not found)\n" >&2; return 1
  fi
}

# https://www.binarytides.com/linux-command-to-check-distro/
# -> uname, lsb_release
# -> cat /proc/version
#    contains info about kernel and distro
# -> Ubuntu/Debian Based      CentOS/Fedora Based
#    cat /etc/issue           /etc/centos-release
#    cat /etc/issue.net       /etc/redhat-release
#    cat /etc/os-release      /etc/system-release
#    cat /etc/lsb-release     cat /etc/lsb-release
# -> Portable Command
#    uname -a || lsb_release -a
#    cat /etc/[A-Za-z]*[_-][vr]e[rl]*
#    cat /etc/*-release | uniq -u
#    cat /etc/*version /etc/*release /proc/version* | uniq -u

function @zeta:host:is-macos()        { false; }

function @zeta:host:is-linux()        { false; }
function @zeta:host:is-android()      { false; }
function @zeta:host:is-arch()         { false; }
function @zeta:host:is-debian()       { false; }
function @zeta:host:is-ubuntu()       { false; }

function @zeta:host:is-windows()      { false; }
function @zeta:host:is-msys()         { false; }
function @zeta:host:is-mingw()        { false; }
function @zeta:host:is-cygwin()       { false; }

function @zeta:host:is-bsd()          { false; }
function @zeta:host:is-netbsd()       { false; }
function @zeta:host:is-freebsd()      { false; }

function @zeta:host:is-illumos()      { false; }
function @zeta:host:is-dragonfly()    { false; }

declare HOST_CPU_ID  HOST_DISTRO  HOST_OS_ABI
HOST_CPU_ID="$(uname -m)"
HOST_DISTRO="$(uname -s)"

function @zeta:xsh:init-host-triplet() {
  if [[ "${HOST_DISTRO}" == Linux ]]; then
    [[ "$(uname -o)" == Android ]] && HOST_DISTRO=Android
  elif [[ "${HOST_DISTRO}" == Darwin ]]; then
    if [[ "${HOST_CPU_ID}" == i386 ]]; then
      # Handling i386 compatibility mode in macOS version <10.15
      # Starting from 10.15, macOS explicitly bans all i386 binaries
      # Avoid `sysctl: unknown oid` stderr output and/or non-zero exit code
      if sysctl hw.optional.x86_64 2> /dev/null || true | grep -q ': 1'; then
        HOST_CPU_ID=x86_64
      fi
    elif [[ "${HOST_CPU_ID}" == x86_64 ]]; then
      # Handling x86-64 compatibility mode, a.k.a. Rosetta 2
      # in newer macOS versions (>=11) running on arm64-based Macs
      # Rosetta 2 is built exclusively for x86-64 and cannot run i386 binaries.
      # Avoid `sysctl: unknown oid` stderr output and/or non-zero exit code.
      if sysctl hw.optional.arm64 2> /dev/null || true | grep -q ': 1'; then
        HOST_CPU_ID=arm64
      fi
    fi
  elif [[ "${HOST_DISTRO}" == SunOS ]]; then
    # Both Solaris and illumos announce as "SunOS" in `uname -s`
    [[ "$(uname -o)" == illumos ]] && HOST_DISTRO=illumos
    # illumos `uname -m` reports i86pc for both x86 32-/64-(bit)
    # Check for the native instruction set on the running kernel
    [[ "${HOST_CPU_ID}" == i86pc ]] && HOST_CPU_ID="$(isainfo -n)"
  fi

  # 环境变量 HOSTTYPE, OSTYPE, MACHTYPE, HOSTNAME
  case "${HOST_DISTRO}" in
    Darwin)     HOST_DISTRO=macos     ;;

    Linux)      HOST_DISTRO=linux     ;;
    Android)    HOST_DISTRO=android   ;;

    MSYS*)      HOST_DISTRO=msys      ;;
    MINGW*)     HOST_DISTRO=mingw     ;;
    CYGWIN*)    HOST_DISTRO=cygwin    ;;
    Windows_NT) HOST_DISTRO=windows   ;;

    NetBSD)     HOST_DISTRO=netbsd    ;;
    FreeBSD)    HOST_DISTRO=freebsd   ;;

    illumos)    HOST_DISTRO=illumos   ;;
    DragonFly)  HOST_DISTRO=dragonfly ;;
  esac

  eval "function @zeta:host:is-${HOST_DISTRO}() { true; }"

  if [[ "${HOST_DISTRO}" == "netbsd" || "${HOST_DISTRO}" == "freebsd" ]]; then
    function @zeta:host:is-bsd() { true; }
  fi

  case "${HOST_DISTRO}" in
    msys|mingw|cygwin)
      function @zeta:host:is-windows() { true; }
      HOST_DISTRO=windows; HOST_OS_ABI=${HOST_DISTRO}
    ;;
  esac

  if @zeta:host:is-linux && @zeta:xsh:has-cmd lsb_release; then
    local linuxDistroName=$(lsb_release -is)
    case "${linuxDistroName}" in
        Arch) HOST_DISTRO=arch   ;;
      Debian) HOST_DISTRO=debian ;;
      Ubuntu) HOST_DISTRO=ubuntu ;;
    esac

    # Linux 发行版 function @zeta:host:is-arch() { true; }
    eval "function @zeta:host:is-${HOST_DISTRO}() { true; }"

    # https://musl.libc.org
    ldd --version 2>&1 | grep -q 'musl' && HOST_OS_ABI="musl"

    # ELF 可执行文件格式 https://man.archlinux.org/man/elf.5.en
    # https://www.kernel.org/doc/html/latest/filesystems/proc.html
    # Architecture detection without dependencies beyond coreutils
    # NOTE `printf` like dash only supports octal escape sequences
    if test -L /proc/self/exe; then
      # ELF file magic 4-bytes header is \x7fELF
      [[ "$(head -c 4 /proc/self/exe)" == "$(printf '\177ELF')" ]] && {
        local _bits_=$(head -c 5 /proc/self/exe | tail -c 1)
        if [[ "${_bits_}" == "$(printf '\001')" ]]; then
          _bits_=32 # 0x01 表示 32-bit 体系结构
        elif [[ "${_bits_}" == "$(printf '\002')" ]]; then
          _bits_=64 # 0x02 表示 64-bit 体系结构
        fi

        # 数据<低字节>内存<低地址>  数据 0x12345678 => 内存 78 53 34 12
        # 数据<高字节>内存<低地址>  数据 0x12345678 => 内存 12 34 56 78
        local _endian_="$(head -c 6 /proc/self/exe | tail -c 1)"
        if [[ "${_endian_}" == "$(printf '\001')" ]]; then
          _endian_=le # 0x01 小端序 little-endian
        elif [[ "${_endian_}" == "$(printf '\002')" ]]; then
          _endian_=be # 0x02 大端序 big-endian => 网络字节顺序
        fi

        if [[ -n "${_bits_}" && -n "${_endian_}" ]]; then
          local _xinfo_="${_bits_}${_endian_}"
        fi
      }
    fi
  fi

  # https://alt.fedoraproject.org/alt
  # 1978 -> X86, 1981 -> MIPS, 1983 -> ARM, 1991 -> PowerPC
  case "${HOST_CPU_ID}" in
    # https://www.sandpile.org/x86/cpuid.htm
    i386|i486|i586|i686|i786|x86)   HOST_CPU_ID=x86 ;;
    x86_64|x86-64|amd64|x64)        HOST_CPU_ID=x64 ;;
    # IBM zSystems s390x Architecture
    s390x)                          HOST_CPU_ID=s390x ;;
    # https://apple.fandom.com/wiki/PowerPC
    ppc*)                           HOST_CPU_ID=ppc${_xinfo_}   ;;
    # https://mips.com
    mips*)                          HOST_CPU_ID=mips${_xinfo_}  ;;
    # https://riscv.org/technical/specifications
    riscv*)                         HOST_CPU_ID=riscv${_xinfo_} ;;
    # 龙架构 https://www.loongson.cn/system/loongarch
    loongarch*)                     HOST_CPU_ID=lsa${_xinfo_}   ;;
    # https://developer.arm.com/architectures
    xscale|arm*|armv*l|aarch*)      HOST_CPU_ID=arm${_xinfo_}   ;;
  esac
}

# $(uname | tr '[:upper:]' '[:lower:]')
# $(uname -s) -> WindowsNT, Darwin, Linux, FreeBSD, SunOS
#
# 正则比较语法: 字符串变量 =~ 正则(必须右侧)常量
# [[ "${OSTYPE}" =~ ^linux  ]] 和 [[ "${OSTYPE}" =~ ^darwin ]]

@zeta:xsh:init-host-triplet
unset -f @zeta:xsh:init-host-triplet

# $ gcc -dumpmachine
# https://wiki.osdev.org/Target_Triplet
# https://clang.llvm.org/docs/CrossCompilation.html
# https://doc.rust-lang.org/nightly/rustc/platform-support.html

# 处理器-发行商-操作系统
#   HOST_CPU_ID = x86_64, i386, arm, thumb, mips
#   HOST_DISTRO = none, windows, macos, linux, android
#                 arch, debian, ubuntu, freebsd, netbsd
#   HOST_OS_ABI = gnu, musl, msvc, mysy, cygwin, mingw
function host-triplet() {
  if [[ -n "${HOST_OS_ABI}" ]]; then
    echo "${HOST_CPU_ID}-${HOST_DISTRO}-${HOST_OS_ABI}"
  else
    echo "${HOST_CPU_ID}-${HOST_DISTRO}"
  fi
}
