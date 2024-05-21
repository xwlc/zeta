# `update-grub` or `grub-mkconfig` command hooks scripts

All executable files in this folder are processed in the shell-expansion order.

The number namespace **in-between** is configurable by the system administrator.
For example, you can add an entry to boot another OS as `02_os1`, `12_os2`, etc,
depending on the position you want the entries to occupy in the generated menus.

Run command `apt-file search /etc/grub.d/` to show orginal default hook-scripts.

- 0[0-9]-*: GRUB reserved
  * `00-grub-common`
  * `01-grub-header`
  * `02-grub-themes`

- 1[0-9]-*: The OS boot entries
  * `10-prober-windows`
  * `11-prober-macos`
  * `12-prober-linux`

- 2[0-9]-*: Third party apps/utils
  * `20-bios-firmware`
  * `20-uefi-firmware`
  * `21-util-memtests`
