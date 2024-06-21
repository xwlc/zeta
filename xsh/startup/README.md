# Bash/Zsh Startup or Shutdown Files

- Interactive(交互) & Login(登陆)

  |  交互  |  登陆  |       示例       |
  |:------:|:------:|:----------------:|
  |   NO   |   NO   |   执行脚本文件   |
  |   NO   |   OK   |   ?? 不存在 ??   |
  |   OK   |   NO   | 打开 PC 本地终端 |
  |   OK   |   OK   | `ssh  localhost` |

## Zsh Startup Files

- `ZDOTDIR` 未设置时, 默认使用 `HOME`
- 按列从上倒下, 依次按照顺序执行 A, B, C, ...
- Debian/Ubuntu 类系统, `/etc/zsh` 取代 `/etc`
- https://zsh.sourceforge.io/Doc/Release/Files.html

```bash
# +--------+----------+------+
# | 交互式 |  交互式  |  脚  |
# |  登陆  |  非登陆  |  本  |
# +--------+----------+------+
# |    A   |     A    |   A  | /etc/zshenv
# +--------+----------+------+
# |    B   |     B    |   B  | $ZDOTDIR/.zshenv
# +--------+----------+------+
# |    C   |          |      | /etc/zprofile
# +--------+----------+------+
# |    D   |          |      | $ZDOTDIR/.zprofile
# +--------+----------+------+
# |    E   |     C    |      | /etc/zshrc
# +--------+----------+------+
# |    F   |     D    |      | $ZDOTDIR/.zshrc
# +--------+----------+------+
# |    G   |          |      | /etc/zlogin
# +--------+----------+------+
# |    H   |          |      | $ZDOTDIR/.zlogin
# +--------+----------+------+
# |    I   |          |      | $ZDOTDIR/.zlogout
# +--------+----------+------+
# |    J   |          |      | /etc/zlogout
# +--------+----------+------+
```

# Bash Startup Files

- Read down appropriate column, executes A, then B, then C, etc.
- The (A) or (B3) means it is sourced by the primary file A or B3
- The B1, B2, B3 means it executes only the first of those files found
- https://www.gnu.org/software/bash/manual/bash.html#Bash-Startup-Files

```bash
# +-----------+-----------+------+
# |Interactive|Interactive|Script|
# |   Login   | Non-Login |      |
# +-----------+-----------+------+
# |           |           |   A  | BASH_ENV
# +-----------+-----------+------+
# |     A     |           |      | /etc/profile
# +-----------+-----------+------+
# |    (A)    |     A     |      | /etc/bash.bashrc
# +-----------+-----------+------+
# |    (A)    |           |      | /etc/profile.d/*.sh
# +-----------+-----------+------+
# |    B1     |           |      | ~/.bash_profile
# +-----------+-----------+------+
# |    B2     |           |      | ~/.bash_login
# +-----------+-----------+------+
# |    B3     |           |      | ~/.profile
# +-----------+-----------+------+
# |   (B3)    |     B     |      | ~/.bashrc
# +-----------+-----------+------+
# |    C      |           |      | ~/.bash_logout
# +-----------+-----------+------+
```
