# SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
# SPDX-FileCopyrightText: 2024 Charles Wong <charlie-wong@outlook.com>
# Created By: Charles Wong 2024-05-26T12:01:44+08:00 Asia/Shanghai
# Repository: https://github.com/xwlc/zeta

# 10天干 => 甲  乙  丙  丁  戊  己  庚  辛  壬  癸
# 12地支 => 子  丑  寅  卯  辰  巳  午  未  申  酉  戌  亥

#  寅月   卯月   辰月   巳月   午月   未月   申月   酉月   戌月   亥月   子月   丑月
#   03     04     05     06     07     08     09     10     11     12     01     02
# 立春03 惊蛰05 清明07 立夏09 芒种11 小暑13 立秋15 白露17 寒露19 立冬21 大雪23 小寒01
# 雨水04 春分06 谷雨08 小满10 夏至12 大暑14 处暑16 秋分18 霜降20 小雪22 冬至24 大寒02

# rb => rainbow 彩虹色
function @zeta:memo:msgrb() {
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

# tj => TaiJi/YinYang 双色
function @zeta:memo:msgtj() {
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

function memo-times() {
  echo
  @zeta:memo:msgrb Mon. 壹/一 Monday
  @zeta:memo:msgrb Tue. 贰/二 Tuesday
  @zeta:memo:msgrb Wed. 叁/三 Wednesday; echo
  @zeta:memo:msgrb Thu. 肆/四 Thursday
  @zeta:memo:msgrb Fri. 伍/五 Friday
  @zeta:memo:msgrb Sat. 陆/六 Saturday; echo
  @zeta:memo:msgrb Sun. 柒/七 Sunday; echo
  echo
  @zeta:memo:msgrb Jan. 01/壹 子 zǐ   大雪 January
  @zeta:memo:msgrb Feb. 02/贰 丑 chǒu 小寒 February; echo
  @zeta:memo:msgrb Mar. 03/叁 寅 yín  立春 March
  @zeta:memo:msgrb Apr. 04/肆 卯 mǎo  惊蛰 April;    echo
  @zeta:memo:msgrb May. 05/伍 辰 chén 清明 May
  @zeta:memo:msgrb Jun. 06/陆 巳 sì   立夏 June;     echo
  @zeta:memo:msgrb Jul. 07/柒 午 wǔ   芒种 July
  @zeta:memo:msgrb Aug. 08/捌 未 wèi  小暑 August;   echo
  @zeta:memo:msgrb Sep. 09/玖 申 shēn 立秋 September
  @zeta:memo:msgrb Oct. 10/拾 酉 yǒu  白露 October;  echo
  @zeta:memo:msgrb Nov. 11/〇 戌 xū   寒露 November
  @zeta:memo:msgrb Dec. 12/廿 亥 hài  立冬 December; echo
  echo
}

function memo-cultural() {
  echo "易经八卦 => ☯  阳数($(@R3 奇数)) & 阴数($(@D9 偶数))"
  @zeta:memo:msgtj '天干' 甲  乙  丙  丁  戊  己  庚  辛  壬  癸
  @zeta:memo:msgtj '地支' 子  丑  寅  卯  辰  巳  午  未  申  酉  戌  亥
  @zeta:memo:msgtj '生肖' 鼠  牛  虎  兔  龙  蛇  马  羊  猴  鸡  狗  猪
  @zeta:memo:msgtj '时间' 00  02  04  06  08  10  12  14  16  18  20  22 Δ
  @zeta:memo:msgtj '字母' A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
  echo

  echo -n "干支纪法(组合规律) => ☯  "
  echo -n "($(@R3 奇数))$(@G3 阳干)配$(@R3 阳支) "
  echo    "($(@D9 偶数))$(@B3 阴干)配$(@Y3 阴支)"

  local jiazi=1 tgidx dzidx
  local GAN=(甲  乙  丙  丁  戊  己  庚  辛  壬  癸)
  local ZHI=(子  丑  寅  卯  辰  巳  午  未  申  酉  戌  亥)

  for jiazi in {0..59}; do
    (( jiazi++, tgidx=jiazi%10, dzidx=jiazi%12 ))
    if [[ -n "${ZSH_VERSION}" ]]; then
      (( tgidx == 0 )) && (( tgidx=10 ))
      (( dzidx == 0 )) && (( dzidx=12 ))
    fi
    if (( tgidx%2 == 0 )); then
      printf "$(@B3 ${GAN[${tgidx}]})$(@Y3 ${ZHI[${dzidx}]})/%02d  " ${jiazi}
    else
      printf "$(@G3 ${GAN[${tgidx}]})$(@R3 ${ZHI[${dzidx}]})/%02d  " ${jiazi}
    fi
    (( jiazi%10 == 0 )) && echo
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
  local y07=" $(@B3 立秋) " y08=" $(@B3 白露) " y09=" $(@B3 寒露) "
  local y10=" $(@D9 立冬) " y11=" $(@D9 大雪) " y12=" $(@D9 小寒) "

  local z01=" $(@G3 雨水) " z02=" $(@G3 春分) " z03=" $(@G3 谷雨) "
  local z04=" $(@R3 小满) " z05=" $(@R3 夏至) " z06=" $(@R3 大暑) "
  local z07=" $(@B3 处暑) " z08=" $(@B3 秋分) " z09=" $(@B3 霜降) "
  local z10=" $(@D9 小雪) " z11=" $(@D9 冬至) " z12=" $(@D9 大寒) "

  echo "┌────────────────────────────────────────────────────────────────────────────────────────┐"
  echo "│                             每个月两字, ${YCWJI}, ${YZWQI}                             │"
printf "│         "
@zeta:memo:msgrb 春 雨 x 寅; @zeta:memo:msgrb 惊 春 x 卯; @zeta:memo:msgrb 清 谷 天 辰; printf "                "
@zeta:memo:msgrb 夏 满 x 巳; @zeta:memo:msgrb 芒 夏 x 午; @zeta:memo:msgrb 暑 相 连 未; echo "       │"
printf "│         "
@zeta:memo:msgrb 秋 处 x 申; @zeta:memo:msgrb 露 秋 x 酉; @zeta:memo:msgrb 寒 霜 降 戌; printf "                "
@zeta:memo:msgrb 冬 雪 x 亥; @zeta:memo:msgrb 雪 冬 x 子; @zeta:memo:msgrb 小 大 寒 丑; echo "       │"
  echo "├────┬────────────────────┬────────────────────┬────────────────────┬────────────────────┤"
  echo "│ 季 │       ${x1}        │       ${x2}        │       ${x3}        │       ${x4}        │"
  echo "├────┼──────┬──────┬──────┼──────┬──────┬──────┼──────┬──────┬──────┼──────┬──────┬──────┤"
  echo "│ 月 │${x03}│${x04}│${x05}│${x06}│${x07}│${x08}│${x09}│${x10}│${x11}│${x12}│${x01}│${x02}│"
  echo "├────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┤"
  echo "│ 节 │${y01}│${y02}│${y03}│${y04}│${y05}│${y06}│${y07}│${y08}│${y09}│${y10}│${y11}│${y12}│"
  echo "├────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┤"
  echo "│ 气 │${z01}│${z02}│${z03}│${z04}│${z05}│${z06}│${z07}│${z08}│${z09}│${z10}│${z11}│${z12}│"
  echo "└────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┘"
}

function memo-lunar() {
  local YY YYgz MM MMgz DD lcMM lcDD
  local hh hhN1 hhN2 hhN3 hhN4 hhN51 hhN52
  local mm mmN idx ss
  YY=$(date '+%Y'); MM=$(date '+%m'); DD=$(date '+%d')
  hh=$(date '+%H'); mm=$(date '+%M'); ss=$(date '+%S')

  local TianGan=( # 干支纪标记法以 60 为循环周期
    "甲"  "乙"  "丙"  "丁"  "戊"  "己"  "庚"  "辛"  "壬"  "癸"
  )
  local DiZhi=( # https://123.5ikfc.com/shichen
    "子"  "丑"  "寅"  "卯"  "辰"  "巳"  "午"  "未"  "申"  "酉"  "戌"  "亥"
  )
  local ShengXiao=( # https://www.beijing-time.org/jb.html
    "鼠"  "牛"  "虎"  "兔"  "龙"  "蛇"  "马"  "羊"  "猴"  "鸡"  "狗"  "猪"
  )

  # 公元后年份的干支算法: 天干编号01-10，地支编号01-12
  # - 年份减 3 对 10 取余数即<天干>编号
  (( idx = (YY - 3)%10 )); [[ -n "${BASH_VERSION}" ]] && (( idx-- ))
  YYgz="$(@G9 ${TianGan[${idx}]})"
  MMgz=${TianGan[${idx}]} # 从年份的<天干>查表找月份<天干>
  # - 年份减 3 对 12 取余数即<地支>编号
  (( idx = (YY - 3)%12 )); [[ -n "${BASH_VERSION}" ]] && (( idx-- ))
  YYgz="${YYgz}$(@R3 ${DiZhi[${idx}]})$(@Y3 ${ShengXiao[${idx}]})"

  local gzJanIdx gzDayIdx
  # NOTE 月份的干支表示要用农历月份计算
  lcMM=$(xcmd lunar-calendar -x | grep lcM | cut -d' ' -f3) # 农历月
  lcDD=$(xcmd lunar-calendar -x | grep lcD | cut -d' ' -f3) # 农历日
  # 甲/0  乙/1  丙/2  丁/3  戊/4  己/5  庚/6  辛/7  壬/8  癸/9  偏移
  case ${MMgz} in # 年份<天干> => 正月的起始<天干>
    甲|己) gzJanIdx=2 ;; # 正月<天干>起始于(丙)
    乙|庚) gzJanIdx=4 ;; # 正月<天干>起始于(戊)
    丙|辛) gzJanIdx=6 ;; # 正月<天干>起始于(庚)
    丁|壬) gzJanIdx=8 ;; # 正月<天干>起始于(壬)
    戊|癸) gzJanIdx=0 ;; # 正月<天干>起始于(甲)
  esac
  (( idx = (lcMM + gzJanIdx)%10 )); [[ -n "${BASH_VERSION}" ]] && (( idx-- ))
  MMgz="${TianGan[${idx}]}" # 月份的天干

  case ${hh} in                             #   初        正
    23|00) idx=0;  hhN3='夜半'; hhN4='三更' # 23:00 -> 00:00 -> 00:59
      hhN51="困敦";   hhN52='混沌万物之初萌, 藏黄泉之下'   ;; # 子
    01|02) idx=1;  hhN3='鸡鸣'; hhN4='四更' # 01:00 -> 02:00 -> 02:59
      hhN51="赤奋若"; hhN52='气运奋迅而起, 万物无不若其性' ;; # 丑
    03|04) idx=2;  hhN3='平旦'; hhN4='五更' # 03:00 -> 04:00 -> 04:59
      hhN51="摄提格"; hhN52='万物承阳而起'                 ;; # 寅
    05|06) idx=3;  hhN3='日出'; hhN4=''     # 05:00 -> 06:00 -> 06:59
      hhN51="单阏";   hhN52='阳气推万物而起'               ;; # 卯
    07|08) idx=4;  hhN3='食时'; hhN4=''     # 07:00 -> 08:00 -> 08:59
      hhN51="执徐";   hhN52='伏蛰之物, 而敷舒出'           ;; # 辰
    09|10) idx=5;  hhN3='隅中'; hhN4=''     # 09:00 -> 10:00 -> 10:59
      hhN51="大荒落"; hhN52='万物炽盛而出, 霍然落之'       ;; # 巳
    11|12) idx=6;  hhN3='日中'; hhN4=''     # 11:00 -> 12:00 -> 12:59
      hhN51="敦牂";   hhN52='万物壮盛也'                   ;; # 午
    13|14) idx=7;  hhN3='日昳'; hhN4=''     # 13:00 -> 14:00 -> 14:59
      hhN51="协洽";   hhN52='阴阳和合，万物化生'           ;; # 未
    15|16) idx=8;  hhN3='日晡'; hhN4=''     # 15:00 -> 16:00 -> 16:59
      hhN51="涒滩";   hhN52='万物吐秀, 倾垂也'             ;; # 申
    17|18) idx=9;  hhN3='日入'; hhN4=''     # 17:00 -> 18:00 -> 18:59
      hhN51="作噩";   hhN52='万物皆芒枝起'                 ;; # 酉
    19|20) idx=10; hhN3='日暮'; hhN4='一更' # 19:00 -> 20:00 -> 20:59
      hhN51="阉茂";   hhN52='万物皆蔽冒也'                 ;; # 戌
    21|22) idx=11; hhN3='人定'; hhN4='二更' # 21:00 -> 22:00 -> 22:59
      hhN51="大渊献"; hhN52='万物于天, 深盖藏也'           ;; # 亥
  esac

  [[ -n "${ZSH_VERSION}" ]] && (( idx++ ))
  hhN1=${DiZhi[${idx}]}
  hhN2=初; (( hh%2 == 0 )) && hhN2=正

    if (( mm <= 15 )); then  mmN='一刻'
  elif (( mm <= 30 )); then  mmN='二刻'
  elif (( mm <= 45 )); then  mmN='三刻'
  else                       mmN='四刻'
  fi

  local gzjyFixed=( #  干支记月份表示法中月份的地支名称固定如下表
    "寅"  "卯"  "辰"  "巳"  "午"  "未"  "申"  "酉"  "戌"  "亥"  "子"  "丑"
  )

  idx=${lcMM}; [[ -n "${BASH_VERSION}" ]] && (( idx-- ))
  MMgz="$(@G9 ${MMgz})$(@Y3 ${gzjyFixed[${idx}]})"
  echo
  echo "$(@G9 ${hhN51}) - $(@D9 "${hhN52}")"
  echo
  printf " ${hh}:${mm}:${ss}   $(@R3 ${hhN1})$(@G9 ${hhN2})$(@Y3 ${mmN}) - "
  if [[ -n "${hhN4}" ]]; then
    echo "$(@B9 ${hhN3})($(@D9 ${hhN4}))"
  else
    echo "$(@B9 ${hhN3})"
  fi
  echo "${YY}-${MM}-${DD}  ${YYgz}$(@D9 年) - ${MMgz}$(@D9 月)"
  echo
}
