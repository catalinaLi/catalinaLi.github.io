---
title: Dubbo初体验:远程服务调用和管控台的搭建
date: 2017-09-06 15:42:56
tags: Dubbo
categories: Dubbo
keywords: Dubbo
---

![hellodubbo_logo](http://ou3np1yz4.bkt.clouddn.com/hellodubbo_logo.jpg)
>Dubbo是一个阿里巴巴的分布式服务框架。虽然在很久以前阿里停止更新了,但是还是有很多公司在使用它。Dubbo致力于提供高性能和透明化的RPC远程服务调用方案以及SOA服务治理方案。通过他我们可以非常容易地通过Dubbo来构建分布式服务。哦，对了。好像最近阿里又开始更新了。

---
<!--more-->
## Dubbo的架构
![hellodubbo_1](http://ou3np1yz4.bkt.clouddn.com/hellodubbo_1.png)
**调用关系说明：**

- 服务容器负责启动，加载，运行服务提供者。
- 服务提供者在启动时，向注册中心注册自己提供的服务。 
- 服务消费者在启动时，向注册中心订阅自己所需的服务。
- 注册中心返回服务提供者地址列表给消费者，如果有变更，注册中心将基于长连接推送变更数据给消费者。
- 服务消费者，从提供者地址列表中，基于软负载均衡算法，选一台提供者进行调用，如果调用失败，再选另一台调用。
- 服务消费者和提供者，在内存中累计调用次数和调用时间，定时每分钟发送一次统计数据到监控中心。
<br>
这张图和这段话你可能已经见过无数次了,但是我还是把它从[官网](http://dubbo.io/)复制了过来。原因就是这张图能很简洁的说么Dubbo的调用关系。如果你还没有使用过Dubbo,那这张图可以很快帮你理顺调用关系。

## Hello Dubbo
我们在使用过程中一般是采用XML配置,原因就是简单方便。在使用之前我们需要搭建Dubbo的注册中心。官方推荐的注册中心是zookeeper。如果你还没有搭建好zookeeper,那么可以看看我之前写的[小白从头到脚搭建zookeeper集群的过程](http://catalinali.top/2017/buildzookeeper/)。
**1.Dubbo依赖**
如果你使用的是Maven项目,在使用Dubbo的地方加入下面的依赖即可:
```xml
<dependency>
	<groupId>com.alibaba</groupId>
	<artifactId>dubbo</artifactId>
	<exclusions>
		<exclusion>
			<groupId>org.springframework</groupId>
			<artifactId>spring</artifactId>
		</exclusion>
		<exclusion>
			<groupId>org.jboss.netty</groupId>
			<artifactId>netty</artifactId>
		</exclusion>
	</exclusions>
</dependency>
<dependency>
	<groupId>org.apache.zookeeper</groupId>
	<artifactId>zookeeper</artifactId>
</dependency>
<dependency>
	<groupId>com.github.sgroschupf</groupId>
	<artifactId>zkclient</artifactId>
</dependency>
```
**2.生产者**
首先展示生产者的接口,很简单的两个方法。
```java
public interface SampleService {

	String sayHello(String name);
	
}
```
生产者的实现类:
```java
public class SampleServiceImpl implements SampleService {
	
	public String sayHello(String name) {
		return "Hello " + name;
	}

}
```
User类的话就是name、age、sex三个属性。<br>
接下来就是生产者的Spring配置:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
	xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://code.alibabatech.com/schema/dubbo
        http://code.alibabatech.com/schema/dubbo/dubbo.xsd
        ">

	<!-- 具体的实现bean -->
	<bean id="sampleService" class="top.catalinali.sample.provider.impl.SampleServiceImpl" />

	<!-- 提供方应用信息，用于计算依赖关系 -->
	<dubbo:application name="sample-provider" />

	<!-- 使用zookeeper注册中心暴露服务地址 -->
	<dubbo:registry address="zookeeper://192.168.71.121:2181?backup=192.168.71.122:2181,192.168.71.123:2181" />

	<!-- 用dubbo协议在20880端口暴露服务 -->
	<dubbo:protocol name="dubbo" port="20880" />

	<!-- 声明需要暴露的服务接口  写操作可以设置retries=0 避免重复调用SOA服务 -->
	<dubbo:service retries="0" interface="top.catalinali.sample.provider.SampleService" ref="sampleService" />

</beans>
```
**3.消费者**
首先消费者需要一个跟生产一模一样的接口类
```java
public interface SampleService {

	String sayHello(String name);

}
```
消费者配置
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
	xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://code.alibabatech.com/schema/dubbo
        http://code.alibabatech.com/schema/dubbo/dubbo.xsd
        ">

	<!-- 消费方应用名，用于计算依赖关系，不是匹配条件，不要与提供方一样 -->
	<dubbo:application name="sample-consumer" />

	<dubbo:registry address="zookeeper://192.168.71.121:2181?backup=192.168.71.122:2181,192.168.71.123:2181" />

	<!-- 生成远程服务代理，可以像使用本地bean一样使用demoService 检查级联依赖关系 默认为true 当有依赖服务的时候，需要根据需求进行设置 -->
	<dubbo:reference id="sampleService" check="false"
		interface="top.catalinali.sample.provider.SampleService" />

</beans>
```
## Dubbo启动
首先我们先启动生产者启动:
```java
public class Provider {

	public static void main(String[] args) throws Exception {
		ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext(
				new String[] { "sample-provider.xml" });
		context.start(); 
		System.in.read(); // 为保证服务一直开着，利用输入流的阻塞来模拟
	}
}
```
启动消费者
```java
public class Consumer {

	public static void main(String[] args) throws Exception {
		ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext(
				new String[] { "sample-consumer.xml" });
		context.start();
			
		SampleService sampleService = (SampleService) context.getBean("sampleService");
		String hello = sampleService.sayHello("tom");
		System.out.println(hello);
		
		System.in.read();
	}

}
```
结果
![hellodubbo_2](http://ou3np1yz4.bkt.clouddn.com/hellodubbo_2.png)
项目结构图
![hellodubbo_3](http://ou3np1yz4.bkt.clouddn.com/hellodubbo_4.png)

## Dubbo的管控台
Dubbo管控台搭建其实很容易,我们只需要一个在linux上的tomcat跑Dubbo即可,需要的环境:

- apache-tomcat-7.0.29.tar.gz
- dubbo-admin-2.5.4.war

**1.安装tomcat**
使用`tar -zxvf apache-tomcat-7.0.29.tar.gz`解压tar包
**2.解压dubbo的war包**
使用`unzip dubbo-admin-2.5.3.war -d dubbo-admin`解压dubbo-admin-2.5.4.war到tomcat目录下的webapps下。如果提示无unzip命令,使用yum安装`yum install -y unzip zip`此命令
*注意：*
如果zookeeper注册中心不在此服务器上,则需要打开dubbo-admin/WEB-INF/dubbo.properties文件,将红框改注册中心的ip地址。
![hellodubbo_5](http://ou3np1yz4.bkt.clouddn.com/hellodubbo_5.png)
**3.运行tomcat**
①进入tomcat下的bin目录下,执行`./startup.sh`脚本。
②使用`tail -f ../logs/catalina.out`查看日志。
![hellodubbo_6](http://ou3np1yz4.bkt.clouddn.com/hellodubbo_6.png)
③进入*http://192.168.71.121:8080/dubbo-admin/*就可以看到管控台了(IP地址改成你的服务器ip)
![hellodubbo_7](http://ou3np1yz4.bkt.clouddn.com/hellodubbo_7.png)
也可以看到我们刚才所运行的服务
![hellodubbo_8](http://ou3np1yz4.bkt.clouddn.com/hellodubbo_8.png)

---
>本文作者： catalinaLi
本文链接： http://catalinali.top/2017/helloDubbo/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。