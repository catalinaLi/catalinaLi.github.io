---
title: 小白学SpringCloud(二)：服务间的调用
date: 2018-06-05 10:07:05
tags: SpringCloud 
categories: SpringCloud 
keywords: SpringCloud 
---
![feign&Rest_logo](http://ou3np1yz4.bkt.clouddn.com/feign&Rest_logo.png)
>SpringCloud服务间的调用有两种方式：RestTemplate和FeignClient。不管是什么方式，他都是通过REST接口调用服务的http接口，参数和结果默认都是通过jackson序列化和反序列化。

<!--more-->

## 一、Ribbon简介
在说这两种方式之前，我们先来简单的看一下Ribbon。

>Ribbon is a client side load balancer which gives you a lot of control over the behaviour of HTTP and TCP clients. Feign already uses Ribbon, so if you are using @FeignClient then this section also applies.

这是官网对Ribbon的简介，简单的说Ribbon是一个负载均衡客户端，SpringCloud的两种服务间调用方式背后都用了Ribbon。

## 二、使用RestTemplate进行服务调用
代码Demo接上篇[SpringCloud(一)：服务的注册与发现（Eureka）](http://catalinali.top/2018/startEureka/)
**1.**我们首先启动端口为8761的eureka工程，把SpringCloud的服务注册中心启动。

**2.**打开我们的Discovery工程。这时候Discovery工程相当于服务端，我们来为它写一个提供服务的方法：
``` java
@RestController
public class HelloController {

    @Value("${server.port}")
    private String port;

    @GetMapping("/hello")
    public String hello() {
        return "hello! 我是" + port;
    }
}
```
然后将配置文件中的端口改为8762和8763分别启动。
如果你使用的是IDEA的话，只需要去掉下图中红框框住的部分就可以将同一工程启动多个实例
![Rest_1](http://ou3np1yz4.bkt.clouddn.com/feign&Rest_1.png)
这时，我们就拥有了端口为8762和8763的两个Discovery集群，Eureka中可以看到
![feign&Rest_2](http://ou3np1yz4.bkt.clouddn.com/feign&Rest_2.png)
**3.**我们再新建一个Eureka-Discovery工程（可以参照上一篇文章），首先为他配置好Eureka-Client的配置。在配置文件中为它指定端口为8764：
``` yml
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/ #服务端地址
server:
  port: 8764 #客户端端口
spring:
  application:
    name: client #客户端名称
```
然后我们为它添加一个RestTemplate的配置Bean，可以参照如下代码
``` java
@Component
public class HelloConfig {
    @Bean
    @LoadBalanced
    RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
```
之后我们就可以在需要调用的地方用如下方式进行调用
``` java
@RestController
public class ClientController {

    @Autowired
    private RestTemplate restTemplate;

    @GetMapping("/cliHello")
    public String CliHello() {
        //第一个参数为：服务端的应用名称/调用接口的Mapping
        //第二个参数为返回的类型
        return restTemplate.getForObject("http://discovery/hello",String.class);
    }

}
```
结果如图：
![feign&Rest_3](http://ou3np1yz4.bkt.clouddn.com/feign&Rest_3.png)
这里因为Ribbon的默认负载均衡方式为轮询，所以我们可以看到端口8762和8763依次出现。如果有想改变负载均衡方式的小伙伴可以下去自行研究一下，这里就不过多赘述了。
## 三、使用Feign进行服务调用
**1.添加Feign的pom引用**
在FeignClient的pom文件中添加
``` pom
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
```
需要注意的是版本一定要跟我的一致，否则添加的依赖有可能会不一样
**2.为启动类添加注解**
这一步很简单，只需要在在启动类上添加`@EnableFeignClients`注解：
```
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
public class ClientApplication {

    public static void main(String[] args) {
        SpringApplication.run(ClientApplication.class, args);
    }
}
```
**3.定义一个Feign接口**
代码如下：
``` java
//name是服务端的名称
@FeignClient(name = "discovery")
public interface HelloClient {

    //url是调用服务的url值
    @GetMapping("/hello")
    String hello();
}
```
**4.调用**
在配置了Feign接口后，我们就可以直接进行注入调用了
``` java
    @Autowired
    private HelloClient helloClient;

    @GetMapping("/feignHello")
    public String feignHello() {
        return helloClient.hello();
    }
```
调用的结果跟RestTemplate也相同
![feign&Rest_3_1](http://ou3np1yz4.bkt.clouddn.com/feign&Rest_3.png)
从这里我们可以看到，使用Feign是伪分布式的调用方式。

---

>本文作者： catalinaLi
本文链接： http://catalinali.top/2018/startfeign&Rest/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。
