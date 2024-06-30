// 前端公共库  https://www.bootcdn.cn
// https://developers.google.cn/speed/libraries

// 浏览器控制台
//   console.error('报错信息 => 默认红色');
//   console.log('%c绿色信息', 'color: #529b2e');
// 浏览器控制台 + 终端
//   console.log('\x1B[32m%s\x1B[0m', '绿色信息');
//   console.log('\x1B[31m%s\x1B[0m', '红色信息');
const ZCOLORS = {
  'reset'     : '\x1B[0m',
  'bright'    : '\x1B[1m',  // 属性 => 亮色
  'grey'      : '\x1B[2m',  // 字体 -> 灰色
  'italic'    : '\x1B[3m',  // 属性 => 斜体
  'underline' : '\x1B[4m',  // 属性 => 下划线
  'reverse'   : '\x1B[7m',  // 属性 => 反向
  'hidden'    : '\x1B[8m',  // 属性 => 隐藏
  'black'     : '\x1B[30m', // 字体 -> 黑色
  'red'       : '\x1B[31m', // 字体 -> 红色
  'green'     : '\x1B[32m', // 字体 -> 绿色
  'yellow'    : '\x1B[33m', // 字体 -> 黄色
  'blue'      : '\x1B[34m', // 字体 -> 蓝色
  'magenta'   : '\x1B[35m', // 字体 -> 品红
  'cyan'      : '\x1B[36m', // 字体 -> 青色
  'white'     : '\x1B[37m', // 字体 -> 白色
  'blackBG'   : '\x1B[40m', // 背景 -> 黑色
  'redBG'     : '\x1B[41m', // 背景 -> 红色
  'greenBG'   : '\x1B[42m', // 背景 -> 绿色
  'yellowBG'  : '\x1B[43m', // 背景 -> 黄色
  'blueBG'    : '\x1B[44m', // 背景 -> 蓝色
  'magentaBG' : '\x1B[45m', // 背景 -> 品红
  'cyanBG'    : '\x1B[46m', // 背景 -> 青色
  'whiteBG'   : '\x1B[47m'  // 背景 -> 白色
};

// https://developer.mozilla.org/en-US/docs/Web/API/console
// log() info() warn() error() debug() assert() trace() clear()
function zlog(config, ...args) {
  if ( typeof(config) != 'object' ) { console.warn(...args); return; }
  if ( config.trace ) { console.trace(); }
  if ( config.detail ) {
    const err = new Error();
    err.name = "开发调试";
    err.message = "详细信息";
    console.log(err);
    err.stack.split(/\r\n|\n/).forEach(item => {
      if (item) console.log('行号', item.split(':')[1]);
    });
  }
  const color = ZCOLORS[config.color];
  if ( typeof(config.zlog) === 'function' && color ) {
    config.zlog(color + '%s\x1B[0m', ...args);
  } else {
    console.warn(...args);
  }
}

function tinyHTML() {
  let config = { trace: true, detail: false, color: 'green', zlog: console.log }
  zlog(config, 'Tiny HTML 绿色 + Trace', config);
  config.trace = false; config.color = 'blue';
  zlog(config, 'Tiny HTML 蓝色 - Trace', config);
}

tinyHTML();
