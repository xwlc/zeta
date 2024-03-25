# Bash/Zsh Startup or Shutdown Files

- Interactive & Login

  |  交互式  |  login  |       示例       |
  |:--------:|:-------:|:----------------:|
  | no       | yes     | ?? 不存在 ??     |
  | no       | no      | 执行 Shell 脚本  |
  | yes      | yes     | `ssh localhost`  |
  | yes      | no      | 打开 PC 本地终端 |

# Zsh [Startup/Shutdown](https://zsh.sourceforge.io/Doc/Release/Files.html) Files

- `ZDOTDIR` 未设置时, 默认使用 `HOME`
- 按列从上倒下, 依次按照顺序执行 A, B, C, ...
- Debian/Ubuntu 类系统, `/etc/zsh` 取代 `/etc`

```bash
# +--------------------+--------+----------+------+
# |      Z-Shell       | 交互式 |  交互式  | 脚本 |
# |     Used Envs      | 登陆式 | 非登陆式 |      |
# +--------------------+--------+----------+------+
# |      /etc/zshenv   |    A   |     A    |   A  |
# +--------------------+--------+----------+------+
# | $ZDOTDIR/.zshenv   |    B   |     B    |   B  |
# +--------------------+--------+----------+------+
# |      /etc/zprofile |    C   |          |      |
# +--------------------+--------+----------+------+
# | $ZDOTDIR/.zprofile |    D   |          |      |
# +--------------------+--------+----------+------+
# |      /etc/zshrc    |    E   |     C    |      |
# +--------------------+--------+----------+------+
# | $ZDOTDIR/.zshrc    |    F   |     D    |      |
# +--------------------+--------+----------+------+
# |      /etc/zlogin   |    G   |          |      |
# +--------------------+--------+----------+------+
# | $ZDOTDIR/.zlogin   |    H   |          |      |
# +--------------------+--------+----------+------+
# | $ZDOTDIR/.zlogout  |    I   |          |      |
# +--------------------+--------+----------+------+
# |      /etc/zlogout  |    J   |          |      |
# +--------------------+--------+----------+------+
```

# Bash [Startup/Shutdown](https://www.gnu.org/software/bash/manual/bash.html#Bash-Startup-Files) Files

- Read down appropriate column, executes A, then B, then C, etc.
- The (A) or (B3) means it is sourced by the primary file A or B3
- The B1, B2, B3 means it executes only the first of those files found.

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
