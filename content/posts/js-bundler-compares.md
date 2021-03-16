---
title: "JS打包工具简单对比"
tags: []
categories: ["development"]
date: 2019-06-25T21:38:27+08:00
hidden: false
draft: false
keywords: []
description: ""
slug: ""
---

从功能来说, 现在3者几乎都差不多, tree shaking, dev server, code splitting, 不过rollup不支持HMR, 其实也不是完全没有办法.


## 测试结果

|   |      | Parcel | Webpack  | Rollup.js |
|:-:|:-:|:-:|:-:|:-:|
|CJS|  web |   1477 |     1116 |       152 |
|   | node |   1444 |     1347 |       374 |
|ES6|  web |   1643 |     1101 |       134 |
|   | node |   1444 |       X  |       270 |
|MIX| web  |   1632 |     1096 |         X |
|   | node |   1444 |       X  |         X |

## 项目地址

[Go](https://github.com/sfengyuan/js-bundler-compares)
