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
    @Y9 "$1 "
    if [[ $# -eq 3 ]]; then
      printf "$(@D9 $2) $(@G9 %-10s)" $3
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
  unset -f _triples_ _yinyang_
}
