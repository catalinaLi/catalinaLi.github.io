---
title: 如何在同一台电脑上使用github和gitlab
date: 2018-04-27 09:50:24
tags: [git,github]
categories: git
keywords: [git,github]
---
![gitlabgithub_logo](http://ou3np1yz4.bkt.clouddn.com/gitlabgithub_logo.jpg)
> 换了工作后使用的是gitlab，这样对github的使用会有影响。为了解决这个问题，搜了很多资料后完美解决。现在把它记录下来。

<!--more-->

## 前言
在同一台电脑上使用github和gitlab，主要的思想就是使用不同的仓库时，切换成不同的账号。不同账号的sshKey分别对应github和gitlab。接下来跟着我看看怎么做吧^_^

## 一、生成ssh密钥

这里我们要做的事情就是分别对githubn和gitlab生成对应的密钥（默认情况下本地生成的秘钥位于/Users/用户名/.ssh/），并且配置git访问不同host时访问不同的密钥，流程如下：
**1、** 在gitbash中使用`ssh-keygen -t rsa -C "公司邮箱地址"`生成对应的gitlab密钥：*id_rsa*和*id_rsa.pub*
**2、** 将gitlab公钥即*id_rsa.pub*中的内容配置到公司的gitlab上
**3、** 在gitbash中使用`ssh-keygen -t rsa -C "github地址" -f ~/.ssh/github_rsa`生成对应的github密钥：*github_rsa*和*github_rsa.pub*
**4、** 将github公钥即*github_rsa.pub*中的内容配置到自己的github上
**5、** 进入密钥生成的位置，创建一个`config`文件，添加配置：

``` yml
# gitlab
Host gitlab
	HostName git.xxx.com #这里填你的gitlab的Host
	User git
	IdentityFile ~/.ssh/id_rsa
# githab
Host github.com
	HostName github.com
	User git
	IdentityFile ~/.ssh/github_rsa

```

## 二、测试连接

在密钥的生成位置/Users/用户名/.ssh/下使用gitbash运行` ssh -T git@hostName`命令测试sshkey对gitlab与github的连接：

``` linux
catalinaLi@catalinaLi MINGW64 ~/.ssh
$ ssh -T git@gitlab
Welcome to GitLab, catalinaLi!

catalinaLi@catalinaLi MINGW64 ~/.ssh
$ ssh -T git@github.com
Hi catalinaLi! You've successfully authenticated, but GitHub does not provide shell access.
```

如果出现上图结果就说明连接成功，如果不是这样的话就仔细看看第一步哪里做错了。

## 三、配置git仓库

这里我们要用到git的config配置。git的config文件记录了用户的基本信息，我们的账号信息也在里面，这里我们要做的就行在不同的本地仓库配置不同的用户信息来访问不同的远程仓库。config文件通常有三个位置：

- system （系统级别）：
    位于Windows下在git的安装目录， 包含了适用于系统所有用户和所有库的值。如果你传递参数选项’--system’ 给 git config，它将明确的读和写这个文件。 
- global（用户级别）: 
    位于~/.gitconfig，具体到你的用户。你可以通过传递--global 选项使Git 读或写这个特定的文件。
- local（仓库级别）：
    位于 .git/config，无论你当前在用的库是什么，特定指向该单一的库。每个级别重写前一个级别的值。

简单了解后我们就可以来配置了

**1.** 用户级别配置
因为公司的代码使用频率较高，所以我们将git配置文件的global（用户级别）设置为公司的gitlab账号,在gitlab中使用如下命令：

``` linux
$ git config --global user.name 'catalinaLi' #公司账号名称
$ git config --global user.email 'catalinaLi@companyName.com' #公司账号邮箱
```

**2.** 仓库级别配置
我们将local（仓库级别）配置成github的账号。此时我们需要先**init**一个git的仓库并进入里面后执行如下命令：

``` linux
$ git config --local user.name 'username' #github账号名称
$ git config --local user.email 'username@gmail.com' #github账号邮箱
```

之后我们github的代码都应该在这个仓库下拉取。

**3.** 克隆代码

```
$ git clone git@github.com:catalinaLi/ideaTaotao.git
```

在使用github克隆代码时，因为配置了config, 所以会通过配置的host自动查找到git@github.com。对于gitlab也是相同的道理

至此，在同一台电脑上使用gitlab与github已经成功了，尽情感受吧。另外，大家可以寻找[度娘](https://www.baidu.com/s?ie=utf-8&f=8&rsv_bp=1&tn=baidu&wd=git%20config&oq=git%25E5%259B%25BE%25E7%2589%2587&rsv_pq=8af24b1f00001879&rsv_t=f935uktxm1WFti3L2TeFRHq8XdFpo%2B3%2FcGp%2F14sVbaYetcqU4uCbhZ5DCCQ&rqlang=cn&rsv_enter=1&inputT=1397&rsv_sug3=14&rsv_sug1=18&rsv_sug7=100&bs=git%E5%9B%BE%E7%89%87)来学习关于git的config的更多使用

## 参考资料

http://www.arccode.net/config-multi-git-account-and-workspaces.html
https://segmentfault.com/a/1190000002994742

---
>本文作者： catalinaLi
本文链接： http://catalinali.top/2018/noteGithubGitlab/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。