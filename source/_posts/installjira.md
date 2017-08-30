---
title: centos7下破解安装JIRA 7.2
date: 2017-08-16 11:41:50
tags: jira
categories: jira
keywords: jira
---

![hello_jira](http://ou3np1yz4.bkt.clouddn.com/hellojira_1.jpg)
>JIRA是Atlassian公司出品的项目与事务跟踪工具,是一款Code Review利器。实习的时候帮公司安装了一下jira，发现网上的资料参差不齐，现在抽空把搭建的过程一步步记录下来。有兴趣的朋友可以参考下。

---

<!-- more -->

# 一、环境搭建
 - **jdk的搭建**
jira 7.2的运行需要jdk1.8的依赖，首先去[oracle官网](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)下载linux版本的jdk，然后我们开始进行安装。
1. 找到一个目录解压jdk:`tar -zxvf jdk-8u144-linux-i586.tar.gz`
![hellojira_01](http://ou3np1yz4.bkt.clouddn.com/hellojira_01.png)
2. 在usr下创建一个目录,然后将解压的文件放进去:

 ```
   mkdir /usr/java
   mv  jdk1.8.0_102 /usr/java/
 ```
 
3. 配置环境变量,`vim /etc/profile`,然后在最后面加入下列代码:

```
 export JAVA_HOME=/usr/java/jdk1.8.0_102/
 export PATH=$JAVA_HOME/bin:$PATH
 export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
```

4.更新profile文件

```
 source /etc/profile
```
![hellojira_2](http://ou3np1yz4.bkt.clouddn.com/hellojira_2.png)
### 注意：
 如果是给公司安装的话,你可能会发现服务器上不止一个版本的jdk,而且*/etc/profile*下的环境变量也不是1.8的，这时候该怎么办呢？
你可以在jira的运行目录下找到程序启动的**.sh**文件,使用vim编辑器在此文件的最上方添加你要使用的jdk的环境变量,让其从这个路径下寻找jdk。

- 数据库mysql的搭建
我使用的是*centos7*,好多配置跟之前的不太一样。也踩了不少坑,这里就简单说一下我的安装过程吧。
首先我使用网上大多数人的答案:
```
 yum install mysql
 yum install mysql-server
 yum install mysql-devel
```
结果发现安装上的压根不是mysql,而是一个mariadb的鬼玩意。于是我去查资料发现centos7的默认数据库由mysql改为了mariadb。于是我又查了各种资料进行mysql的安装,简单说一下步骤:

**1.首先下载mysql的repo源**

```
 wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
```

**2.安装mysql-community-release-el7-5.noarch.rpm包**

```
 rpm -ivh mysql-community-release-el7-5.noarch.rpm
```
**3.安装mysql**

```
 yum install mysql-server
```

这样mysql就安装好了,不过这是centos7下的方法,如果大家用的别的环境就不适用了。
**4.mysql安装好后是没有密码的,我们需要登录mysql然后设置密码:**

```
 mysql -u root
 use mysql;
 update user set password=password(‘123456‘) where user=‘root‘;
```
**5.设置远程连接**

```
 use mysql;          #使用'mysql'这个数据库
 Grant all privileges on *.* to 'root'@'%' identified by '123456' with grant option;   #赋权限
 flush privileges;   #刷新权限
```
这时候我们使用这个账号就可以远程访问了,比如使用桌面的sqlyog进行连接。如果连接不上有可能是3306端口没有放开,下面说一下centos7下的开放端口的方法:

```
 firewall-cmd --state #查看运行状态
 firewall-cmd --add-port=3306/tcp --permanent #开放3306端口
 firewall-cmd --reload #生效刚才的端口设置
```
**6.创建一个jira使用的mysql账号**
回到正题,mysql已经安装好了。现在我们来为jira创建一个mysql用户

```
 CREATE USER 'jira'@'%' IDENTIFIED BY 'jira';
```
创建一个jira数据库

```
 create database jira default character set utf8 collate utf8_bin;
```

给jira用户赋权限

```
  GRANT all on jiradb.* to 'jira'@'%' identified by 'jira';
  flush privileges;
```
这时候我们可以使用`show grants for jira@localhost;`来查看一下权限。

# 二、破解安装jira
这时候我们就可以安装并破解jira了
**1.下载linux版本的jira**
首先去[官网](https://www.atlassian.com/software/jira/download)下载linux版本的jira
![hellojira_03](http://ou3np1yz4.bkt.clouddn.com/hellojira_03.png)
并且把破解包下载下来链接：http://pan.baidu.com/s/1bMfksQ 密码：lsc7
**2.开始安装jira**
将安装包放入linux随意一个目录下后,使用如下命令:

```
 chmod 755 atlassian-jira-software-7.4.2-x64.bin #修改权限

./atlassian-jira-software-7.4.2-x64.bin
```
安装过程有一些选项,如果选不对就会出现下图情景,我们可以看到jira安装的端口是8080,安装的路径是/opt/atlassian/jira和/var/atlassian/application-data/jira目录下:
![hellojira_04.png](http://ou3np1yz4.bkt.clouddn.com/hellojira_04.png)
因为8080端口比较常用,所以我们把他更换一下:`vim /opt/atlassian/jira/conf/server.xml`
![hellojira_4.png](http://ou3np1yz4.bkt.clouddn.com/hellojira_4.png)
这里我把红框中的端口改为了8090
**3.破解jira**
解压破解包,找到一下两个文件:

    atlassian-extras-3.1.2.jar    #jira破解文件
    mysql-connector-java-5.1.39-bin.jar   #mysql驱动

和两个文件复制到/opt/atlassian/jira/atlassian-jira/WEB-INF/lib/目录下。这时候需要注意,jira破解文件是需要替换里面的原文件,但由于他的版本比较旧,所以就需要大家先找到原本目录下的atlassian-extras-3.x.jar文件。将它删除,然后把我们的破解文件换成它的名字。
**4.启动jira**
进入/opt/atlassian/jira/bin目录下运行*start-jira.sh*
打开桌面上的浏览器,访问[http://localhost:8090](http://localhost:8090)。就可以看到启动画面,如果不能访问,尝试用上面的方法放开一下8090端口:
![hellojira_6](http://ou3np1yz4.bkt.clouddn.com/hellojira_6.png)
点击continue后开始选择配置数据库:
输入正确的数据库信息后可以先test一下,如果test成功的话,执行下一步会jira会自动的向数据库中创建表。
这里需要注意的就是Mode选项。private是只有管理员可以注册账号，public是用户可以自己注册。
![hellojira_10](http://ou3np1yz4.bkt.clouddn.com/hellojira_10.png)
下面的步骤需要获取license:
![hellojira_11](http://ou3np1yz4.bkt.clouddn.com/hellojira_11.png)
需要我们去官网注册一个账号来获取license:
![hellojira_13](http://ou3np1yz4.bkt.clouddn.com/hellojira_13.png)
确定后会自动跳转回来:
![hellojira_14](http://ou3np1yz4.bkt.clouddn.com/hellojira_14.png)
之后就简单多了:
![hellojira_14](http://ou3np1yz4.bkt.clouddn.com/hellojira_15.png)
点击*Next*
![hellojira_14](http://ou3np1yz4.bkt.clouddn.com/hellojira_16.png)
选择*Finish*,之后选择一些语言就好了:
![hellojira_14](http://ou3np1yz4.bkt.clouddn.com/hellojira_17.png)

jira到这里就算是安装完成了,看着步骤多其实没有什么难点。

# 参考资料

-  [烂泥：jira7.2安装、中文及破解](https://www.ilanni.com/?p=12119)
-  [Centos 6.7下 jira7.1.1+confluence5.96+mysql结合（破解）](http://10551335.blog.51cto.com/10541335/1749945)
-  [CentOS yum 安装、卸载MariaDB数据库](http://blog.csdn.net/dunhanson/article/details/52997803)
-  [centos7下使用yum安装mysql](http://www.cnblogs.com/julyme/p/5969626.html)
-  [【Linux】CentOS 7通过Firewall开放防火墙端口](http://blog.csdn.net/sodino/article/details/52356472)


>本文作者： catalinaLi
本文链接： http://catalinali.top/2017/installjira/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。