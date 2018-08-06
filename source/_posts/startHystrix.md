---
title: 小白学SpringCloud(六)：服务降级（Hystrix）
date: 2018-08-06 09:40:58
tags: SpringCloud
categories: SpringCloud
keywords: SpringCloud
---
![hystrix_logo](http://ou3np1yz4.bkt.clouddn.com/hystrix_logo.jpg)

> 在微服务架构中，我们将系统拆分为很多个服务，各个服务之间通过注册与订阅的方式相互依赖，由于各个服务都是在各自的进程中运行，就有可能由于网络原因或者服务自身的问题导致调用故障或延迟，随着服务的积压，可能会导致服务崩溃。为了解决这一系列的问题，断路器等一系列服务保护机制出现了。

<!--more-->

## 一、Hystrix简介

Netflix提供了一个叫Hystrix的类库，它实现了断路器模式。在微服务架构中，通常一个微服务会调用多个其他的微服务。一个相对低层级的服务失败可能造成上层应用的级联失败，服务访问量越大失败率越高。当断路打开的时候，这个调用就被终止了。打开的断路可以阻止级联失败。
![Hystrix_1](http://ou3np1yz4.bkt.clouddn.com/Hystrix_1.png)
较底层的服务如果出现故障，会导致连锁故障。当对特定的服务的调用的不可用达到一个阀值（Hystric 是5秒20次） 断路器将会被打开。
![Hystrix_2](http://ou3np1yz4.bkt.clouddn.com/Hystrix_2.png)

## 二、创建一个api-gateway工程
这里我们使用之前的Client项目进行演示。
**1.在服务调用方添加pom**
``` pom
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-hystrix</artifactId>
</dependency>
```

**2.添加@EnableCircuitBreaker注解**
这个注解只需要在springboot工程的启动application类上就好了
``` java
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
@EnableCircuitBreaker
//@SpringCloudApplication
public class ClientApplication {

    public static void main(String[] args) {
        SpringApplication.run(ClientApplication.class, args);
    }
}
```
这时我们发现我们的启动类上添加了很多的注解，所以Spring Cloud将这些注解封装了一下，提供了一个@SpringCloudApplication的注解：
```
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@SpringBootApplication
@EnableDiscoveryClient
@EnableCircuitBreaker
public @interface SpringCloudApplication {
}
```
**3.对要服务进行降级**
之前的例子里我们有一个*restHello*的接口,这个接口调用的Discovery的*hello*接口。
我们现在在他上面添加一个@HystrixCommand注解
``` java
    @HystrixCommand(fallbackMethod  = "helloFallback")
    @GetMapping("/restHello")
    public String CliHello() {
        return restTemplate.getForObject("http://discovery/hello",String.class);
    }
```
我们使用fallbackMethod属性指定一个fallback方法，在需要降级的时候调用这个方法
``` java
    private String helloFallback() {
        return "哎呀，服务器开小差了！请稍后再试。";
    }
```
这时候我们将服务端和客户端都启动进行访问
![Hystrix_3](http://ou3np1yz4.bkt.clouddn.com/Hystrix_3.png)
这时候我们将服务端Discover关掉然后再访问这个地址，他就会去访问降级的地址
![Hystrix_4](http://ou3np1yz4.bkt.clouddn.com/Hystrix_4.png)
这样我们就实现了服务降级。但是这样需要没一个接口都添加这个注解，有没有更快一点的方法呢？

**4.配置默认服务降级注解**
在类上添加@DefaultProperties注解配置默认的降级方法
``` java
@RestController
@RefreshScope
@DefaultProperties(defaultFallback = "helloFallback")
public class ClientController {
        //@HystrixCommand(fallbackMethod  = "helloFallback")
    @GetMapping("/restHello")
    public String CliHello() {
        return restTemplate.getForObject("http://discovery/hello",String.class);
    }

    private String helloFallback() {
        return "哎呀，服务器开小差了！请稍后再试。";
    }
}
```
这样我们再进行刚才的操作，可以发现是同样的效果^_^
![Hystrix_4](http://ou3np1yz4.bkt.clouddn.com/Hystrix_4.png)

---

>本文作者： catalinaLi
本文链接： http://catalinali.top/2018/startHystrix/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。


