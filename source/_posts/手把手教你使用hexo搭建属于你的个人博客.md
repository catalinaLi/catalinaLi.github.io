---
title: 手把手教你使用hexo搭建属于你的个人博客
date: 2017-08-06 14:15:15
tags: [hexo,git,github]
categories: hexo
---
![front-pic-1](http://ou3np1yz4.bkt.clouddn.com/front-pic1.jpg)
# 前言
>    每当看到别人精美的个人博客时，不知你是否有一点点的羡慕。别急，现在我就来手把手教你搭建自己的个人博客。
    在技术日趋成熟的今天，有着很多种快速生成博客的框架:Hexo,Jekyll,Wordpress等等。今天我们就用`Hexo`来带着大家完成自己的博客 

---
<!-- more -->

# 什么是Hexo?
Hexo[官网](https://hexo.io/)中说是这么描述的：**A fast, simple & powerful blog framework**,即:一个快速、简单且强大的博客快速生产工具。它的简单体现在你完全有可能在30分钟内就生成属于你的个人博客。而它的强大体现在你对细节的调整上完全有可能花上一天的时间。

# 一、巧妇难为无米之炊:准备搭建环境
### 1.安装node.js
Node.js 的实质是一个JavaScript运行环境,这里我们主要使用它来生成我们博客的静态页面。从[no.js官网](http://nodejs.cn/)下载下最新的安装包进行默认安装就好。安装过程略。
### 2.安装git环境
git是最流行的分布式版本控制系统，我们使用它主要是与github进行交互。安装[git](https://git-for-windows.github.io/)使用默认选项安装即可，过程略。如果你还对git不是特别熟悉，推荐一个学习git的教程:[传送门](https://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/)
### 3.注册github
[github](https://github.com/)就不用说了吧，它是一个面向开源及私有软件项目的托管平台。几乎所有的程序员都听说过它的大名。就正常注册一个账号就好了。
# 二、上正菜：开始搭建博客
环境都准备好后，我们就可以开始安装博客了：
首先，新建一个文件夹用于存放我们的博客，并且右键菜单选择Git Bash Here,然后在Git Bash里输入：

    npm install hexo

然后回车，如图：

![buildHexo_1](http://ou3np1yz4.bkt.clouddn.com/buildHexo_1.png?v=2)

之后依次执行以下3个命令

    hexo init  --初始化hexo环境
    npm install --安装依赖包
    hexo generate --生成静态页面
    hexo server --生成本地服务
    
好了，这时候我们打开浏览器输入[http://localhost:4000](http://localhost:4000)看看可不可以访问。如果默认的hexo博客出现，那么恭喜你，你已经搭建好了自己的博客，接下来我们就要将它发布到网上。
# 三、万事具备，只欠东风：将本地博客发布到网络上
这时候就要用到了我们的github：
1.创建一个跟自己账号**名字**一样仓库，如图：
![buildHexo_2](http://ou3np1yz4.bkt.clouddn.com/buildHexo_2.png)
![buildHexo_3](http://ou3np1yz4.bkt.clouddn.com/buildHexo_3.png)
现在我们要做的就是将本地博客与刚创建的github仓库相连接:打开本地博客的文件夹，打开**_config.yml**进行编辑
![buildHexo_4](http://ou3np1yz4.bkt.clouddn.com/buildHexo_4.png?v=2)
翻到文件最下方，找到以下选项并将yournmae修改为你自己的名称：
    
    deploy:
    type: git
    repo: git@github.com:yourname/yourname.github.io.git
    branch: master 
    
然后再GitBash中执行

    npm install hexo-deployer-git --save
    
这时候，我们再最后执行一句

    hexo deploy

就可以在浏览器中访问http://yourname.github.io/来进入你的博客啦
大功告成！！
# 四、一鼓作气：详细了解Hexo
博客已经可以访问了，但我相信大家对Hexo还是一头雾水，现在我们来学习一下Hexo的基本命令

    hexo generate --生成个人博客所需的静态页面
    hexo server --本地预览，后面跟--debug选项可以进入调试模式
    hexo deploy --部署我们的个人博客
    hexo clean --清除缓存

写文章的需要用到下面的命令

    hexo new "postName" --新建文章
    hexo new page "pageName" --新建页面

Hexo的文章支持的是MarkDown语法，网上有很多资料，这里提供一个[传送门](https://www.zybuluo.com/mdeditor)。

所以以后我们每次部署的步骤是
    
    hexo clean 
    hexo generate 
    hexo deploy

后两步可以简写为`hexo g -d`，另外我们也可以使用`hexo help`来查看hexo命令帮助
# 五、结语
>看了上面的内容,你可能会有很多疑问,比如怎么换头像、怎么添加评论、怎么添加目录。到这里,我们其实只是接触到了Hexo的冰山一角,还有很多个性化的配置需要我们大家来配置,这里我就不详细说明了,等待大家自行去发掘^_^
    



