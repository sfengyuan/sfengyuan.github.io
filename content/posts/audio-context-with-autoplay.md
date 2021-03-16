---
title: "自动播放媒体文件与Audio Context"
tags: []
categories: ["javascript"]
date: 2019-06-14T23:21:09+08:00
hidden: false
draft: false
keywords: ["audioContext"]
description: ""
slug: ""
---

Chome在去年更新了新的政策, 进一步限制了媒体的自动播放.

# 自动播放

根据官网给的说明, 新的政策是:

**静音的媒体可以**

许多网站都是这么做的, 自动播放静音的视频, 需要用户手动启用声音.

**用户产生操作之后**

chrome会拦截代码里的播放指令, 当用户产生操作之后, 比如单击或触摸, chrome会尝试自动播放. 但是这个并不靠谱, 如果你的AudioContext是在页面载入时创建的, 那就必须手动调用resume.

**桌面浏览器的MEI决定是否自动播放**

在chrome里打开`chrome://media-engagement/`查看域名的MEI评分.

**移动浏览器上, 添加到首页的页面可以自动播放**

# 本地调试

允许自动播放:

打开`chrome://flags/#autoplay-policy`, 把`"Autoplay Policy"` 设置为 `"No user gesture is required"`

不允许自动播放:

在快捷方式上设置flag:`.../chrome.exe" --disable-features="PreloadMediaEngagementData,AutoplayIgnoreWebAudio, MediaEngagementBypassAutoplayPolicies"`

# AudioContext

我们尝试用AudioContext写一个播放音乐的页面, AudioContext好比一个由很多音频节点构成的一个图纸, 每一个节点都可以操纵音频.
我们的所有操作也必须由节点完成.

如图:

```
          |-----------------------------------------------------------|
          |    --------------    --------------    ---------------    |
mp3  ->   |    | audio node |    | audio node |    | audio  node |    |
ogg  ->   | -> |------------| -> |------------| -> |-------------|    |
etc  ->   |    |   source   |    |   ......   |    | destination |    |
          |    |------------|    |------------|    |-------------|    |
          |-----------------------------------------------------------|
```

音频文件解码之后作为source节点, 然后连接到destination节点, 就可以播放了, 之间可以根据需要连接其他节点, 如GainNode可以控制音量.

# 示例

## 创建Context

```
    function createAudioContext() {
      let ctx
      try {
        ctx = new (window.AudioContext || window.webkitAudioContext)()
      } catch (e) {
        console.log('audioContext unavailable.')
      }
      return ctx
    }
```

## 获取文件

可以用FileReader. 这里是ajax, 类型是`'arraybuffer'`

```
    function requestSound(url) {
      return new Promise((resolve, reject) => {
        const req = new XMLHttpRequest()
        req.open('GET', url, true)
        req.responseType = 'arraybuffer'
        req.onload = () => {
          resolve(req.response)
        }
        req.onerror = () => { reject('XHR:Faild to request' + url) }
        req.send()
      })
    }
```

## 解码

```
    function decodeBuffer(ctx, arraybuffer) {
      return new Promise((resolve, reject) => {
        ctx.decodeAudioData(arraybuffer, decoded => {
          resolve(decoded)
        })
      })
    }
```

## 创建source节点

```
    function createSource(ctx, { decoded, loop }) {
      let source = ctx.createBufferSource()
      source.buffer = decoded
      source.loop = loop
      source.onended = () => {
        source = null
      }
      return source
    }
```

## 连接destination节点

```
    let source = createSource(ctx, {decoded, loop: true})
    source.connect(ctx.destination)
    source.start()
```

注意上面的`source.start()`不一定会播放, chrome会拦截成suspended状态, `ctx.state`能返回当前context的状态,
`onstatechange`钩子可以在状态改变时调用我们给的函数.

`suspend`和`resume`方法可以切换context的状态.

## 控制按钮

```
    btn.addEventListener('click', e => {
      if (ctx.state === 'running') {
        ctx.suspend().then(() => { })
      } else if (ctx.state === 'suspended') {
        ctx.resume().then(() => { })
      }
      e.stopPropagation()
      e.preventDefault()
    })
```

## 尝试自动播放

```
    const autoResume = (e) => {
      if (ctx.state === 'suspended') {
        ctx.resume().then(() => {})
      }
      if (ctx.state === 'running') {
        document.removeEventListener('click', autoResume)
        document.removeEventListener('touchstart', autoResume)
      }
    }
    document.addEventListener('click', autoResume, false)
    document.addEventListener('touchstart', autoResume, false)
```

我们在用户第一次单击或触摸时, 尝试调用resume, 如果成功, 则删除事件, 因为之后就一切正常播放了.

## 完整例子

[codepen link](https://codepen.io/jacobsun/pen/xoZwpz?editors=0010)
