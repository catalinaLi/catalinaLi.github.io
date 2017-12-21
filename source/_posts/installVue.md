---
title: Vue.js小白入门，搭建开发环境
date: 2017-11-27 16:39:32
tags: vue.js
categories: vue.js
keywords: vue.js
---
![installvue_logo](http://ou3np1yz4.bkt.clouddn.com/installvue_logo.jpg)
>最近Vue.js的热度持续上升，甚至有标题说2017再不会Vue.js就out了。而作为一个不排斥前段的后端码农来说，当然也要跟得上时代。近来准备放下手中的DOM操作，来一次Vue.js从入门到放弃。现将环境搭建过程记录下来。

---
<!--more-->

## 环境准备
- Node.js Javascript的运行时环境
- npm Node.js下的包管理工具
- webpack 前端资源模块化管理和打包工具
- vue-cli 脚手架构建工具
- cnpm  npm的淘宝镜像

如果你像我一样是个后端开发者，并且对以上的工具还处在一脸懵逼的状态下。那么可以先看一下这篇文章[萌新也能懂的现代 JavaScript 开发](https://zhuanlan.zhihu.com/p/31044340)。了解一下现代 JavaScript的演变过程。
### Vue.js安装
**1.** Node.js的安装非常容易，首先从[官网](https://nodejs.org/en/download/)下载你所需操作系统的版本，然后一直下一步就ok，这里贴个菜鸟教程的[传送门](http://www.runoob.com/nodejs/nodejs-install-setup.html)。
安装完成之后，在命令行敲出`node -v`，如果出现对应版本号，则表示安装成功。
![installvue_01](http://ou3np1yz4.bkt.clouddn.com/installvue_01.jpg)
**2.** npm是随同Node.js一起安装的包管理工具,直接在命令行敲出`npm -v`就可以查看是否安装成功。
![installvue_02](http://ou3np1yz4.bkt.clouddn.com/installvue_02.jpg)
npm包管理器虽然有了，但是由于npm下载需要依赖包的服务器地址在国外，导致很多资源访问会很慢。所以我们可以安装淘宝的国内镜像。
**3.** 在命令行敲出` npm install -g cnpm --registry=http://registry.npm.taobao.org`。
这样就可以使用 cnpm 命令来安装模块了：
```linux
cnpm install [name]
```
**4.** 安装webpack
```
cnpm install webpack -g
```
**5.** 安装vue脚手架
```
npm install vue-cli -g
```
### 初始化一个Vue.js环境
在电脑上新建一个文件夹用来存放我们的代码。然后使用命令行进入这个文件夹`cd 目录路径`。
之后使用命令
```cmd 
vue init webpack name
```
来初始化一个vue环境，这个命令的意思是初始化一个项目，其中webpack是构建工具，也就是整个项目是基于webpack的。在安装过程会有一些初始化的设置，我们可以采用默认配置，一路回车 。
![installvue_04](http://ou3np1yz4.bkt.clouddn.com/installvue_04.png)
从上图的我们还可以看到vue很贴心的告诉了我们快速开始(To get started)的命令
**安装项目依赖**
一定要从官方仓库安装，npm 服务器在国外所以这一步安装速度会很慢。
```
npm install
```
不要从国内镜像cnpm安装(会导致后面缺了很多依赖库)
```
cnpm install
```
安装 vue 路由模块vue-router和网络请求模块vue-resource
```
cnpm install vue-router vue-resource --save
```
启动项目
```
npm run dev
```
运行成功以后他会告诉你ip和端口号
![installvue_05](http://ou3np1yz4.bkt.clouddn.com/installvue_05.png)
访问这个地址
![installvue_06](http://ou3np1yz4.bkt.clouddn.com/installvue_06.png)
如果出现上图。恭喜你，已经可以开始Vue.js之旅了。

---
>本文作者： catalinaLi
本文链接： http://catalinali.top/2017/installVue/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。

