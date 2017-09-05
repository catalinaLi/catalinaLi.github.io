---
title: 小白从头到脚搭建zookeeper集群的过程
date: 2017-09-04 15:59:30
tags: zookeeper
categories: zookeeper
keywords: zookeeper搭建
---
![buildzk_logo](http://ou3np1yz4.bkt.clouddn.com/buildzk_logo.jpg)
>zookeeper的字面意思为动物园管理员,正如他的名字,各个子系统能正常为用户提供统一的服务。并且还可以作为Dubbo的注册中心来使用。今天进行了一番centos的安装到zookeeper集群的搭建,也遇到不少坑。特此记录下来搭建过程。

---
<!--more-->
## 环境准备
- VMware Workstation 11   
- centos 6.4镜像
- jdk-7u67-linux-x64.tar.gz
- zookeeper-3.4.6.tar.gz
- Xshell 
- Xftp

## 搭建linux环境
1.linux安装过程就不赘述了,网上有很多。可以参考[这一篇](http://blog.csdn.net/lzwglory/article/details/53468199)。需要注意的是:
安装过程中我们最好配置一下网络。可以参考[这一篇](https://jingyan.baidu.com/article/fc07f9891d186512ffe51935.html)。里面的ip最好前三段跟我们的本机一样,最后一段就随便取啦。DNS服务器这一栏可以填跟网关一样的内容。我安装的也是minimal模式。
2.安装好centos以后我们要更改一下网络连接方式。如图:
![buildzk_1](http://ou3np1yz4.bkt.clouddn.com/buildzk_1.png)
3.这样我们就安装好了一台linux,由于我们要搭建集群,所以我们再克隆2台linux:
![buildzk_2](http://ou3np1yz4.bkt.clouddn.com/buildzk_2.jpg)
除了这一步,其他的一直下一步就好
![buildzk_3](http://ou3np1yz4.bkt.clouddn.com/buildzk_3.jpg)
这时我们就得到了3台linux环境。可是由于是克隆的,所以后两台连ip地址都是一样的。所以我们需要更改一些配置来使得后2台也能有了自己的ip。参考[这一篇](http://www.linuxidc.com/Linux/2012-12/76248.htm)。
4.开启我们的三台linux环境,使用Xshell分别进行连接。
![buildzk_4](http://ou3np1yz4.bkt.clouddn.com/buildzk_4.png)
至此,linux环境就搭建成功了。
## 搭建zookeeper集群
1.由于zookeeper是Java编写的,运行在Java环境上，所以我们要先安装jdk。具体安装过程可以看我之前写的[centos7下破解安装JIRA 7.2](http://catalinali.top/2017/installjira/)的开头部分。
2.使用tar -zxvf 将`zookeeper-3.4.6.tar.gz`解压到某一个位置。
3.将zookeeper-3.4.6/conf目录下面的zoo_sample.cfg修改为zoo.cfg。
4.使用vi/vim命令修改`zoo.cfg`的内容如下图:
![buildzk_5](http://ou3np1yz4.bkt.clouddn.com/buildzk_5.png)
其中上面的红框是zookeeper的**数据日志目录**,可以更改成自己的位置。下面的红框是集群中服务的列表。
5.分别操作linux进入刚才修改的**数据日志目录**,新建一个myid文件。内容分别是**0**、**1**、**2**。没有错,里面就一个数字，用来唯一标识这个服务。这个id是很重要的，一定要保证整个集群中唯一。zookeeper会根据这个id来取出server.x上的配置。比如当前id为1，则对应着zoo.cfg里的server.1的配置。
6.使用关闭`service iptables stop`暂时关闭防火墙,或者使用`chkconfig iptables off`永久禁用防火墙。然后进入zookeeper下的bin目录,使用./zkServer.sh start同时对三个linux进行操作。
![buildzk_6](http://ou3np1yz4.bkt.clouddn.com/buildzk_6.png)
这时候我们再使用`./zkServer.sh status`来查看状态如果出现下图,恭喜你搭建成功
![buildzk_7](http://ou3np1yz4.bkt.clouddn.com/buildzk_7.png)
其中leader是主节点,follow是从节点。
但是大多数情况我们却出现**It is probably not running**。这时可以参考这篇[文章](http://blog.csdn.net/henni_719/article/details/53331724)去解决问题。

## 随便说说
首先感谢上文参考的所有文章！！
其次感谢这个开发的网络世界,让我们可以找到想找的所有资料！！！

---
>本文作者： catalinaLi
本文链接： http://catalinali.top/2017/buildzookeeper/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。