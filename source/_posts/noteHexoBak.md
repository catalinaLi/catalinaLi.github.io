---
title: 笔记：使用hexo，如果换了电脑怎么更新博客
date: 2018-04-26 16:02:00
tags: [note,hexo]
categories: hexo
keywords: hexo
---
![note_hexo_install_logo](http://ou3np1yz4.bkt.clouddn.com/note_hexo_install_logo.jpg)
> 最近换了工作，忙着熟悉业务，好久没写博客了。换了新环境，好多东西都要重装。Hexo博客就是其中之一，这里我从万能的知乎上找了一个感觉很赞的方法，现在把文章搬运过来。话不多说，我们快来看看他是怎么做吧。

---

<!--more-->

## 一、引言
其实，Hexo生成的文件里面是有一个.gitignore的，所以它的本意应该也是想我们把这些文件放到GitHub上存放的。但是考虑到如果每个GitHub Pages都需要额外的一个仓库存放这些文件，就显得特别冗余了。这个时候就可以用分支的思路！一个分支用来存放Hexo生成的网站原始的文件，另一个分支用来存放生成的静态网页。

## 二、搭建的流程
**1.** 创建仓库，http://catalinaLi.github.io；
**2.** 创建两个分支：master 与 hexo；
**3.** 设置hexo为默认分支（因为我们只需要手动管理这个分支上的Hexo网站文件）；
**4.** 使用git clone git@github.com:catalinaLi/catalinaLi.github.io.git拷贝仓库；
**5.** 在本地http://catalinaLi.github.io 文件夹下通过Git bash依次执行npm install hexo、hexo init、npm install 和 npm install hexo-deployer-git（此时当前分支应显示为hexo）;
**6.** 修改_config.yml中的deploy参数，分支应为master；
**7.** 依次执行git add .、git commit -m "..."、git push origin hexo提交网站相关的文件；
**8.** 执行hexo g -d生成网站并部署到GitHub上。这样一来，在GitHub上的http://catalinaLi.github.io 仓库就有两个分支，一个hexo分支用来存放网站的原始文件，一个master分支用来存放生成的静态网页。完美( •̀ ω •́ )y！
## 三、日常的改动流程
在本地对博客进行修改、添加新博文、修改样式等等可以参照以下流程：
**1.** 依次执行git add .、git commit -m "..."、git push origin hexo指令将改动推送到GitHub（此时当前分支应为hexo）；
**2.** 然后才执行hexo g -d发布网站到master分支上。虽然两个过程顺序调转一般不会有问题，不过逻辑上这样的顺序是绝对没问题的（例如突然死机要重装了，悲催....的情况，调转顺序就有问题了）。

## 四、拉取备份
本地资料丢失后的流程当重装电脑之后，或者想在其他电脑上修改博客，可以使用下列步骤：
**1.** 使用git clone git@github.com:CrazyMilk/CrazyMilk.github.io.git拷贝仓库（默认分支为hexo）；
**2.** 在本地新拷贝的http://catalinaLi.github.io 文件夹下通过Git bash依次执行下列指令：npm install hexo、npm install、npm install hexo-deployer-git（记得，不需要hexo init这条指令）。

## 参考资料
* https://www.zhihu.com/question/21193762

---
>本文作者： catalinaLi
本文链接： http://catalinali.top/2018/noteHexoBak/
