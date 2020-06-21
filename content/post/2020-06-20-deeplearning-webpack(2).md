---
title:       "Deep Learning Webpack（2）"
subtitle:    "webpack 核心概念:Entry、Output、Loaders、Plugins、Mode"
description: ""
date:        2020-06-20
author:      "莫伟伟"
image:       "https://img.moweiwei.com/webpack-bg1.png"
tags:
    - webpack
categories:  [ TECH ]
URL:         /2020/06/20/2
---

# Deep Learning Webpack（2）

## 1. Entry

模块依赖图：

![](https://img.moweiwei.com/webpack-tree.png)

- entry： 指定 webpack 打包入口
- 依赖图的入口是 entry，图片、字体等也会不断加入依赖图

entry 用法：

- 单入口：

```js
module.exports = {
  entry: './src/index.js',
}
```

- 多入口：

```js
module.exports = {
  entry: {
    app: './src/index.js',
    adminApp: './src/adminApp.js'
  }
}
```

## 2. Output

- output: 指定 webpack 打包的输出

output 用法：

- 单入口：

```js
module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js'
  },
}
```

- 多入口

通过占位符确保文件名的唯一

```js
module.exports = {
  entry: {
    app: './src/index.js',
    adminApp: './src/adminApp.js'
  },
  output: {
    filename: '[name].js'
    path: path.resolve(__dirname, 'dist'),
  },
}
```

![](https://img.moweiwei.com/webpack-output.png)

## 3. Loaders

- webpack 开箱只支持 JS 和 JSON 两种文件类型
- 通过 loaders 将其他类型转化为有效的模块，添加到依赖图中
- loaders 本身是一个函数，接受源文件作为参数，返回转换的结果。

常见的 loaders：

| babel-loader  | 转换ES6、ES7新语法       |
| ------------- | ------------------------ |
| css-loader    | 支持.css文件的加载和解析 |
| less-loader   | 将 less 文件转化为css    |
| ts-loader     | 将TS转化为JS             |
| file-loader   | 打包图片、字体等         |
| raw-loader    | 将文件以字符串的形式导入 |
| thread-loader | 多进程打包JS和CSS        |

loaders 用法：

- test：指定匹配规则
- use： 指定使用的 loader

```js
module.exports = {
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[name].js'
  },
  module: {
    rules: [
      {
        test: /.txt$/,
        use: 'raw-loader'
      }
    ]
  }
}
```

## 4. Plugins

- 增强 loader 功能；loader 不能做的，plugins 做。
- 作用于构建的整个过程：开始、过程、结束。
- 用于 bundle 文件的优化、资源管理、环境变量的注入

常见的 plugins：

| 名称                     | 描述                                       |
| ------------------------ | ------------------------------------------ |
| CommonsChunkPlugin       | 将chunks相同的模块代码提取成公共的js       |
| CleanWebpackPlugin       | 清理构建目录                               |
| ExtractTextWebpackPlugin | 将css从bundle文件里提取成一个独立的css文件 |
| CopyWebpackPlugin        | 将文件或文件夹拷贝到构建的输出目录         |
| HTMLWebpackPlugin        | 创建html文件去承载输出的 bundle            |
| UglifyjsWebpackPlugin    | 压缩JS                                     |
| ZipWebpackPlugin         | 将打包出的资源生成一个zip包                |

plugins 用法：

```js
module.exports = {
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[name].js'
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './src/index.html'
    })
  ]
}
```

## 5. Mode

- Mode用来指定当前构建环境是：Production、development、none
- 设置 mode 可以用 webpack 内置函数，默认值：production

![](https://img.moweiwei.com/webpack-mode.png)

