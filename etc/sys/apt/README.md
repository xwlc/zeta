# APT

- [How to upgrade to the newer distribution version](http://help.ubuntu.com/community/UpgradeNotes)

- 关于 `/etc/apt/sources.list` 文件 [CodeName](https://wiki.ubuntu.com/Releases)

  ```
  CodeName              Main Packages
  CodeName-updates      Recommended Updates
  CodeName-security     Important Security Updates
  CodeName-backports    HWE Versions, Not Well Tested
  CodeName-proposed     Pre-released Software/Packages

  main                  Ubuntu Team & Security Team 维护/更新
  restricted            受法律和版权保护, 设备驱动/专利软件
  universe              社区支持维护的开源软件
  multiverse            受法律和版权保护, 非开源软件
  ```

- [Microsoft Edge](https://www.microsoft.com/en-us/edge/download?form=MA13FJ)
  * `/etc/apt/trusted.gpg.d/microsoft-edge.gpg`
  * `/etc/apt/sources.list.d/microsoft-edge.list`

- [Latest Stable Git Version](https://git-scm.com/download/linux)
  * `/etc/apt/trusted.gpg.d/git-core-ppa.gpg`
  * `/etc/apt/sources.list.d/git-core-ppa.list`

- [Beyond Compare](https://www.scootersoftware.com/download)
  * `/usr/share/keyrings/bcompare4.gpg`
  * `/etc/apt/sources.list.d/bcompare4.list`

- [XanMod](https://xanmod.org) Kernel
  * `/usr/share/keyrings/xanmod-kernel.gpg`
  * `/etc/apt/sources.list.d/xanmod-kernel.list`
  * 显示包信息 `apt show linux-xanmod-lts-x64v3`
