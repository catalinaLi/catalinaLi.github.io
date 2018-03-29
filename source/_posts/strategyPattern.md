---
title: Java设计模式之策略模式
date: 2017-12-18 14:55:26
tags: design-patterns
categories: design-patterns
keywords: strategyPattern
---
![strategy_logo](http://ou3np1yz4.bkt.clouddn.com/strategy_logo.jpg)
>在开发中我们会使用很多中间件，开发过程当然是单机配置，可是上生产环境的时候如何快速切换到集群配置，总不能修改代码吧，这里我们就可以结合Spring来使用策略模式。

---

<!--more-->
## 一、什么是策略模式？
在开发中常常遇到这种情况，实现某一个功能有多方式，我们可以根据不同的条件选择不同的方式来完成该功能。最常用的方法是将这些算法方式写到一个类中，在该类中提供多个方法，每一个方法对应一个具体的算法；或者通过if…else…或者case等条件判断语句来进行选择。
    然而该类代码将较复杂，维护较为困难。如果我们把一个类中经常改变或者将来可能改变的部分提取出来，作为一个接口，然后在类中包含这个对象的实例，这样类的实例在运行时就可以随意调用实现了这个接口的类的行为。这就是策略模式。
    
## 二、基本的策略模式使用方法
我们直接来看例子：
**1.策略接口**
``` java
/**
 * Description: Strategy Pattern Interface
 * Created at:	2017/12/18
 */
public interface Strategy {
    void testStrategy();
}
```
**2.准备两个实现类**
``` java
/**
 * Description: 实现类A
 * Author: lllx
 * Created at: 2017/12/18
 */
public class StrategyA implements Strategy {
    @Override
    public void testStrategy() {
        System.out.println("我是实现类A");
    }
}

/**
 * Description: 实现类B
 * Author: lllx
 * Created at: 2017/12/18
 */
public class StrategyB implements Strategy {
    @Override
    public void testStrategy() {
        System.out.println("我是实现类B");
    }
}
```
**3.策略执行Context类**
``` java
/**
 * Description: 策略执行
 * Author: lllx
 * Created at: 2017/12/18
 */
public class Context {
    
    private Strategy stg;
    
    public void doAction() {
        this.stg.testStrategy();
    }
    /*  Getter And Setter */
    public Strategy getStg() {
        return stg;
    }

    public void setStg(Strategy stg) {
        this.stg = stg;
    }
}

```
这时候我们准备一个main方法来测试一下他
``` java
/**
 * Description: StrategyTest
 * Author: lllx
 * Created at: 2017/12/18
 */
public class StrategyTest {
    public static void main(String[] args) {
        Strategy stgB = new StrategyB();
        Context context = new Context(stgB);
        context.setStg(stgB);
        context.doAction();
    }
}
```
运行结果：
![strategy_1](http://ou3np1yz4.bkt.clouddn.com/strategy_1.jpg)
实例化不同的实现类可以出现不同的结果。

## 三、与Spring想结合的策略模式
我们主要利用Spring的核心IOC来实现它，还是使用上面的例子；
由于我们要在Spring的配置文件中来注入Context的实例:
``` xml
	<bean id="context" class = "top.catalinali.search.service.impl.Context">
		<property name="stg" ref="stgB"/>
	</bean>
	<bean id="stgA" class = "top.catalinali.search.service.impl.StrategyA"/>
	<bean id="stgB" class = "top.catalinali.search.service.impl.StrategyB"/>
```
这样就可以通过只修改配置文件来更改context的实现类，从而达到策略模式的目的。
## 四、通过Spring使用策略模式替换中间件的单机与集群配置
在开发环境中，许多中间件使用的是单机配置。可到了生产我们就需要使用集群配置。这里我们就可以通过策略模式来快速改变中间件的配置，现在我们以Redis为例：
**1.策略接口**
首先我们把Redis方法抽成一个接口
``` java
public interface JedisClient {
	String set(String key, String value);
	String get(String key);
	Boolean exists(String key);
	Long expire(String key, int seconds);
	Long ttl(String key);
	Long incr(String key);
	Long hset(String key, String field, String value);
	String hget(String key, String field);
	Long hdel(String key, String... field);
	Boolean hexists(String key, String field);
	List<String> hvals(String key);
	Long del(String key);
}
```

**2.单机和集群两个实现类**
这里我们准备单机和集群两个实现类：JedisClientPool和JedisClientCluster。实现上面的JedisClient接口，分别使用单机和集群的代码来实现这些方法。因为代码冗长就不在这里贴出来了。
**3.配置文件**
我们使用不同的环境只需要把不用的配置注释掉就好。
``` xml
	<!-- 连接redis单机版 -->
	<bean id="jedisClientPool" class="top.catalinali.common.jedis.JedisClientPool">
		<property name="jedisPool" ref="jedisPool"></property>
	</bean>
	<bean id="jedisPool" class="redis.clients.jedis.JedisPool">
		<constructor-arg name="host" value="192.168.72.121"/>
		<constructor-arg name="port" value="6379"/>
	</bean>
	<!-- 连接redis集群 -->
	<!-- <bean id="jedisClientCluster" class="cn.e3mall.common.jedis.JedisClientCluster">
		<property name="jedisCluster" ref="jedisCluster"/>
	</bean>
	<bean id="jedisCluster" class="redis.clients.jedis.JedisCluster">
		<constructor-arg name="nodes">
			<set>
				<bean class="redis.clients.jedis.HostAndPort">
					<constructor-arg name="host" value="192.168.25.162"></constructor-arg>
					<constructor-arg name="port" value="7001"></constructor-arg>
				</bean> 
				<bean class="redis.clients.jedis.HostAndPort">
					<constructor-arg name="host" value="192.168.25.162"></constructor-arg>
					<constructor-arg name="port" value="7002"></constructor-arg>
				</bean> 
				<bean class="redis.clients.jedis.HostAndPort">
					<constructor-arg name="host" value="192.168.25.162"></constructor-arg>
					<constructor-arg name="port" value="7003"></constructor-arg>
				</bean> 
				<bean class="redis.clients.jedis.HostAndPort">
					<constructor-arg name="host" value="192.168.25.162"></constructor-arg>
					<constructor-arg name="port" value="7004"></constructor-arg>
				</bean> 
				<bean class="redis.clients.jedis.HostAndPort">
					<constructor-arg name="host" value="192.168.25.162"></constructor-arg>
					<constructor-arg name="port" value="7005"></constructor-arg>
				</bean> 
				<bean class="redis.clients.jedis.HostAndPort">
					<constructor-arg name="host" value="192.168.25.162"></constructor-arg>
					<constructor-arg name="port" value="7006"></constructor-arg>
				</bean> 
			</set>
		</constructor-arg>
	</bean> -->
```
这样在我们开发时只需要注释掉连接集群的配置，而在上线时注释掉单机的配置就好。

## 参考文章

[spring与策略模式](http://scholers.iteye.com/blog/2012936)

---
>本文作者： catalinaLi
本文链接： http://catalinali.top/2017/strategyPattern/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。