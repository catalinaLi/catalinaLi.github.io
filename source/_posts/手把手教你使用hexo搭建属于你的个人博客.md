---
title: 手把手教你使用hexo搭建属于你的个人博客
date: 2017-08-06 14:15:15
tags: hexo
categories: hexo
---
![front-pic-1](http://ou3np1yz4.bkt.clouddn.com/front-pic1.jpg)

## 前言

>    每当看到别人精美的个人博客时，不知你是否有一点点的羡慕。别急，现在我就来手把手教你搭建自己的个人博客。
    在技术日趋成熟的今天，有着很多种快速生成博客的框架:Hexo,Jekyll,Wordpress等等。今天我们就用`Hexo`来带着大家完成自己的博客 

---
<!-- more -->
## 什么是Hexo?
Hexo[官网](https://hexo.io/)中说是这么描述的：**A fast, simple & powerful blog framework**,即:一个快速、简单且强大的博客快速生产工具。它的简单体现在你完全有可能在30分钟内就生成属于你的个人博客。而它的强大体现在你对细节的调整上完全有可能花上一天的时间。

## 一、巧妇难为无米之炊:准备搭建环境
### 1.安装node.js
Node.js 的实质是一个JavaScript运行环境,这里我们主要使用它来生成我们博客的静态页面。从[官网](http://nodejs.cn/)下载最新的安装包进行默认安装就好。安装过程略。
### 2.安装git环境
git是最流行的分布式版本控制系统，我们使用它主要是与github进行交互。安装[git](https://git-for-windows.github.io/)使用默认选项安装即可，安装过程略。如果你还对git不是特别熟悉，推荐一个学习git的教程:[传送门](https://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/)
### 3.注册github
[github](https://github.com/)就不用说了吧，它是一个面向开源及私有软件项目的托管平台。几乎所有的程序员都听说过它的大名。就正常注册一个账号就好了。
注册号以后首先给我们的账号添加本机的SSH，具体方法及原因在[这篇文章](https://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/001374385852170d9c7adf13c30429b9660d0eb689dd43a000)已经有了详细说明，并且方法也很简单
## 二、上正菜：开始搭建博客
环境都准备好后，我们就可以开始安装博客了:
**1.创建文件夹**
    在本地新建一个文件夹用于存放我们的博客，并且右键菜单选择Git Bash Here,然后在Git Bash里输入：

    npm install hexo

然后回车，如图：

![buildHexo_1](http://ou3np1yz4.bkt.clouddn.com/buildHexo_1.png)
我在执行这个的时候出现了下图的警告,但是并不影响我们的安装，不用理会它。
![buildHexo_5](http://ou3np1yz4.bkt.clouddn.com/buildHexo_5.png)
如果没有输出err之类的错误并且目录下多了一个node_modules文件夹，那这步就算成功了
![buildHexo_6](http://ou3np1yz4.bkt.clouddn.com/buildHexo_6.png)

**2.执行hexo命令**
依次执行以下3个命令:

    hexo init  --初始化hexo环境,这时会在目录下自动生成hexo的文件
    npm install --安装npm依赖包
    hexo generate --生成静态页面
    hexo server --生成本地服务
    
好了，这时候我们打开浏览器输入[http://localhost:4000](http://localhost:4000)看看可不可以访问。如果默认的hexo博客出现，那么恭喜你，你已经搭建好了自己的博客，接下来我们就要将它发布到网上。
![buildHexo_11](http://ou3np1yz4.bkt.clouddn.com/buildHexo_11.png)
**3.可能遇到的报错**:

- **日志报错**
  这个报错一般是由于在命令执行中用户使用Ctrl+C强制中断了命令的执行，导致log中记录已经执行，但实际没有执行完成。解决办法:删除图中路径下的.log文件
![buildHexo_7](http://ou3np1yz4.bkt.clouddn.com/buildHexo_7.png)

- **在非空文件夹下执行`hexo init`命令**
 `hexo init`这个命令是自动生成hexo目录时使用的命令，使用他有一个前提是必须是空文件夹，如果出现了这个错误，把所有文件删除就行。如果还是报错，别着急，看看是不是有隐藏文件没有删除。
![buildHexo_8](http://ou3np1yz4.bkt.clouddn.com/buildHexo_8.png)

- **hexo命令未找到**
  有的同学可能会出现在执行hexo命令时出现`conmand not found`的提示，这是由于hexo没有配到环境变量中，只需要手动配置一下就好了，这里演示一下win7的配置方式，其他系统也差不多，自行[百度](https://www.baidu.com/)就好:
1.找到并进入根目录下**node_modules**文件夹,这时我们发现里面有很多文件夹，找到`hexo`文件夹,这里我们可以看到一个`bin`文件夹，进到`bin`目录下，复制当前路径:
![buildHexo_9](http://ou3np1yz4.bkt.clouddn.com/buildHexo_9.png)
2.右键我的电脑-->高级系统设置-->高级-->环境变量。在系统变量那栏找到Path并双击这行,在弹出的`编辑系统变量`这栏的变量值的**最后**先输入一个分号`；`表示与前一个变量隔开,然后再把刚才复制的hexo路径添加到分号后面。
![buildHexo_10](http://ou3np1yz4.bkt.clouddn.com/buildHexo_10.png)
  

## 三、万事具备，只欠东风：将本地博客发布到网络上
这时候就要用到了我们的github：
**1.创建远程仓库**
新建一个跟自己账号**名字**一样的空仓库，如图：
![buildHexo_2](http://ou3np1yz4.bkt.clouddn.com/buildHexo_2.png)
![buildHexo_3](http://ou3np1yz4.bkt.clouddn.com/buildHexo_3.png)
**2.连接本地与远程github仓库**
打开本地博客的文件夹，打开**_config.yml**进行编辑
![buildHexo_4](http://ou3np1yz4.bkt.clouddn.com/buildHexo_4.png)
翻到文件最下方，将deploy的选项改成以下的形式，并将yournmae修改为你自己的名称：
    
    deploy:
    type: git
    repo: git@github.com:yourname/yourname.github.io.git
    branch: master 
    
然后在GitBash中执行

    npm install hexo-deployer-git --save
    
这时候，我们再最后执行一句

    hexo deploy

就可以在浏览器中访问http://yourname.github.io/来进入你的博客啦
大功告成！！
## 四、一鼓作气：详细了解Hexo
博客已经可以访问了，但我相信大家对Hexo还是一头雾水，现在我们来深入学习一下Hexo:
**1.Hexo的基本命令**

    hexo generate --生成个人博客所需的静态页面
    hexo server --本地预览
    hexo deploy --部署我们的个人博客
    hexo clean --清除缓存
    
这几个命令都能用首字母缩写完成

    hexo g --generate 
    hexo s --server 
    hexo d --deploy 

**2.写文章的需要用到下面的命令**

    hexo new "postName" --新建文章
    hexo new page "pageName" --新建页面

编辑我们的博客的时候可以使用
    
    hexo s --debug

然后访问[http://localhost:4000/](http://localhost:4000/)来进入调试模式，更改了配置或文章后随时刷新页面来查看效果。
Hexo的文章支持的是`MarkDown`语法。网上有很多资料，这里提供一个[传送门](https://www.zybuluo.com/mdeditor)。

**3.我们每次部署的步骤是**
    
    hexo clean 
    hexo generate 
    hexo deploy

后两步可以简写为`hexo g -d`，另外我们也可以使用`hexo help`来查看hexo命令帮助

**4.目录结构说明**
hexo init 出来的文件各自的作用如下:
   
      `-----------
      |  +-- .deploy       #hexo deploy生成的文件
      |  +-- node_modules  #npm组件
      |  +-- public        #生成的静态网页文件
      |  +--scaffolds      #模板
      |  +-- source        #博客正文和其他源文件
      |  |   +-- _posts    #我们自己写的文章以md结尾
      |  +-- themes        #主题
      |  +-- _config.yml   #全局配置文件
      |  `-- package.json  #定义了hexo所需要的各种模块

**5.配置文件**
有时候我们部署了以后自己博客的链接打不开,查看生成的静态文件也没有index.html,或者是各种奇怪的报错。这时候有可能是我们的配置文件`_config.yml`格式出现了问题。这时候不妨去一些YAML格式检测网站去检测一下格式是否正确:[传送门](http://www.yamllint.com/)。
## 五、结语
>完成上面的操作,你就已经一只脚踏进了`hexo`的大门,这时的你肯定还有很多疑问,比如博客的头像怎么更换，博客的主题怎么配置等等等等。这里先留下一个悬念,有兴趣的同学可以先行查询一些资料^_^
    