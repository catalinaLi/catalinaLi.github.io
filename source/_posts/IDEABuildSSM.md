---
title: 记录：使用IDEA搭建Maven+SSM的过程
date: 2017-08-15 15:51:18
tags: [SSM,IDEA]
categories: [IDEA,SSM]
keywords: [SSM,IDEA] 
---
![hellossm_15](http://ou3np1yz4.bkt.clouddn.com/hellossm_15.jpg)
# 前言
>IntelliJ IDEA被认为是当前 Java 开发效率最快的 IDE 工具。份额已经逐渐超越Eclipse。一直使用Eclipse的我也不禁想尝尝鲜，之前简单的使用它搭建了一下SSM环境，现在把他记录下来。

<!-- more -->

# 新建一个Maven项目

打开IDEA,选择新建一个项目
![hellossm_1](http://ou3np1yz4.bkt.clouddn.com/hellossm_1.png)
如图:首先我们选择一个maven Project,然后要创建模板勾选Create from archetype。由于我们准备新建一个web工程所以选择maven-archetype-webapp。
![hellossm_2](http://ou3np1yz4.bkt.clouddn.com/hellossm_2.png)
下一步:填写GroupId,ArtifactId。填写的标准就不用多说了吧。
![hellossm_3](http://ou3np1yz4.bkt.clouddn.com/hellossm_3.png)
下一步:选择使用的maven的本地位置,这个根据实际情况选择就好。
![hellossm_4](http://ou3np1yz4.bkt.clouddn.com/hellossm_4.png)
下一步:这一步会填写项目名称,根据实际来就好了。
![hellossm_5](http://ou3np1yz4.bkt.clouddn.com/hellossm_5.png)
然后点击Finish,一个空的web工程就建好了。

# 搭建SSM环境

![hellossm_6](http://ou3np1yz4.bkt.clouddn.com/hellossm_6.png)
IDEA里的java文件只能在Source Boot类型的文件夹下创建,所以我们要新建一个文件夹，然后将它的类型改为Source Boot:
![hellossm_7](http://ou3np1yz4.bkt.clouddn.com/hellossm_7.png)
这时候我们就可以新建需要的类了。ssm的配置还是那老一套，由于篇幅问题这里就不贴出来了。配置完的大体结构是这样的。
![hellossm_8](http://ou3np1yz4.bkt.clouddn.com/hellossm_8.png)

# 运行web工程
选择如图位置：
![hellossm_9](http://ou3np1yz4.bkt.clouddn.com/hellossm_9.png)
然后选择如图:
![hellossm_10](http://ou3np1yz4.bkt.clouddn.com/hellossm_10.png)
这里主要选择本地tomcat的位置
![hellossm_11](http://ou3np1yz4.bkt.clouddn.com/hellossm_11.png)
然后我们切换到第二栏Deployment:
![hellossm_12](http://ou3np1yz4.bkt.clouddn.com/hellossm_12.png)
选择如图的选项,注意这里一定要选择带exploded的这个:
![hellossm_13](http://ou3np1yz4.bkt.clouddn.com/hellossm_13.png)
选择OK，然后install-->运行tomcat。如果出现如图，则表示成功:
![hellossm_14](http://ou3np1yz4.bkt.clouddn.com/hellossm_14.png)

# 随便说说
IntelliJ IDEA现在已经被基本被认为是当前 Java 开发效率最快的 IDE 工具。对于用惯了Eclipse的我来说显然快要跟不上时代了,这篇文章只是简单的记录了一下搭建的过程,目的是快速熟悉一下IDEA的运行方式。然而关于SSM配置内容却只字未提。一个是因为关于SSM整合的文章现在网上多的是,大家只要一搜就好了。再一个是因为配置都是一大段一大段的,全部粘上来未免太占篇幅。
最后贴一个IDEA的[教程](https://youmeek.gitbooks.io/intellij-idea-tutorial/content/)

---

>本文作者： catalinaLi
本文链接： http://catalinali.top/2017/IDEABuildSSM/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。