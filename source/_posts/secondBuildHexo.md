---
title: Hexo骚操作：主题配置|搜索|评论|SEO|统计|图床
date: 2017-08-10 16:12:56
tags: hexo
categories: hexo
---
![front-pic2](http://ou3np1yz4.bkt.clouddn.com/front-pic2.jpg)

## 前言

>相信各位在看过上一篇blog[手把手教你使用hexo搭建属于你的个人博客](http://catalinali.top/2017/firstBuildHexo/)后已经初步搭建了属于自己的博客，不过细心的你可能已经发现这样的博客还是缺点什么，现在就来说说Hexo的骚操作:添加主题、统计、评论、SEO等等等等。

---

<!-- more -->
承接上篇最后说过的:根目录下的`_config.yml`叫做**站点配置文件**，主题下文件夹的`_config.yml`叫做**主题配置文件**。好了,现在进入正题，今天我们要对Hexo进行一些脱胎换骨的操作，让你从内到外了解Hexo，要完成的操作如下：

 - 添加个性化主题
 - 在github保存Hexo
 - 添加评论系统
 - 添加搜索与统计
 - 添加图床

## 一、添加个性化主题

Hexo默认的主题可能满足不了你的胃口，我们这里选择换一个更加个性化的主题，首先先去挑一个你心仪的主题:[传送门](https://www.zhihu.com/question/24422335)。大家也可以自行寻找一些主题。这里使用人气最高的Next主题为例：
**1.安装主题**
打开[github下载地址](https://github.com/iissnan/hexo-theme-next)，clone下载地址
![buildHexo2_1](http://ou3np1yz4.bkt.clouddn.com/buildHexo2_1.png)
进入你的Hexo根目录右键选择Git Bash Here,在命令行中输入
```
$ git clone https://github.com/iissnan/hexo-theme-next.git themes/next
```
这时在我们的`theme`文件夹下就会有一个名next的主题文件夹。
**2.配置主题**
进入**站点配置文件**,找到theme选项，后面填写你要使用的主题名字。这里再次强调一下,_config.yml使用的是`YAML`语法。选项后面要先加一个空格才能填值，遇到无法解决的问题不妨对格式进行[校验](http://www.yamllint.com/)。
![buildHexo2_2](http://ou3np1yz4.bkt.clouddn.com/buildHexo2_2.png)
这时候就可以使用调试模式来查看一下主题了:
```
hexo clean #清除缓存
hexo g #自动生成静态页面,hexo generate的缩写
hexo s --debug #调试模式,在浏览器进入http://localhost:4000/进行访问
```
发现没有什么问题就可以使用`hexo d`进行发布了,Next主题有他的[官方文档](http://theme-next.iissnan.com/getting-started.html),一些基本的设置都可以在上面找的，这里就不赘述了。
## 二、在github保存Hexo
当你慢慢了解Hexo以后，不知你是否会有这样的想法:当我换了一台电脑，我该怎样继续更新的我blog。查阅了众多资料后找到了我心中答案:[传送门](https://www.zhihu.com/question/21193762)。我们要用的就是知乎中1楼的这个高亮答案。过程他已经说的很清楚了，但是这里我要说几个我遇到的坑:

 - 在明白了答主的步骤后，我们发现刚才的主题是用git拉下来的,那么Next主题文件夹下就会有一个**.git**的隐藏文件夹,这个文件会影响我们对博客文件的提交，所以我们要首要的一步是删除Next文件夹下隐藏的**.git**文件夹
 - 这篇文章楼下答主[**KOKO**](https://www.zhihu.com/people/KOKO-55/answers)所说的内容。在我们拉下来仓库以后会生成一个.git文件夹。这个文件夹记录了我们所对应github的分支。然而在进行了hexo命令操作以后会覆盖这个.git文件夹。所以应该提前将这个文件夹备份一下,然后回过头来进行覆盖。

## 三、为Hexo添加评论系统

官方文档里推荐了好多个评论系统,一路用过来发现DISQUS被墙了,网易云跟帖跟多说关闭服务了。现在还比较好用的就剩下来必力跟畅言了,并且我们选择的Next昨天还很贴心的集成了这两个评论系统。

- 添加来必力
1.注册[来必力](https://livere.com/),注册过程中可能会冒出一些棒子语言，让我们使用直觉注册好后点击我的页面-->代码管理-->data-uid
![buildHexo2_3](http://ou3np1yz4.bkt.clouddn.com/buildHexo2_3.png)
2.复制我们的这个id,粘贴到主题配置文件`livere_uid`选项后面
![buildHexo2_4](http://ou3np1yz4.bkt.clouddn.com/buildHexo2_4.png)
这时你再重新部署你的Hexo,是不是已经有了来必力评论系统
- 添加畅言
畅言的UI感觉比来必力清爽一些，但是注册的过程需要ICP备案号,这个比较麻烦
1.注册[畅言](http://changyan.kuaizhan.com/),进入账户管理-->后台总览-->畅言秘钥
![buildHexo2_5](http://ou3np1yz4.bkt.clouddn.com/buildHexo2_5.png)
2.复制畅言秘钥，粘贴到主题配置文件`changyan`后面
![buildHexo2_6](http://ou3np1yz4.bkt.clouddn.com/buildHexo2_6.png)

## 四、为Hexo搜索与统计

搜索与统计都比较简单，[官方文档](http://theme-next.iissnan.com/third-party-services.html#analytics-busuanzi)有详尽的明细,统计推荐不蒜子，简单粗暴。
搜索的话我使用的是本地搜索，即Local Search。他的原理是在你本地生成一个xml文件,搜索的时候对这个文件进行检索。下面说说安装步骤
1.执行下面2个命令
```
npm install hexo-generator-search --save
npm install hexo-generator-searchdb --save
```
2.打开站点配置文件，新增以下内容：
```
search:
  path: search.xml
  field: post
  format: html
  limit: 10000
```
3.打开主题配置文件，启用本地搜索功能：
```
# Local search
local_search:
  enable: true
```

## 五、为Hexo添加图床

以后写博客避免不了常常使用图片,可是Github Pages是有容量限制的,总不能全部都作为静态文件进行上传吧。这里推荐一个好评的[七牛云](https://portal.qiniu.com/signup?code=3letjvek8jgia)图床。七牛云不是免费的，但每个用户有10GB免费存储，每月10GB免费下载流量,对于博客使用来说够了。使用方法:
1.打开链接并注册,单机 对象存储-->创建空间。
![buildHexo2_7](http://ou3np1yz4.bkt.clouddn.com/buildHexo2_7.png)
2.当我们使用图片时。需要先上传到七牛,然后复制外链,之后就可以在MarkDown文章中使用了。
![buildHexo2_8](http://ou3np1yz4.bkt.clouddn.com/buildHexo2_8.png)
3.每次这样获取图片链接,相信你一定会很烦的。这里有一个针对七牛的小工具[Mpic](http://mpic.lzhaofu.cn/)。简化了这一步骤,相信你一定会爱上他的。

---

>本文作者： catalinaLi
本文链接： http://catalinali.top/2017/secondBuildHexo/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。