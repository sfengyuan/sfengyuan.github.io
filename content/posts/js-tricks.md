---
title: "[新]Javascript小技巧"
tags: []
categories: []
date: 2022-03-12T21:28:29+08:00
hidden: false
draft: false
keywords: ["tricks"]
description: ""
slug: ""
---

## nullish coalescing操作符 ??

它是一个类似`||`的短路求值用法的操作符, 只有当左侧的值为`null`或`undefined`时, 才返回右侧的值, 否则返回左侧的值. `||`当左侧的值为"falsy`(有些人叫虚值)时就会返回右侧的.

```
console.log(null ?? 'YEAH')
```

## optional chaining 操作符 ?.

访问不确定是否存在的属性时可以使用这个操作符, 确信存在但是没有, 应该抛出错误.

```
console.log({foo: 'Yeah'}?.bar)
```

## 利用...操作符动态添加属性

```
console.log({
  foo: 'foo value',
  ...(true && { bar:'bar value' })
})
```

## 动态解构对象

```
const user = {name: 'Alex', age: 19}
const { name: userName } = user
const userKey = 'name'
const { [userKey]: data } = user
```

## 使用字典处理复杂条件判断

这里它代替了if或者switch
```
function getBrand (brand) {
  const brands = {
    apple: 'apple brand',
    google: 'google brand',
    microsoft: 'microsoft brand'
  }
  return brands[brand.trim().toLowerCase()] ?? 'unknow brand'
}
```
