---
title: "REST API设计"
tags: []
categories: []
date: 2022-03-13T21:56:48+08:00
hidden: false
draft: false
keywords: []
description: ""
slug: ""
---

## HTTP相关基础知识概述

REST是基于资源的, 资源是由uri来表示, 如`/books`, 对资源的操作由HTTP动词来表名, 如`GET, POST...`. 动词和uri的组合称为endpoint, 如`GET: /books`, endpoint可以理解为对某资源的操作. 如`POST: /books`可以意思`创建一本新书`.

响应状态可以由状态码表示:
```
1xx: 信息
2xx: 成功
3xx: 重定向
4xx: 客户端错误
5xx:服务器端错误
```

从开发角度看, HTTP动词可以映射到CRUD操作.
```
GET -> READ,
POST -> CREATE
PUT, PATCH -> UPDATE
DELETE -> DELETE
```

## 必备常识

1. 指定`Content-Type`, 如`Content-Type: application/json`
2. `uri`里不要包含操作动词.
```
POST: /books/create-new-book
改成
POST: /books
```
3. 为了统一性, 资源名字最好用复数
4. 响应体包含详细错误信息.

如
`message`可以在界面上显示, `detail`是提供给开发人员使用的.
```
{
  "error": "Invalid payload.",
  "message": "Required fields should not be blank.",
  "detail": {
      "name": "This field is required."
  }
}
```

IETF设计了RFC7807，它创建了一个通用的错误处理模式.

该模式由五部分组成:

type — 对错误进行分类的URI标识符
title — 简短易懂的消息
status — HTTP响应码(可选)
detail — 错误说明
instance — 标识特定错误的URL实例
除了使用我们自定义的错误响应主体，还可以将主体转换为:
```
{
  "type": "/errors/incorrect-user-pass",
  "title": "Incorrect username or password.",
  "status": 403,
  "detail": "Authentication failed due to incorrect username or password.",
  "instance": "/login/log/abc123"
}
```
5. 使用准确的状态码描述响应.

也可以使用更通用状态码来描述, 如Facebook只使用400作为所有错误的状态码.

6. 每个动词对应的状态码应该始终一致.

```
GET: 200 OK
PUT: 200 OK
POST: 201 Created
PATCH: 200 OK
DELETE: 204 No Content
```
7. 查询字符串而非嵌套uri
嵌套uri会使资源不明显
```
/authors/libai/tangshi
# 不如
/tangshi?author=libai
```

8. 自动处理uri末尾的斜杠.
无论uri有或没有斜杠, 程序应该兼容两种风格.
```
/books
/books/
```

9. 使用查询字符串过滤分页

```
/books/published
# 不如
/books?published=true&page=2&page_size=10
```

10. 401 VS 403

```
# 未提供身份信息的使用
401 Unauthorized

# 提供了身份信息, 但没有必要的权限
403 Forbidden
```
11. 202 Accepted

`202 Accepted`可以作为`201 created`的替代品. 它适用的场景:
```
1. 资源将会在未来创建, 如在某个job完成后.
2. 资源已经创建, 但本次操作不算错误
```
