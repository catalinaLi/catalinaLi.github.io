---
title: 使用IDEA搭建第一个SpringBoot程序
date: 2018-01-27 17:25:26
tags: [SpringBoot,IDEA]
categories: SpringBoot
keywords: [SpringBoot,IDEA]
---
![startSpringBoot_logo](http://ou3np1yz4.bkt.clouddn.com/startSpringBoot_logo.jpg)
>近来在研究SpringBoot的使用，现在把使用IDEA搭建一个SpringBoot的HelloWorld程序记录下来

<!--more-->
## 新建一个SpringBoot环境
打开你的IntelliJ IDEA，然后选择Create New Project。如图，我们要选择一个Spring Initializr
![startSpringBoot_1](http://ou3np1yz4.bkt.clouddn.com/startSpringBoot_1.png)
之后我们填入自己的Group与Artifact(项目名字)后选择Next
![startSpringBoot_2](http://ou3np1yz4.bkt.clouddn.com/startSpringBoot_2.png)
由于我们是Web项目，所以我们先勾选最基本的Web选项，其他的待我们用到了再勾选。
![startSpringBoot_3](http://ou3np1yz4.bkt.clouddn.com/startSpringBoot_3.png)
接下来是选择项目存放的位置
![startSpringBoot_4](http://ou3np1yz4.bkt.clouddn.com/startSpringBoot_4.png)
选择Finish之后静静等待IEAD加载索引搭建工程。OK，一个完整的SpringBoot项目的结构我们已经搭建好了。
![startSpringBoot_5](http://ou3np1yz4.bkt.clouddn.com/startSpringBoot_5.png)
上图我用红框圈住的可以删掉，保持项目的简洁。这样，一个可供使用的SpringBoot环境就搭好了。
## SpringBoot介绍
使用SpringBoot可以让你快速搭建一个SpringWeb项目，它使用“习惯优于配置”的理念让你的项目快速运行起来。使用SpringBoot可以很容易创建一个独立运行（运行jar，内嵌Servlet容器）、准生产级别的基于Spring框架的项目。使用SpringBoot你可以不用或者是很少的配置。
使用SpringBoot的优点：

- 快速构建项;
- 对主流开发框架的无配罝集成；
- 项目可独立运行，无须外部依赖Servlet容器；
- 提供运行时的应用监控；
- 极大地提髙了开发、部署效率；
- 与云计算的天然集成。
## SpringBoot入门
我们来写一个SpringBoot的HelloWorld
打开项目自动生成的DemoApplication类，修改代码：
``` java
@Controller
@SpringBootApplication
@Configuration
public class DemoApplication {

	@RequestMapping("hello")
	@ResponseBody
	public String hello(){
		return "hello world！";
	}

	public static void main(String[] args) {
		SpringApplication.run(DemoApplication.class, args);
	}
}

```
然后右键选择Run
![startSpringBoot_7](http://ou3np1yz4.bkt.clouddn.com/startSpringBoot_7.png)
然后打开浏览器访问[http://localhost:8080/hello](http://localhost:8080/hello)就可以看到我们写的HelloWorld
![startSpringBoot_8](http://ou3np1yz4.bkt.clouddn.com/startSpringBoot_8.png)
**代码说明：**
1、@SpringBootApplication：Spring Boot项目的核心注解，主要目的是开启自动配置。；
2、@Configuration：这是一个配置Spring的配置类；
3、@Controller：标明这是一个SpringMVC的Controller控制器；
4、main方法：在main方法中启动一个应用，即：这个应用的入口；

这次只是记录了一下搭建SpringBoot的HelloWorld过程。具体的SpringBoot知识还需要大家去深入学习

---
>本文作者： catalinaLi
本文链接： http://catalinali.top/2017/startSpringBoot/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。