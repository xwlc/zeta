#!/usr/bin/env bash

# [系统设置] -> [地域设置] -> [输入法] -> [Pinyin] - [Punctuation]
# 简体中文标点符号表: 拷贝前删除 # 号开头的注释行, 即此文件的前三行
if [[ "$0" == "fcitx5-punc.xsh" ]]; then
  THIS_DIR="${PWD}"
else
  THIS_DIR="$(realpath "${0%/*}")"
fi

sudo cp "${THIS_DIR}/fcitx5-punc.ini" /usr/share/fcitx5/punctuation/punc.mb.zh_CN
