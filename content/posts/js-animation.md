---
title: "Javascript动画"
tags: ["动画"]
categories: ["javascript"]
date: 2019-05-20T18:17:53+08:00
hidden: false
draft: false
keywords: ["requestanimationframe"]
description: ""
slug: ""
---

利用`requestanimationframe`实现 的一种通用动画效果, 方便使用其他库辅助动画效果.

# 时间

控制时间就等于控制了动画, 我们先确定动画的持续时间`duration`, 然后计算出已播放的时间长度对于`duration`的比值, 也就是动画进度`progress`. 比如一个小球从空中落到地面的动画, 小球在空中4秒钟, `duration`是`4`, 动画开始时, `progress`是0, 小球还没有掉落, 2秒钟后0.5, 小球掉了一半的距离, 当`progress`是1时, 小球落到地面, 动画结束了.

如果用图形表达

progress:
```
      |---------------------------------|

      t0  t0.1  t0.2 ...                t1

      0                                 1
```
progress 对应的位置:
```
      |---------------------------------|

      x                                 y

t0 * (y-x) + x                     t1 * (y-x) + x

      x                                 y
```

## performance 接口

Javascript的performance接口有几个函数特别有用, `performance.now`获取当前时间戳, 和Date相比, 它的精度更高, 虽然为了避免被时序攻击, 时间都做了一定的模糊化处理, 还是要比Date.now()精度高, 可以达到微秒.

另外, `performance.mark`, `performance.clearMarks`, `performance.getEntriesByName`可以用来操作buffer, 我们可以mark一个动画的id, entry里会保存mark的时间. Buffer的空间可以设置, 按照MDN的说法, 浏览器推荐的是150个对象, 动画一般很短, 结束就把entry clear掉, 没什么问题, 如果动画很多很长, 我想buffer没爆之前, 浏览器已经爆掉了, 所以我不是太关心这个限制问题.

实际代码

```
const trackTime = id => {
    const [entry] = performance.getEntriesByName(id)
    if (!entry) {
        performance.mark(id)
        return 0
    }
    return performance.now() - entry.startTime
}
```
上面的代码就是用来计算动画已经播放的时间的, id是requestAnimationFrame的返回值.

有了trackTime, 就可以计算出progress了.

```
const getProgress = ({duration, id}) => {
    if (duration) {
        return Math.min(trackTime(id) / duration, 1)
    }
    return 1
}
```

开头提到的"已播放的时间长度对于`duration`的比值".

# 动画函数

有了这两个工具函数, 就可以开始写动画函数了.

```
const animate = (cb, duration, easing) => {
    const tick = () => {
        const progress = Math.min(time.easing(getProgress(time)), 1)
        if (progress < 1) {
            cb(progress)
            requestAnimationFrame(tick)
        } else if (progress === 1) {
            cb(progress)
            performance.clearMarks(time.id)
        }
    }
    const time = {
        id: requestAnimationFrame(tick),
        duration,
        easing
    }
}
```
这个动画函数接受一个回调函数--每一帧执行的行为, 一个持续时间, 和一个easing函数. 当`progress`等于1时, 则绘制完当前帧后就不再继续播放了.

# 例子

这里是一个小球掉落的动画函数

```
const cubic = progress => Math.pow(--progress, 3) + 1
const drop = (duration, easing) => {
    const ballEle = document.querySelector('.ball')
    const r = ballEle.getBoundingClientRect()
    const data = {
        ele: ballEle,
        initX: r.top,
        distance: document.body.getBoundingClientRect().bottom - r.bottom - 5,
        duration,
        easing
    }

    animate(progress => {
            data.ele.style.top = progress * data.distance + data.initX + 'px'
        }, data.duration, data.easing)
}
drop(2000, cubic)
```
其中, initX是小球的初始位置, distance是小球距离地面的距离, 那个-5是因为body元素有5px的border, 并不重要. `progress * data.distance + data.initX + 'px'` 也是上面图里说的`t * (y-x) + x`, 至于为什么说t, 网上有些动画库叫t, 反正我们知道其实是progress就好.

至于easing函数, 单纯的数学公式, 他们有一个特点, 就是要保证输入0时输出是0, 输入1时输出是1, 0到1之间的小数就随便变化了. 不过D3.ease库有一些easing效果不满足这个要求, 这种情况需要处理, 不然动画会"卡碟", 卡在那完不成.

[完整Demo](https://codepen.io/jacobsun/pen/LozYKj?editors=0110)

# 参考
https://developer.mozilla.org/en-US/docs/Web/API/Performance

https://medium.com/@bdc/gain-motion-superpowers-with-requestanimationframe-ecc6d5b0d9a4
