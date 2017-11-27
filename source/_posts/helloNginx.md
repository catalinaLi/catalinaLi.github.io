---
title: Nginx初探究：安装与简单使用
date: 2017-10-31 16:30:13
tags: nginx
categories: nginx
keywords: nginx
---
![nginx_logo](http://ou3np1yz4.bkt.clouddn.com/nginx_logo1.jpg)
>在学习淘淘商城的过程中接触到了nginx,今天就把使用它的过程记录下来,作为留存。

---

<!--more-->

## 一、什么是Nginx
Nginx是一款高性能的http服务器/反向代理服务器及电子邮件（IMAP/POP3）代理服务器。由俄罗斯的程序设计师Igor Sysoev所开发，官方测试nginx能够支支撑5万并发链接，并且cpu、内存等资源消耗却非常低，运行非常稳定。
### 应用场景
- http服务器。Nginx是一个http服务可以独立提供http服务。可以做网页静态服务器。
- 虚拟主机。可以实现在一台服务器虚拟出多个网站。例如个人网站使用的虚拟主机。
- 反向代理，负载均衡。当网站的访问量达到一定程度后，单台服务器不能满足用户的请求时，需要用多台服务器集群可以使用nginx做反向代理。并且多台服务器可以平均分担负载，不会因为某台服务器负载高宕机而某台服务器闲置的情况。

## 二、nginx安装
### 1.[官网](http://nginx.org/)下载nginx源码。
### 2.外部环境准备:

- 需要安装gcc的环境:`yum install gcc-c++`
- 第三方的开发包:
① PCRE(Perl Compatible Regular Expressions)是一个Perl库，包括 perl 兼容的正则表达式库。nginx的http模块使用pcre来解析正则表达式，所以需要在linux上安装pcre库。
```
yum install -y pcre pcre-devel
```
②zlib库提供了很多种压缩和解压缩的方式，nginx使用zlib对http包的内容进行gzip，所以需要在linux上安装zlib库。
```
yum install -y zlib zlib-devel
```
③OpenSSL 是一个强大的安全套接字层密码库，囊括主要的密码算法、常用的密钥和证书封装管理功能及SSL协议，并提供丰富的应用程序供测试或其它目的使用。nginx不仅支持http协议，还支持https（即在ssl协议上传输http）
```
yum install -y openssl openssl-devel
```

### 3.正式安装
第一步：把nginx的源码包上传到linux系统
第二步：解压缩
```linux
tar zxf nginx-1.8.0.tar.gz 
```
第三步：使用configure命令创建一makeFile文件。
./configure \
--prefix=/usr/local/nginx \
--pid-path=/var/run/nginx/nginx.pid \
--lock-path=/var/lock/nginx.lock \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--with-http_gzip_static_module \
--http-client-body-temp-path=/var/temp/nginx/client \
--http-proxy-temp-path=/var/temp/nginx/proxy \
--http-fastcgi-temp-path=/var/temp/nginx/fastcgi \
--http-uwsgi-temp-path=/var/temp/nginx/uwsgi \
--http-scgi-temp-path=/var/temp/nginx/scgi
注意：以上都是一些安装时配置nginx的一些参数,具体含义可以自行百度。另外在启动nginx之前，上边将临时文件目录指定为/var/temp/nginx，需要在/var下创建temp及nginx目录
```
mkdir /var/temp/nginx/client -p
```
第四步：编译,运行`make`命令
第五步：安装运行`make install`命令
第六步：测试
进入安装目录下的**sbin**文件,运行`./nginx`后，打开浏览器访问主机ip。
注意：①默认是80端口。②是否关闭防火墙。
![nginx_1](http://ou3np1yz4.bkt.clouddn.com/nginx_1.png)
如果出现上图，恭喜你，nginx安装成功。
相关命令:
```linux
./nginx -s stop ##关闭nginx
./nginx -s quit ##关闭nginx(推荐使用)
./nginx -s reload ##重启nginx
```
## 三、配置虚拟主机
### 1.通过端口号区分虚拟主机
打开nginx的配置文件
```
vim /usr/local/nginx/conf/nginx.conf
```
可以看到一个server节点,这个就是我们配置虚拟主机的关键,每一个此节点代表一台主机。
```
    server {
        listen       80;    ##端口号
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;    ##nginx安装目录下的html目录
            index  index.html index.htm; ##每台主机对应的页面
        }
    }
```
当我们配置了多个server，就相当于配置了多个虚拟主机。这时我们就可以通过不同的端口号来进行访问。
### 2.通过域名区分虚拟主机
首先我们要知道当我们打开浏览器访问每一个域名的时候，每一个域名对应的是一个ip地址。并且一个ip地址可以被多个域名绑定。当我们在本地hosts文件（C:\Windows\System32\drivers\etc）中配置了域名与ip的对应的映射关系时，浏览器就不会再去走DNS服务器
为了方便测试，我们先在本地hosts文件配置一下测试所用数据
```
192.168.71.121 www.taobao.com
192.168.21.121 www.baidu.com
```

然后配置两个server节点

```
    server {
        listen       80;
        server_name  www.taobao.com; ##不同域名配置

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   html-taobao; ##不同域名访问的不同文件夹
            index  index.html index.htm;
        }
    }
    server {
        listen       80;
        server_name  www.baidu.com; ##不同域名配置

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   html-baidu; ##不同域名访问的不同文件夹
            index  index.html index.htm;
        }
    }
```
然后在浏览器上访问这两个地址就可以访问到我们配置的两台虚拟主机。
## 四、反向代理
### 1.什么是反向代理
两个域名指向同一台nginx服务器，用户访问不同的域名显示不同的网页内容。
两个域名是www.sian.com.cn和www.sohu.com
nginx服务器使用虚拟机192.168.101.3
### 2.实现反向代理
第一步：安装两个tomcat，分别运行在8080和8081端口。
第二步：启动两个tomcat。
第三步：反向代理服务器的配置
```
upstream tomcat1 {
	server 192.168.25.148:8080;
    }
    server {
        listen       80;
        server_name  www.sina.com.cn;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            proxy_pass   http://tomcat1;
            index  index.html index.htm;
        }
    }
    upstream tomcat2 {
	server 192.168.25.148:8081;
    }
    server {
        listen       80;
        server_name  www.sohu.com;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            proxy_pass   http://tomcat2;
            index  index.html index.htm;
        }
    }
```
第四步：nginx重新加载配置文件
第五步：配置域名
在hosts文件中添加域名和ip的映射关系
```
192.168.71.121 www.sina.com.cn
192.168.71.121 www.sohu.com
```
## 五、负载均衡
如果一个服务由多条服务器提供，需要把负载分配到不同的服务器处理，需要负载均衡。
```
 upstream tomcat2 {
	server 192.168.71.121:8081;
	server 192.168.71.121:8082;
  }
```
可以根据服务器的实际情况调整服务器权重。权重越高分配的请求越多，权重越低，请求越少。默认是都是1
```
 upstream tomcat2 {
	server 192.168.71.121:8081;
	server 192.168.71.121:8082 weight=2;
    }
```
---
>本文作者： catalinaLi
本文链接： http://catalinali.top/2017/helloNginx/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。