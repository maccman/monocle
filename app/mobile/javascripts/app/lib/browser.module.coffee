ua         = window.navigator.userAgent
iPhoneIPod = ua && /iPhone|iPod/.test(ua)
iOS5       = parseInt((ua.match(/\wOS\w(\d+)_/i) || [0,0])[1], 10) < 6

module.exports =
  ua: ua
  iPhoneIPod: iPhoneIPod
  iOS5: iOS5