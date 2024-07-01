#!/usr/bin/env bash

THIS_AFP="$(realpath "${0}")"        # 当前文件绝对路径(含名)
THIS_FNO="$(basename "${THIS_AFP}")" # 仅包含当前文件的文件名
THIS_DIR="$(dirname  "${THIS_AFP}")" # 当前文件所在的绝对路径

# [系统设置] -> [地域设置] -> [输入法] -> [Pinyin] - [Punctuation]
# 简体中文标点符号表: 拷贝前删除 # 号开头的注释行, 即此文件的前三行

sudo cp "${THIS_DIR}/fcitx5.punc" /usr/share/fcitx5/punctuation/punc.mb.zh_CN
