---
title: 小白学SpringCloud(四)：消息总线（Spring Cloud Bus）
date: 2018-07-02 14:33:08
tags: SpringCloud
categories: SpringCloud
keywords: SpringCloud
---

![bus_logo](http://ou3np1yz4.bkt.clouddn.com/bus_logo.jpg)
> Spring Cloud Bus 将分布式的节点用轻量的消息代理连接起来。它可以用于广播配置文件的更改或者服务之间的通讯，也可以用于监控。上篇我们有说到Spring Cloud为我们提供了在不重启项目的情况下切换配置的功能，就要用到它，让我们来看看怎么实现的吧。

<!--more-->

## 一、安装MQ

Spring Cloud Bus支持常见的Rabbitmq、kafka、Activemq等。我们这里使用Rabbitmq来作为演示。Rabbitmq的安装这里就不作演示了，大家可以使用docker来安装使用，很方便。给大家一个度娘的[传送门](https://www.baidu.com/s?wd=docker%E5%AE%89%E8%A3%85activemq&rsv_spt=1&rsv_iqid=0xf5578fe4000354b9&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&rqlang=cn&tn=baiduhome_pg&rsv_enter=0&oq=docker%2520%25E5%25AE%2589%25E8%25A3%2585activemq&inputT=1021&rsv_t=11e21%2FaLzaFQGzuvMvLtKuHmxzuLUWS0TB6d8t9pETvwOEs%2B0fjRN9KsfhoNwJv1cAky&rsv_pq=ef4e2567000322af&sug=activemq&rsv_sug3=21&rsv_sug1=17&rsv_sug7=100&rsv_sug2=0&rsv_sug4=1751)。

## 二、Config Server配置
这里我们还是以廖师兄的图为例，先来看看自动更新配置的原理(图中product、order均为客户端)。
![bus_1](http://ou3np1yz4.bkt.clouddn.com/bus_1.png)
当我们在远端Git修改了配置之后，如果我们访问Config Server的`/bus-refresh`接口，Config Server就会把更改的配置发送给MQ，之后MQ就会把要改变的配置推送给各个客户端，这样就实现了自动更换配置的功能，现在我们来试一试吧。记住在这之前要先启动Rabbitmq。
**1.**添加pom引用
老规矩，先来添加pom引用，要注意的是Config的Server和Client端都要添加。
``` pom
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-bus-amqp</artifactId>
</dependency>
```
**2.**修改配置文件
首先我们要先添加rabbitmq的配置，我们可以直接配置在远程git上面，这样服务端和客户端就都有这份配置了。
``` yml
spring:
  rabbitmq:
    username: guest
    password: guest
    host: 192.168.xxx.xxx
    port: 5672
```
然后我们也要显示的使我们的服务暴漏`/bus-refresh`接口。在Spring2.0中把这个接口都移动到了*actuator*下面。这个只需要在Config端进行配置就好了。
``` yml
management:
  endpoints:
    web:
      exposure:
        include: bus-refresh #也可以改为"*"来暴露所有接口
```
现在我们逐一启动我们的Eureka、Config和Client项目，同时在启动Config Server的时候可以看到我们对外暴露的接口
![bus_2](http://ou3np1yz4.bkt.clouddn.com/bus_2.png)
这样我们就完成配置了，现在我们修改一下远端配置中的`env`的值，然后访问一下这个接口
```
curl -X POST http://localhost:8764/actuator/bus-refresh
```
这时候我们发现在不重启项目的情况下，我们的配置已经修改了。
**3.**配置Webhook
刚才我们已经实现了自动替换项目配置，但是我们每次更改配置都要手动访问`/bus-refresh`接口，有没有简单的方式呢?答案当然是有的。现在大部分远端Git都提供了webhook功能，即我们每更改一次配置，就自动向某一接口发送一次请求。这不就是我们想要的吗？

---

>本文作者： catalinaLi
本文链接： http://catalinali.top/2018/startbus/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。