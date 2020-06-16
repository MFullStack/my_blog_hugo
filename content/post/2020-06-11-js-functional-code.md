---
title:       "JS 函数编程总结"
subtitle:    "javascript 函数式编程"
description: ""
date:        2020-06-11
author:      "莫伟伟"
image:       "https://img.moweiwei.com/Phuket14.JPG"
tags:
    - JS
categories:  [ TECH ]
URL:         "/2020/06/11/"
draft: true
---

# JS 函数编程总结

## 函数输出

在 JavaScript 中，函数只会返回一个值。下面的三个函数都有相同的 return 操作。没有 return 值，或者 return;，则会隐式地返回 undefined 值。

```js
function foo() {}

function bar() {
    return;
}

function baz() {
    return undefined;
}
```

使用函数编程：使用函数而非程序，那么函数必须永远有返回值。这也意味着必须明确地 return 一个非 undefined 值。