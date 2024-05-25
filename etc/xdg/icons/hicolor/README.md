# Favor Desktop Icons

- https://wiki.archlinux.org/title/Icons
- https://specifications.freedesktop.org/icon-naming-spec/latest
- https://specifications.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html

- 更新目录下图标文件后
  * 用户 Logout, Login 后系统相关菜单图标才能显示
  * 重启文件管理器后相关 .desktop 文件图标才能显示
    例如, 关闭再打开 Dolphin 资源管理器

```bash
# 系统图标文件存储位置, 修改后需要更新系统图标缓存
/usr/share/mime/
/usr/share/icons/hicolor/

# 相关命令更新
update-mime
update-mime-database
update-icon-caches
gtk-update-icon-cache
```
