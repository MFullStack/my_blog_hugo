---
title:       "Deep Learning Webpack（1）"
subtitle:    "webpack 从零开始入门配置"
description: ""
date:        2020-06-20
author:      "莫伟伟"
image:       "https://img.moweiwei.com/webpack-bg1.png"
tags:
    - webpack
categories:  [ TECH ]
URL:         /2020/06/20/1
---

# Deep Learning Webpack（1）

## 1. 为什么需要 webpack 等构建工具

- 转换 ES6 语法
- 转换 JSX、Vue 指令等
- CSS 前缀补全、预处理
- 压缩混淆
- 图片压缩

## 2. 安装 webpack

```sh
# 创建项目
mkdir learning-webpack
cd learning-webpack
npm init -y
# 安装 webpack
npm install webpack webpack-cli --save-dev
# 查看 webpack 版本
./node_modules/.bin/webpack -v
```

## 3. 从零开始配置 webpack

项目根目录创建`webpack.config.js`, 如下：

```js
// webpack.config.js
'use strict';

const path = require('path');

module.exports = {
  entry: './src/index.js', // 入口
  output: {
    path: path.resolve(__dirname, 'dist'), // 输出
    filename: 'bundle.js' // 打包出来的文件名
  },
  mode: 'production' // 模式
}
```

```js
// src/index.js
import { helloworld } from './helloworld';

document.write(helloworld())
```

```js
// src/helloworld.js
export function helloworld() {
  return 'hello world'
}
```

使用 `./node_modules/.bin/webpack` 命令打包，`dist` 文件夹下打包出文件 `bundle.js`

dist 文件夹下创建 `index.html`

```html
<!-- /dist/index.html -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hello Webpack</title>
</head>
<body>

    <script src="./bundle.js" type="text/javascript"></script>
</body>
</html>
```

浏览器打开 `index.html` 可见输出 `hello world`

优化打包命令，修改 `package.json` 如下，执行 `npm run build` 即可同样打包。

```json
...
"scripts": {
    "build": "webpack"
  }
...
```
