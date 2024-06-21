#!/usr/bin/env bash

THIS_AFP="$(realpath "${0}")"        # 当前文件绝对路径(含名)
THIS_FNO="$(basename "${THIS_AFP}")" # 仅包含当前文件的文件名
THIS_DIR="$(dirname  "${THIS_AFP}")" # 当前文件所在的绝对路径
# printf "[${THIS_AFP}]\n[${THIS_DIR}] [${THIS_FNO}]\n"; exit

sudo cp "${THIS_DIR}/updatedb.conf" /etc/updatedb.conf

if false; then
  man updatedb.conf
  updatedb # 更新 /var/lib/plocate/plocate.db
  locate # 默认索引 /var/lib/plocate/plocate.db
fi
