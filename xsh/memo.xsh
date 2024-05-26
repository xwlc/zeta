# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2024 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2024-05-26T12:01:44+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# 10天干 => 甲  乙  丙  丁  戊  己  庚  辛  壬  癸
# 12地支 => 子  丑  寅  卯  辰  巳  午  未  申  酉  戌  亥

# 寅月  卯月  辰月  巳月  午月  未月  申月  酉月  戌月  亥月  子月  丑月
#  03    04    05    06    07    08    09    10    11    12    01    02
# 立春  惊蛰  清明  立夏  芒种  小暑  立秋  白露  寒露  立冬  大雪  小寒  先读上
# 雨水  春分  谷雨  小满  夏至  大暑  处暑  秋分  霜降  小雪  冬至  大寒  后读下

function memo-cultural() {
  function _triples_() {
    case $1 in
      [A-Za-z]*) @Y9 "$1 " ;;
    esac

    if [[ $# -eq 3 ]]; then
      printf "$(@D9 $2) $(@G9 %-10s)" $3
    elif [[ $# -eq 4 ]]; then
      if [[ $3 == x ]]; then
        printf "$(@G3 $1)$(@Y3 $2)$(@D9 "($4)")"
      else
        printf "$(@G3 $1)$(@Y3 $2)$(@B3 $3)$(@D9 "($4)")  "
      fi
    else
      printf "$(@P9 $2) $(@B9 $3) $(@D9 %-4s) $(@Y9 $5) $(@G9 %-10s)" $4 $6
    fi
  }
  function _yinyang_() {
    printf "$1 => "; shift
    local it space='  ' count=0
    [[ $# -eq 26 ]] && space=' '
    for it in $@; do
      if (( count++, count%2 == 0 )); then
        printf "$(@D9 ${it})${space}"
      else
        if [[ ${it} == Δ ]]; then
          # 十二地支 => 十二小时
          printf "[Δ-1, Δ+1]" # 例如 子时 => [23:00, 01:00]
        else
          printf "$(@R9 ${it})${space}"
        fi
      fi
    done
    echo
  }
  echo
  _triples_ Mon. 壹/一 Monday
  _triples_ Tue. 贰/二 Tuesday
  _triples_ Wed. 叁/三 Wednesday; echo
  _triples_ Thu. 肆/四 Thursday
  _triples_ Fri. 伍/五 Friday
  _triples_ Sat. 陆/六 Saturday; echo
  _triples_ Sun. 柒/七 Sunday; echo
  echo
  _triples_ Jan. 01/壹 子 zǐ   大雪 January
  _triples_ Feb. 02/贰 丑 chǒu 小寒 February; echo
  _triples_ Mar. 03/叁 寅 yín  立春 March
  _triples_ Apr. 04/肆 卯 mǎo  惊蛰 April;    echo
  _triples_ May. 05/伍 辰 chén 清明 May
  _triples_ Jun. 06/陆 巳 sì   立夏 June;     echo
  _triples_ Jul. 07/柒 午 wǔ   芒种 July
  _triples_ Aug. 08/捌 未 wèi  小暑 August;   echo
  _triples_ Sep. 09/玖 申 shēn 立秋 September
  _triples_ Oct. 10/拾 酉 yǒu  白露 October;  echo
  _triples_ Nov. 11/〇 戌 xū   寒露 November
  _triples_ Dec. 12/廿 亥 hài  立冬 December; echo
  echo
  echo "易经八卦 => ☯  阳数($(@R3 奇数)) & 阴数($(@D9 偶数))"
  _yinyang_ '天干' 甲  乙  丙  丁  戊  己  庚  辛  壬  癸
  _yinyang_ '地支' 子  丑  寅  卯  辰  巳  午  未  申  酉  戌  亥
  _yinyang_ '生肖' 鼠  牛  虎  兔  龙  蛇  马  羊  猴  鸡  狗  猪
  _yinyang_ '时间' 00  02  04  06  08  10  12  14  16  18  20  22 Δ
  _yinyang_ '字母' A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
  echo
  local count=0  dz cntDZ  tg cntTG=0
  echo -n "干支纪法(组合规律) => ☯  "
  echo -n "($(@R3 奇数))$(@G3 阳干)配$(@R3 阳支) "
  echo    "($(@D9 偶数))$(@B3 阴干)配$(@Y3 阴支)"
  for dz in 子  丑  寅  卯  辰  巳  午  未  申  酉  戌  亥; do
    (( cntDZ++ )); cntTG=0
    for tg in 甲  乙  丙  丁  戊  己  庚  辛  壬  癸; do
      if (( cntTG++, cntTG%2 == cntDZ%2 )); then
        if (( cntTG%2 == 0 )); then
          printf "$(@D9 $(@B3 ${tg})$(@Y3 ${dz}))  "
        else
          printf "$(@R9 $(@G3 ${tg})$(@R3 ${dz}))  "
        fi
      else
        printf "$(@D9 '----')  "
      fi
      (( count++, count%10 == 0 )) && echo
    done
  done
  echo

  local YCWJI="月$(@D9 初)为$(@G3 节)" YZWQI="月$(@D9 中)为$(@Y3 气)"

  local x1="  $(@G3 春) " x2="  $(@R3 夏) "
  local x3="  $(@Y3 秋) " x4="  $(@D9 冬) "

  local x01="  $(@R3 子)  " x02="  $(@C3 丑)  " x03="  $(@R3 寅)  "
  local x04="  $(@C3 卯)  " x05="  $(@R3 辰)  " x06="  $(@C3 巳)  "
  local x07="  $(@R3 午)  " x08="  $(@C3 未)  " x09="  $(@R3 申)  "
  local x10="  $(@C3 酉)  " x11="  $(@R3 戌)  " x12="  $(@C3 亥)  "

  local y01=" $(@G3 立春) " y02=" $(@G3 惊蛰) " y03=" $(@G3 清明) "
  local y04=" $(@R3 立夏) " y05=" $(@R3 芒种) " y06=" $(@R3 小暑) "
  local y07=" $(@Y3 立秋) " y08=" $(@Y3 白露) " y09=" $(@Y3 寒露) "
  local y10=" $(@D9 立冬) " y11=" $(@D9 大雪) " y12=" $(@D9 小寒) "

  local z01=" $(@G3 雨水) " z02=" $(@G3 春分) " z03=" $(@G3 谷雨) "
  local z04=" $(@R3 小满) " z05=" $(@R3 夏至) " z06=" $(@R3 大暑) "
  local z07=" $(@Y3 处暑) " z08=" $(@Y3 秋分) " z09=" $(@Y3 霜降) "
  local z10=" $(@D9 小雪) " z11=" $(@D9 冬至) " z12=" $(@D9 大寒) "

  echo "┌────────────────────────────────────────────────────────────────────────────────────────┐"
  echo "│                             每个月两字, ${YCWJI}, ${YZWQI}                             │"
printf "│         "
_triples_ 春 雨 x 寅; _triples_ 惊 春 x 卯; _triples_ 清 谷 天 辰; printf "                "
_triples_ 夏 满 x 巳; _triples_ 芒 夏 x 午; _triples_ 暑 相 连 未; echo "       │"
printf "│         "
_triples_ 秋 处 x 申; _triples_ 露 秋 x 酉; _triples_ 寒 霜 降 戌; printf "                "
_triples_ 冬 雪 x 亥; _triples_ 雪 冬 x 子; _triples_ 小 大 寒 丑; echo "       │"
  echo "├────┬────────────────────┬────────────────────┬────────────────────┬────────────────────┤"
  echo "│ 季 │       ${x1}        │       ${x2}        │       ${x3}        │       ${x4}        │"
  echo "├────┼──────┬──────┬──────┼──────┬──────┬──────┼──────┬──────┬──────┼──────┬──────┬──────┤"
  echo "│ 月 │${x03}│${x04}│${x05}│${x06}│${x07}│${x08}│${x09}│${x10}│${x11}│${x12}│${x01}│${x02}│"
  echo "├────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┤"
  echo "│ 节 │${y01}│${y02}│${y03}│${y04}│${y05}│${y06}│${y07}│${y08}│${y09}│${y10}│${y11}│${y12}│"
  echo "├────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┤"
  echo "│ 气 │${z01}│${z02}│${z03}│${z04}│${z05}│${z06}│${z07}│${z08}│${z09}│${z10}│${z11}│${z12}│"
  echo "└────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┘"
  unset -f _triples_ _yinyang_
}
