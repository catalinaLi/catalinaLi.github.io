---
title: 解析Vue.js的MVVM模式
date: 2018-08-31 11:44:06
tags:
categories:
keywords:
---
![getMVVM_logo](http://ou3np1yz4.bkt.clouddn.com/getMVVM_logo.png)
>近年来前端一个明显的开发趋势就是架构从传统的 MVC 模式向 MVVM 模式迁移。在传统的 MVC 下，当前前端和后端发生数据交互后会刷新整个页面，从而导致比较差的用户体验。因此我们通过 Ajax 的方式和网关 REST API 作通讯，异步的刷新页面的某个区块，来优化和提升体验。

<!--more-->

---

## 一、MVP模式

我们以前使用JQuery操作Dom的模式就是遵循了MVP模式,我们先来看一下MVP模式的图示：

![getMVVM_1](http://ou3np1yz4.bkt.clouddn.com/getMVVM_1.png)

- 视图（View）：用户界面。
- 控制器（Presenter）：业务逻辑
- 模型（Model）：数据保存

MVP有以下特点：

1. 各部分之间的通信，都是双向的。
2. View 与 Model 不发生联系，都通过 Presenter 传递。
3. View 非常薄，不部署任何业务逻辑，称为"被动视图"（Passive View），即没有任何主动性，而 Presenter非常厚，所有逻辑都部署在那里。

在我们常规的DOM操作中，Model层的数据一般通过AJAX获取，Presenter层通常就是我们的js逻辑而相应的View就是我们用户看到的界面。

## 二、MVVM模式
MVVM是Model-View-ViewModel的简写。它本质上就是MVP的改进版。MVVM 就是将其中的View 的状态和行为抽象化，让我们将视图 UI 和业务逻辑分开。

我们先来看一下图示：

![getMVVM_2](http://ou3np1yz4.bkt.clouddn.com/getMVVM_2.png)

它与MVP的区别在于它采用双向绑定（data-binding）：View的变动，自动反映在 ViewModel，反之亦然。Vue.js 正是采用了这种模式：

![getMVVM_3](http://ou3np1yz4.bkt.clouddn.com/getMVVM_3.png)
Vue.js 可以说是MVVM 架构的最佳实践，专注于 MVVM 中的 ViewModel，不仅做到了数据双向绑定，而且也是一款相对比较轻量级的JS 库，API 简洁，很容易上手。

小伙伴们，快来试试Vue.js吧！

## 参考文章

[MVC，MVP 和 MVVM 的图示](http://www.ruanyifeng.com/blog/2015/02/mvcmvp_mvvm.html)

---
>本文作者： catalinaLi
本文链接： http://catalinali.top/2018/getMVVM/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。



