// 参考实现 https://github.com/chalk/chalk
// 参考实现 https://www.npmmirror.com/package/chalk

// 浏览器控制台
//   console.error('报错信息 => 默认红色');
//   console.log('%c绿色信息', 'color: #529b2e');
// 浏览器控制台 + 终端
//   console.log(  '\x1B[32m%s\x1B[0m', '绿色信息');
//   console.log('\u001B[31m%s\x1B[0m', '红色信息');
//
// https://developer.mozilla.org/en-US/docs/Web/API/console
// log() info() warn() error() debug() assert() trace() clear()

class ZLog {
  // 静态公共属性
  static ANSI = {
    attrs: {        // 开  关
      reset:          [0,   0],
      bold:           [1,  22],
      dim:            [2,  22],
      italic:         [3,  23],
      underline:      [4,  24],
      blink:          [5,  25],
      inverse:        [7,  27],
      hidden:         [8,  28],
      strikethrough:  [9,  29],
      overline:       [53, 55],
    },
    color: {
      fg: { // 39 默认 fg 颜色
        black:    { normal: [30, 39],   bright: [90, 39] },
        red:      { normal: [31, 39],   bright: [91, 39] },
        green:    { normal: [32, 39],   bright: [92, 39] },
        yellow:   { normal: [33, 39],   bright: [93, 39] },
        blue:     { normal: [34, 39],   bright: [94, 39] },
        purple:   { normal: [35, 39],   bright: [95, 39] },
        cyan:     { normal: [36, 39],   bright: [96, 39] },
        white:    { normal: [37, 39],   bright: [97, 39] },

        gray:     { bright: [2,  39],   normal: [90, 39] },
        grey:     { bright: [2,  39],   normal: [90, 39] },
      },
      bg: { // 49 默认 bg 颜色
        black:    { normal: [40, 49],   bright: [100, 49] },
        red:      { normal: [41, 49],   bright: [101, 49] },
        green:    { normal: [42, 49],   bright: [102, 49] },
        yellow:   { normal: [43, 49],   bright: [103, 49] },
        blue:     { normal: [44, 49],   bright: [104, 49] },
        purple:   { normal: [45, 49],   bright: [105, 49] },
        cyan:     { normal: [46, 49],   bright: [106, 49] },
        white:    { normal: [47, 49],   bright: [107, 49] },

        gray:     { bright: [2,  49],   normal: [100, 49] },
        grey:     { bright: [2,  49],   normal: [100, 49] },
      }
    }
  };

  static RTME = {}; // Runtime Environment
  static { // 静态构造器(类实例初始化时执行一次)
    if (typeof(process) === 'object') {
      this.RTME.nodejs = true;
      this.RTME.supports = {
        nocolor: false, ansi: true, ansi256: false, truecolor: false,
      };

      const tty = require('tty');
      const proc = require('process');
      if(! tty.isatty(1) || ! tty.isatty(2)) {
        this.RTME.supports.ansi = false;
        this.RTME.supports.nocolor = true;
      } else {
        function hasFlag(flag) {
          const prefix = flag.startsWith('-') ? '' : (flag.length === 1 ? '-' : '--');
          const position = proc.argv.indexOf(prefix + flag);
          const terminator = proc.argv.indexOf('--');
          return position !== -1 && (terminator === -1 || position < terminator);
        }

        if(hasFlag('no-color')  || hasFlag('no-colors')  || hasFlag('color=false')  || hasFlag('color=never')) {
          this.RTME.supports.ansi = false;
          this.RTME.supports.nocolor = true;
        } else {
          if(  proc.env.TERM === 'xterm-kitty'
            || proc.env.COLORTERM === 'truecolor'
            || hasFlag('color=16m')
            || hasFlag('color=full')
            || hasFlag('color=truecolor')
          ) {
            this.RTME.supports.truecolor = true;
          }

          if(hasFlag('color=256') || /-256(color)?$/i.test(proc.env.TERM)) {
            this.RTME.supports.ansi256 = true;
          }

          if ('CI' in proc.env) {
            if ('GITHUB_ACTIONS' in proc.env || 'GITEA_ACTIONS' in proc.env) {
              this.RTME.supports.truecolor = true;
            }
          }

          if(proc.platform === 'win32') {
            const release = require('os').release().split('.');
            // Windows 10 build 10586 is the first release supports 256colors.
            // Windows 10 build 14931 is the first release supports trueColor.
            if(Number(release[0]) >= 10  && Number(release[2]) >= 10_586  ) {
              if(Number(release[2]) >= 14_931) {
                this.RTME.supports.truecolor = true;
              } else {
                this.RTME.supports.ansi256 = true;
              }
            }
          }
        }
      }
    } else {
      this.RTME.browser = true;
      this.RTME.supports = {
        nocolor: false, ansi: true, ansi256: true, truecolor: true,
      };
    }
  }

  // 转移序列 $ man console_codes
  // 38 设置 fg 颜色, 48 设置 bg 颜色
  static CODE = {};
  static {
    const ansi256 = (offset = 0) => (msg, index, attrs='') => '\u001B[0m' + `\u001B[${attrs}${38 + offset};5;${index}m`       + msg + '\u001B[0m';
    const ansi16m = (offset = 0) => (msg, R,G,B, attrs='') => '\u001B[0m' + `\u001B[${attrs}${38 + offset};2;${R};${G};${B}m` + msg + '\u001B[0m';

    this.CODE.ansi256FG = ansi256(); this.CODE.ansi256BG = ansi256(10);
    this.CODE.ansi16mFG = ansi16m(); this.CODE.ansi16mBG = ansi16m(10);
    this.CODE.ansiColor = (msg, index, attrs='') => '\u001B[0m' + `\u001B[${attrs}${index}m` + msg + '\u001B[0m';
  }

  // 共享原型函数
  _setDefaultValues() {
    this.mode.trace = false;

    if(ZLog.RTME.supports.nocolor) {
      return true;
    }

    this.ansi.fg = true;   this.ansi.normal = true;
    this.ansi.bg = false;  this.ansi.bright = false;

    for(const [key, val] of Object.entries(ZLog.ANSI.attrs)) {
      this.ansi.attrs[key] = false;
    }
  }

  _attrsCodes() {
    let attrsCodes = '';
    for(const key of Object.keys(ZLog.ANSI.attrs)) {
      if(this.ansi.attrs[key]) {
        attrsCodes += ZLog.ANSI.attrs[key][0] + ';';
      }
    }
    return attrsCodes;
  }

  attrs(args = []) {
    if(ZLog.RTME.supports.nocolor) {
      return this;
    }

    for(let attr of args) {
      if(ZLog.ANSI.attrs[attr]) {
        this.ansi.attrs[attr] = true;
      } else {
        this.ansi.attrs[attr] = false;
      }
    }
    return this;
  }

  fg(enable = true) {
    if(ZLog.RTME.supports.nocolor) {
      return this;
    }

    if(enable) {
      this.ansi.fg = true;
    } else {
      this.ansi.fg = false;
    }
    return this;
  }

  bg(enable = true) {
    if(ZLog.RTME.supports.nocolor) {
      return this;
    }

    if(enable) {
      this.ansi.bg = true;
    } else {
      this.ansi.bg = false;
    }
    return this;
  }

  normal(enable = true) {
    if(ZLog.RTME.supports.nocolor) {
      return this;
    }

    if(enable) {
      this.ansi.normal = true;
      this.ansi.bright = false;
    } else {
      this.ansi.normal = false;
      this.ansi.bright = true;
    }
    return this;
  }

  bright(enable = true) {
    if(ZLog.RTME.supports.nocolor) {
      return this;
    }

    if(enable) {
      this.ansi.normal = false;
      this.ansi.bright = true;
    } else {
      this.ansi.normal = true;
      this.ansi.bright = false;
    }
    return this;
  }

  ansi256(index) {
    if(ZLog.RTME.supports.nocolor) {
      return this;
    }
  }

  ansi16m(value) {
    if(ZLog.RTME.supports.nocolor) {
      return this;
    }
  }

  // https://www.w3.org/TR/css-color-3/#html4
  // https://www.w3.org/TR/css-color-3/#svg-color
  rgb(R, G, B) {
    if(ZLog.RTME.supports.nocolor) {
      return this;
    }
  }

  color(name) {
    if(ZLog.RTME.supports.nocolor) {
      return this;
    }
  }

  words(msg) {
    if(ZLog.RTME.supports.nocolor) {
      return msg;
    }
  }

  // 初始化构造器
  constructor() {
    this.mode = {};
    this.ansi = {};
    this.ansi.attrs = {};
    this._setDefaultValues();

    for(const key of Object.keys(ZLog.ANSI.color.fg)) {
      this[key] = function(msg) {
        if(this.mode.trace) {
          console.trace();
        }

        if(ZLog.RTME.supports.nocolor) {
          return msg;
        }
        if(typeof(msg) !== 'string' || !msg ) {
          this._setDefaultValues();
          return msg;
        }

        let colorIndex = 0, variant = 'normal', colorMsg;
        if(this.ansi.normal) { variant = 'normal'; }
        if(this.ansi.bright) { variant = 'bright'; }
        if(this.ansi.bg) {
          colorIndex = ZLog.ANSI.color.bg[key][variant][0];
        } else {
          colorIndex = ZLog.ANSI.color.fg[key][variant][0];
        }
        colorMsg = ZLog.CODE.ansiColor(msg, colorIndex, this._attrsCodes());
        this._setDefaultValues(); return colorMsg;
      }
    }
  }

  trace(enable = true) {
    if(enable) {
      this.mode.trace = true;
    } else {
      this.mode.trace = false;
    }
    return this;
  }
}

// attrs([]), fg(on), bg(off), normal(on), bright(off)
//
// black(''), red(''), green(''), yellow(''), blue('')
// purple(''), cyan(''), white(''), gray(''), grey('')
//
// ansi256(), ansi16m(), rgb(), color(), words()

function zlogUsageExamples() {
  function strToHex(str) {
    let hex = '';
    for(let i=0; i<str.length; i++) {
      hex += str.charCodeAt(i).toString(16);
    }
    return hex;
  }

  const zlog = new ZLog();
  const colorFNs = [
    'black', 'red', 'green', 'yellow', 'blue',
    'purple', 'cyan', 'white', 'gray', 'grey',
  ];
  const attrsVNs = [
    'bold', 'dim', 'italic', 'underline', 'blink',
    'inverse', 'hidden', 'strikethrough', 'overline',
  ];

  let outmsg = 'ZLog 测试: ';
  // 默认 .fg() 字体色, .normal(), 无属性 .attrs([])
  for(let fn of colorFNs) {
    let msg = zlog[fn](fn);
    // console.log(msg, strToHex(msg))
    outmsg += '[' + msg + '] ';
  }; console.log(outmsg);
  outmsg = 'ZLog 测试: ';
  for(let fn of colorFNs) {
    // 字体色默认, 设置 .bright()
    let msg = zlog.bright()[fn](fn);
    // console.log(msg, strToHex(msg))
    outmsg += '[' + msg + '] ';
  }; console.log(outmsg);

  outmsg = 'ZLog 测试: ';
  for(let fn of colorFNs) {
    // 字体色默认, 设置 .bg() 背景色
    let msg = zlog.bg()[fn](fn);
    // console.log(msg, strToHex(msg))
    outmsg += '[' + msg + '] ';
  }; console.log(outmsg);
  outmsg = 'ZLog 测试: ';
  for(let fn of colorFNs) {
    // 字体色默认, 设置 .bg() 背景色
    let msg = zlog.bg().bright()[fn](fn);
    // console.log(msg, strToHex(msg))
    outmsg += '[' + msg + '] ';
  }; console.log(outmsg);

  outmsg = 'ZLog 测试: ';
  for(let an of attrsVNs) {
    // 绿色字体 + 各种属性
    let msg = zlog.attrs([an]).green(an);
    // console.log(msg, strToHex(msg))
    outmsg += '[' + msg + '] ';
  }; console.log(outmsg);

  console.log(zlog.trace().blue('显示调用栈: 启用 console.trace() 模式'))

  return;

  console.log('实例属性')
  Object.getOwnPropertyNames(zlog).forEach(function(property) {
    console.log(property, typeof zlog[property]);
  });

  console.log('类属性')
  Object.getOwnPropertyNames(ZLog).forEach(function(property) {
    console.log(property, typeof ZLog[property], ZLog[property]);
  });
}

zlogUsageExamples();
// function(...args) 变长参数函数, args 是数组
// console.log(...array) 数组元素展开作为函数参数
