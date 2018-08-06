---
title: 小白学SpringCloud(五)：路由网关（Zuul）
date: 2018-07-10 18:15:28
tags: SpringCloud
categories: SpringCloud
keywords: SpringCloud
---

![zuul_logo](http://ou3np1yz4.bkt.clouddn.com/zuul_logo.png)
> 在微服务的架构下，各个服务一般会有各自的网络地址，在这样的情况下外部客户端的调用可能会形成杂乱无章的局面。这时候我们就可以使用微服务网关Zuul这个组件，我们让所有的客户端请求全部请求Zuul，再由Zuul统一的去请求各个服务。

<!--more-->

## 一、Zuul简介

Zuul是Netflix开源的微服务网关，他可以和Eureka,Ribbon,Hystrix等组件配合使用。Zuul组件的核心是一系列的过滤器，这些过滤器可以完成以下功能：

- 身份认证和安全: 识别每一个资源的验证要求，并拒绝那些不符的请求
- 审查与监控：
- 动态路由：动态将请求路由到不同后端集群
- 压力测试：逐渐增加指向集群的流量，以了解性能
- 负载分配：为每一种负载类型分配对应容量，并弃用超出限定值的请求
- 静态响应处理：边缘位置进行响应，避免转发到内部集群
- 多区域弹性：跨域AWS Region进行请求路由，旨在实现ELB(ElasticLoad Balancing)使用多样化

Spring Cloud对Zuul进行了整合和增强。目前，Zuul使用的默认是Apache的HTTP Client，也可以使用Rest Client，可以设置ribbon.restclient.enabled=true.。

## 二、创建一个api-gateway工程
这里我们使用IntelliJ IDEA进行展示。
**1.首先创建一个Zuul项目**
使用IDEA创建一个项目
![eureka_2](http://ou3np1yz4.bkt.clouddn.com/eureka_2.jpg)
中间有一步我们选择Zuul选项和SpringBoot版本，如图
![eureka_2](http://ou3np1yz4.bkt.clouddn.com/zuul_1.png)
然后下一步就可以创建好了
**2.添加@EnableZuulProxy注解**
这个注解只需要在springboot工程的启动application类上就好了
``` java
@SpringBootApplication
@EnableZuulProxy
@EnableDiscoveryClient
public class ApiGetwayApplication {
    public static void main(String[] args) {
        SpringApplication.run(ApiGetwayApplication.class, args);
    }
```
然后在配置文件中添加config的配置，具体可以见[小白学SpringCloud(三)：统一配置中心(config)](http://catalinali.top/2018/startconfig/)。然后就可以使用Zuul工程的路由了，依次运行Eureka、Config、Client客户端、Zuul。
我们先来随便访问一下client端的env接口
![zuul_2](http://ou3np1yz4.bkt.clouddn.com/zuul_2.png)
然后我们通过*zuul服务的端口+项目名/接口名*这种方式来访问一下这个接口
![zuul_3](http://ou3np1yz4.bkt.clouddn.com/zuul_3.png)
可以看到,同样访问到了结果。
另外，我们也可以在配置文件中更加细粒度控制路由路径：
``` yml
# 表示只要HTTP请求是 /client1开始的，就会转发到服务id为client1的服务上面
zuul:
  routes:
    client1:
      path:/client1/**  // 路由路径
      serviceId: client1 // 服务id
    client2:
      path:/client2/**  // 路由路径
      serviceId: client2 // 服务id
```
需要注意的是，使用Zuul默认不会将Cookie的信息带入服务端，所以我们需要在配置文件中进行配置,将敏感头设置为空即可：
``` yml
zuul:
  sensitiveHeaders:  
```
## 二、服务过滤
zuul不仅只是路由，并且还能过滤，做一些安全验证。我们来新建一个Filter并且继承ZuulFilter
``` java
import static org.springframework.cloud.netflix.zuul.filters.support.FilterConstants.PRE_DECORATION_FILTER_ORDER;
import static org.springframework.cloud.netflix.zuul.filters.support.FilterConstants.PRE_TYPE;

/**
 * @Author: lllx
 * @Description:
 * @Date: Created on 17:54 2018/7/10
 * @Modefied by:
 */
public class MyFilter extends ZuulFilter {
    
    /*返回一个字符串代表过滤器的类型
    pre：路由之前
    routing：路由之时
    post： 路由之后
    error：发送错误调用
    我们可以通过导入FilterConstants这个常量类中的属性来返回
    */
    @Override
    public String filterType() {
        return PRE_TYPE;
    }

    //过滤的顺序，Zuul中也自定义了很多过滤器，调用的顺序即通过这个方法返回的大小，越小越靠前。我们可以通过FilterConstants这个常量类中定义好的过滤器-1来返回
    @Override
    public int filterOrder() {
        return PRE_DECORATION_FILTER_ORDER -1;
    }

    //这里可以写逻辑判断，是否要过滤，本文true,永远过滤。
    @Override
    public boolean shouldFilter() {
        return true;
    }

    //过滤器的具体逻辑。可用很复杂，包括查sql，nosql去判断该请求到底有没有权限访问。
    @Override
    public Object run() throws ZuulException {
        RequestContext requestContext = RequestContext.getCurrentContext();
        HttpServletRequest request = requestContext.getRequest();

        //从url参数获取如果没有token这个参数就不允许请求
        String token = request.getParameter("token");
        if(StringUtils.isEmpty(token)){
            requestContext.setSendZuulResponse(false);
            requestContext.setResponseStatusCode(HttpStatus.UNAUTHORIZED.value());
        }
        return null;
    }
}
```
我们可以通过这样的方式去自定义一个个的过滤器。

---

>本文作者： catalinaLi
本文链接： http://catalinali.top/2018/startZuul/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。


