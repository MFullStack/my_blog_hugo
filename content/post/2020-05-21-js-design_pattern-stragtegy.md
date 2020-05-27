---
title: "Javascript 设计模式-策略模式"
subtitle: "策略模式"
description: ""
date: 2020-05-24
author:      "莫伟伟"
image: ""
tags:
  - JS
  - JS设计模式
categories: [TECH]
categories_weight: 44
URL: "/2020/05/21/"
image:       "https://img.moweiwei.com/Phuket1.JPG"
---

# Javascript 设计模式-策略模式

设计模式就是开发过程中面对一些问题、场景时，可以复用的更好的解决方案。

## 策略模式

定义：某个功能有多种方案可以选择，我们定义一个一些策略，把他们每个封装起来，并且使他们可以相互替换。

## 表单校验

表单校验是 web 开发中常见的场景，如注册表单，很容易想到如下 if-else 的版本：

```js
var registerForm = document.getElementById("registerForm");

registerForm.onsubmit = function () {
  if (registerForm.username.value === "") {
    alert("用户名不为空");
    return false;
  }
  if (registerForm.password.value.length < 6) {
    alert("密码长度不能少于6位");
    return false;
  }
  if (!/(^1[3|5|8][0-9]{9}$)/.test(registerForm.phone.value)) {
    alert("手机格式不正确");
    return false;
  }
};
```

这种代码缺点如下：

- onsubmit 函数庞大，有太多的 if-else 语句。
- onsubmit 函数缺乏弹性，若想增加一种校验，需要修改 onsubmit 函数内部代码，这违反开放-封闭原则。
- 函数无法复用，若代码中另一个表单也需要类似校验，则可能就是复制这段 if-else 代码。

## 用策略模式重构表单校验

把校验逻辑封装成策略对象:

```js
var strategies = {
  isNonEmpty: function (value, errorMsg) {
    if (value === "") {
      return errorMsg;
    }
  },
  minLength: function (value, length, errorMsg) {
    if (value.length < length) {
      return errorMsg;
    }
  },
  isMobile: function (value, errorMsg) {
    if (!/(^1[3|5|8][0-9]{9}$)/.test(value)) {
      return errorMsg;
    }
  },
};
```

完成策略后，下面实现 Validator 类：

```js
var Validator = function () {
  this.cache = [];
};

Validator.prototype.add = function (dom, rule, errorMsg) {
  var ary = rule.split(":"); // 把 strategy 和参数分开
  this.cache.push(function () {
    // 把校验的步骤用空函数包装起来，并且放入 cache
    var strategy = ary.shift(); // 用户挑选的 strategy
    ary.unshift(dom.value); // 把 input 的 value 添加进参数列表
    ary.push(errorMsg); // 把 errorMsg 添加进参数列表
    return strategies[strategy].apply(dom, ary);
  });
};

Validator.prototype.check = function () {
  for (var i = 0, validatorFunc; (validatorFunc = this.cache[i++]); ) {
    var msg = validatorFunc(); // 开始校验，并取得校验后的返回信息
    if (msg) {
      // 如果有确切的返回值，说明校验没有通过
      return msg;
    }
  }
};
```

使用策略模式重构后，可以使用 add 方法来添加校验规则，这种校验规则可以复用在其他地方，其他项目中。
然后上述 3 个校验规则可以这么写：

```js
var validataFunc = function () {
  var validator = new Validator(); // 创建一个 validator 对象

  validator.add(registerForm.username, "isNonEmpty", "用户名不能为空");
  validator.add(registerForm.password, "minLength:6", "密码长度不能少于 6 位");
  validator.add(registerForm.phone, "isMobile", "手机号码格式不正确");

  var errorMsg = validator.check();
  return errorMsg;
};

var registerForm = document.getElementById("registerForm");
registerForm.onsubmit = function () {
  var errorMsg = validataFunc(); // 如果 errorMsg 有确切的返回值，说明未通过校验
  if (errorMsg) {
    alert(errorMsg);
    return false;
  }
};
```

若其他小伙伴校验规则是用户名不能少于 4 个字符。则只需要修改少量代码：

```js
validator.add(
  registerForm.userName,
  "minLength:10",
  "用户名长度不能小于 10 位"
);
```

是不是比 if-else 好很多。

## 单个 input 框添加多个校验规则

实际需求中，一个 input 常常有多种校验规则。如：username 既不能为空，字符长度又不能小于 10.
想要这样写：

```js
validator.add(registerForm.username, [
  { strategy: "isNonEmpty", errorMsg: "用户名不能为空" },
  { strategy: "minLength:6", errorMsg: "用户名长度不能小于 10 位" },
]);
```

完整代码如下：

```js
/***********************策略对象**************************/

var strategies = {
  isNonEmpty: function (value, errorMsg) {
    if (value === "") {
      return errorMsg;
    }
  },
  minLength: function (value, length, errorMsg) {
    if (value.length < length) {
      return errorMsg;
    }
  },
  isMobile: function (value, errorMsg) {
    if (!/(^1[3|5|8][0-9]{9}$)/.test(value)) {
      return errorMsg;
    }
  },
};

/***********************Validator 类**************************/

var Validator = function () {
  this.cache = [];
};

Validator.prototype.add = function (dom, rules) {
  var self = this;

  for (var i = 0, rule; (rule = rules[i++]); ) {
    (function (rule) {
      var strategyAry = rule.strategy.split(":");
      var errorMsg = rule.errorMsg;

      self.cache.push(function () {
        var strategy = strategyAry.shift();
        strategyAry.unshift(dom.value);
        strategyAry.push(errorMsg);
        return strategies[strategy].apply(dom, strategyAry);
      });
    })(rule);
  }
};

Validator.prototype.start = function () {
  for (var i = 0, validatorFunc; (validatorFunc = this.cache[i++]); ) {
    var errorMsg = validatorFunc();
    if (errorMsg) {
      return errorMsg;
    }
  }
};

/***********************客户调用代码**************************/

var registerForm = document.getElementById("registerForm");

var validataFunc = function () {
  var validator = new Validator();

  validator.add(registerForm.userName, [
    { strategy: "isNonEmpty", errorMsg: "用户名不能为空" },
    { strategy: "minLength:6", errorMsg: "用户名长度不能小于 10 位" },
  ]);

  validator.add(registerForm.password, [
    { strategy: "minLength:6", errorMsg: "密码长度不能小于 6 位" },
  ]);

  validator.add(registerForm.phoneNumber, [
    { strategy: "isMobile", errorMsg: "手机号码格式不正确" },
  ]);

  var errorMsg = validator.start();
  return errorMsg;
};

registerForm.onsubmit = function () {
  var errorMsg = validataFunc();

  if (errorMsg) {
    alert(errorMsg);
    return false;
  }
};
```

在 JS 中，策略一般被函数替代。此时策略模式就是一种隐形的模式。理解策略模式，则更能理解函数的好处。

## 参考

- 《JavaScript 设计模式与开发实战》曾探
