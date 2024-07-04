#!/usr/bin/env node
// SPDX-License-Identifier: GPL-3.0-only OR Apache-2.0 OR MIT
// SPDX-FileCopyrightText: 2024 Charles Wong <charlie-wong@outlook.com>
// Created By: Charles Wong 2024-07-03T12:26:07+08:00 Asia/Shanghai
// Repository: git@gitlab.com:xwlc/zeta

// 前端公共库  https://www.bootcdn.cn
// https://developers.google.cn/speed/libraries
function wlc() {
  if(typeof(config) != 'object') { console.warn(...zargs); return; }
  if(config.trace) { console.trace(); }
  let show = console.log; // 默认值
  if(config.log)   { show = console.log;   }
  if(config.warn)  { show = console.warn;  }
  if(config.error) { show = console.error; }

  let zcache = { fmt: '', msg: [] };
  for(let item of zargs) {
    let hasAttrs = false;
    let color = ANSI[item.color];
    if(!item.msg && !color && zcache.msg.length != 0 ) {
      show(zcache.fmt + '\x1B[0m', ...zcache.msg);
      zcache.fmt = ''; zcache.msg = []; continue;
    }
    if(!color) { color=''; }
    if(typeof(item.attr) == 'object') {
      let attrVal = '';
      for(let attr of item.attr) {
        if(ANSI[attr]) {
          hasAttrs = true;
          attrVal += ANSI[attr];
        }
      }
      if(hasAttrs) {
        zcache.fmt += ANSI['reset'];
        zcache.fmt += attrVal;
      }
    }
    zcache.fmt += color + '%s';
    if(hasAttrs) {
      zcache.fmt += ANSI['reset'];
    }
    zcache.msg.push(item.msg);
  }
  show(zcache.fmt + '\x1B[0m', ...zcache.msg); // 数组参数化展开

  function zlog(config, ...zargs) {
  };
}
