---
title: 小白学SpringCloud(一)：服务的注册与发现（Eureka）
date: 2018-05-31 18:19:58
tags: SpringCloud
categories: SpringCloud
keywords: SpringCloud
---

![eureka_logo](http://ou3np1yz4.bkt.clouddn.com/eureka_logo1.jpg)

<!--more-->

## 一、引言
首先我们先引用Dubbo官网的一段话

- 单一应用架构
    当网站流量很小时，只需一个应用，将所有功能都部署在一起，以减少部署节点和成本。
    此时，用于简化增删改查工作量的 数据访问框架(ORM) 是关键。
- 垂直应用架构
    当访问量逐渐增大，单一应用增加机器带来的加速度越来越小，将应用拆成互不相干的几个应用，以提升效率。
    此时，用于加速前端页面开发的 Web框架(MVC) 是关键。
- 分布式服务架构
    当垂直应用越来越多，应用之间交互不可避免，将核心业务抽取出来，作为独立的服务，逐渐形成稳定的服务中 心，使前端应用能更快速的响应多变的市场需求。此时，用于提高业务复用及整合的分布式服务框架(RPC)是关键。
- 流动计算架构
当服务越来越多，容量的评估，小服务资源的浪费等问题逐渐显现，此时需增加一个调度中心基于访问压力实时管理集群容量，提高集群利用率。此时，用于提高机器利用率的资源调度和治理中心(SOA) 是关键。

结合现在大火的微服务，SpringCloud成了炙手可热的微服务架构方案，这里我们介绍一个他的核心组件：Eureka ,eureka是一个服务注册和发现模块。类似于Dubbo的管控台。它分为两个模块:客户端和服务端

## 二、创建一个Eureka Server
这里我们使用IntelliJ IDEA进行展示。这里SpringBoot我们统一使用2.0.2版本,SpringCloud使用Finchley.RELEASE版本
**1.首先创建一个Eureka Server**
使用IDEA创建一个项目
![eureka_2](http://ou3np1yz4.bkt.clouddn.com/eureka_2.jpg)
中间有一步我们选择Eureka Server选项和SpringBoot版本，如图
![eureka_2](http://ou3np1yz4.bkt.clouddn.com/eureka_3.jpg)
然后下一步就可以创建好了
**2.添加@EnableEurekaServer注解**
这个注解只需要在springboot工程的启动application类上就好了
``` java
@SpringBootApplication
@EnableEurekaServer
public class EurekaApplication {

    public static void main(String[] args) {
        SpringApplication.run(EurekaApplication.class, args);
    }
}
```
这时候我们就可以启动了，运行EurekaApplication，然后就输入[http://localhost:8080/](http://localhost:8080/)就可以看到我们Eureka的页面了。但这时候我们观察console可以发现一直在报错，这是因为默认情况下Eureka Server也是一个Client,我们需要通过配置来解决这个问题
**3.添加配置**
eureka是一个高可用的组件，它没有后端缓存，每一个实例注册之后需要向注册中心发送心跳（因此可以在内存中完成），在默认情况下erureka server也是一个eureka client ,必须要指定一个server。eureka server的配置文件appication.yml
``` yml
spring:
  application:
    name: eureka #应用的名称
server:
  port: 8761
eureka:
  instance:
    hostname: localhost
  client:
    service-url:
      defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/
    # 通过添加配置我们这里忽略自己
    register-with-eureka: false #表示是否注册自身到eureka服务器
    fetch-registry: false #表示是否从eureka服务器获取注册信息
```
这时候再启动应用，就大功告成了
![eureka_4](http://ou3np1yz4.bkt.clouddn.com/eureka_4.jpg)
## 三、创建一个Eureka Client
**1.运行Eureka Server**
这里我们可以使用命令行在Eureka Server的目录位置使用`mvn clean package`来进行打包
然后使用`java -jar target/eureka-0.0.1-SNAPSHOT.jar`命令来进行启动jar包
也可以使用`nohup java -jar target/eureka-0.0.1-SNAPSHOT.jar &`来后台启动这个jar。
最后刷新Eureka Server来判断是否启动成功
**2.创建一个Eureka Client**
这一步跟创建Server端的步骤是一样的，不同的是模板选择Discovery
![eureka_5](http://ou3np1yz4.bkt.clouddn.com/eureka_5.jpg)
**3.添加@EnableEurekaServer注解和服务端地址**
基本和服务端的做法一样，首先我们在DicoveryApplication.java的代码上添加@EnableDiscoveryClient注解。然后在application.yml上添加配置：
``` java
@SpringBootApplication
@EnableDiscoveryClient
public class DicoveryApplication {

    public static void main(String[] args) {
        SpringApplication.run(DicoveryApplication.class, args);
    }
}
```
``` yml
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/ #服务端地址
server:
  port: 8762 #客户端端口
spring:
  application:
    name: client #客户端名称
```
注意了，这个版本我们需要在pom文件中添加`spring-boot-starter-web`的依赖，
这时候我们就可以启动我们的服务了，然后就可以在eureka的页面上看到我们刚才的Client了
![eureka_6](http://ou3np1yz4.bkt.clouddn.com/eureka_6.jpg)
## 三、Eureka Server的高可用
简单的说，实现Eureka Server的高可用就是让Eureka Server的实例互相注册。
让我们来看一下如何实现：
首先我们配置文件中这样写
``` yml
spring:
  application:
    name: discovery-cluster
---
spring:
  profiles: discovery1
server:
  port: 8761
eureka:
  instance:
    hostname: discovery1
  client:
    service-url:
      default-zone: http://discovery2:8762/eureka

---
spring:
  profiles: discovery2
server:
  port: 8762
eureka:
  instance:
    hostname: discovery2
  client:
    service-url:
      default-zone: http://discovery1:8761/eureka
```
配置文件是通过两个Eureka Server互相注册，这里有三段配置，第一段配置为公共配置，配置了应用名称，第二段为名discovery1的配置，第三段为discovery2的配置。在项目启动可以通过--spring.profiles.active={配置名称} 来启动不同的配置。
下面我们来进行测试：
1）在discovery-cluster目录下，使用`mvn clean package`打包项目 
2）使用下面命令启动两个Eureka Server节点 
`java -jar discovery-cluster-0.0.1-SNAPSHOT.jar --spring.profiles.active=discovery1`

`java -jar discovery-cluster-0.0.1-SNAPSHOT.jar --spring.profiles.active=discovery2` 
3）在浏览器上分别输入http://localhost:8761和http://localhost:8762查看注册的服务。
这时候我们可以发现两个网址都可以访问Eueka页面
![eureka_7](http://ou3np1yz4.bkt.clouddn.com/eureka_7.jpg)
这样我们就大功告成了，如我们我们的实例有3个，那就在配置文件中都写入
``` yml
eureka:
   client:
      service-url:
          default-zone:http://discovery1:8761/eureka,http://discovery2:8762/eureka
```
以上，就是Eureka的基本用法了！

---

>本文作者： catalinaLi
本文链接： http://catalinali.top/2018/startfeign&Rest/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。