---
title: 小白学SpringCloud(三)：统一配置中心(config)
date: 2018-06-15 15:45:19
tags: SpringCloud
categories: SpringCloud
keywords: SpringCloud
---

![config_logo](http://ou3np1yz4.bkt.clouddn.com/config_logo.png)
>在分布式系统中，每一个功能模块都能拆分成一个独立的服务，一次请求的完成，可能会调用很多个服务协调来完成。如果我们每个服务都有一个独立的配置的话，这样很不方便我们维护。Spring Cloud中为我们提供了一个config组件为我们解决了这个问题，并且更改了配置并不需要我们重启。

<!--more-->

## 一、Config概述

同Eureka一样，config也分为server端和client端，我们先来看看server端的原理。这里引用一张廖师兄的图（注：图中的order、product都是客户端）
![config_1](http://ou3np1yz4.bkt.clouddn.com/config_1.png)
从这张图我们可以看出，Config Server是以远端Git作为依托（SVN也可以,这里使用Github作为演示），从远端Git仓库中拉取配置并同步到本地Git上。当客户端需要配置的时候就可以从Server端进行配置的拉取。

## 二、Config Server配置
**1.**创建Config工程
跟前文一样，我们使用IDEA的Spring Initializr创建我们的Config工程，如图:除了图中圈起来的config Server要勾上，Eureka Discover也要勾上。
![config_2](http://ou3np1yz4.bkt.clouddn.com/config_2.png)

**2.**创建远程仓库
首先我们先创建一个远程Git仓库，这里以Github为例，这里我已经创建好了一个公开仓库[https://github.com/catalinaLi/config_repo](https://github.com/catalinaLi/config_repo)
然后在里面先添加一份配置
![config_3](http://ou3np1yz4.bkt.clouddn.com/config_6.png)
**3.**配置Config工程
将我们的Config工程注册到Eureka注册中心：
``` yml
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/ #服务端地址
server:
  port: 8764 #客户端端口
spring:
  application:
    name: config
  cloud:
    config:
      server:
        git:
          uri: https://github.com/catalinaLi/config_repo #config_Server仓库地址
          #如果我们配置的是私有仓库，则还需要远程仓库的账号和密码
          #username: yourusername  
          #password: yourpassword
env:
  dev   
```
然后在启动类上添加注解
``` java
@SpringBootApplication
@EnableDiscoveryClient
@EnableConfigServer 
public class ConfigApplication {

    public static void main(String[] args) {
        SpringApplication.run(ConfigApplication.class, args);
    }
}
```
**4.** Config Server配置
接下来就可以通过网络来访问我们的配置了，首先启动注册中心Eureka，然后启动我们的Config。这时候我们通过浏览器访问[http://localhost:8764/client-dev.yml](http://localhost:8764/client-dev.yml)就可以看到我们的配置了。
![config_5](http://ou3np1yz4.bkt.clouddn.com/config_5.png)
这里是Spring Cloud对配置请求的路径做了映射,通常为：

- /{name}-{profiles}.yml
- /{label}/{name}-{profiles}.yml

这两种方式大家可以挑选一个适合你的。
后缀名也可以不是yml，你可以试试properties，json。Spring Cloud会自动帮你转换。
## 三、Config Client配置
这里我们使用上一篇文章[小白SpringCloud(二)：服务间的调用](http://catalinali.top/2018/startfeignRest/)中的Client项目来进行改造
**1.添加pom引用**
在FeignClient的pom文件中添加Config Client引用
``` pom
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-config-client</artifactId>
        </dependency>
```
**2.修改配置文件**
首先我们要把配置文件的名字改为**bootstrap.yml**，改成这个名字Spring Cloud就会先去Config Server拉取配置。
然后我们要在bootstrap.yml中定义我们要拉取的文件名称，还记得刚才说的Spring Cloud对请求的路径做的映射方式吗(/{name}-{profiles}.yml)？在这里我们配置*name*、*profiles*和*Config项目的名称*

``` yml
spring:
  application:
    name: client #name
  cloud:
    config:
      discovery:
        enabled: true
        service-id: config #Eureka Config's name
      profile: dev #profiles
```
这时候，我们的Client就可以正常启动啦，怎么样简单吧。
## 二、Config Server的高可用

统一配置中心的高可用很简单，只需要我们多启动几个相同的实例就好了。Config Client在启动的时候会根据负载均衡去访问Config Server中的某一台.

还记得导语中说的更改配置可以不用重新启动项目吗？这里需要用到另外一个组件，我们在下篇文章进行讲解。

---

>本文作者： catalinaLi
本文链接： http://catalinali.top/2018/startconfig/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。


