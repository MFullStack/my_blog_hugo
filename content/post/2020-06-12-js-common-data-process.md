---
title:       "JS 常用数据处理方法"
subtitle:    "数组、对象..."
description: ""
date:        2020-06-12
author:      "莫伟伟"
image:       "https://img.moweiwei.com/Phuket9.JPG"
tags:
    - JS
categories:  [ TECH ]
URL:         "/2020/06/12/"
draft: true
---

# JS 常用数据处理方法

## 数组去重

函数式数组去重：

```js
const removeDup = (_arr => _arr.filter((v,i) => _arr.indexOf(v) === i))
console.log(removeDup([1,2,3,4,1,2]))
//[1,2,3,4] 数据中除了第一个相同的都过滤出去
```

