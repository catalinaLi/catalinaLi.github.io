---
title: 走进Redis：Redis的安装、使用以及集群的搭建
date: 2017-11-06 17:48:16
tags: Redis
categories: Redis
keywords: Redis
---
---
![redis_logo](http://ou3np1yz4.bkt.clouddn.com/redis_logo.jpeg)
>今天学习了淘淘商城中的redis的使用，在这里把它记录下来。

---
<!--more-->
## 一、Redis的安装
Redis的安装是很简单的,安装之前我们需要c语言的编译环境。如果没有gcc需要在线安装。`yum install gcc-c++`。
### 安装步骤：
第一步：redis的源码包上传到linux系统。
第二步：解压缩redis。`tar -zxvf redis-3.0.0.tar.gz`
第三步：编译。进入redis源码目录。`make` 
第四步：安装。`make install PREFIX=/usr/local/redis`,PREFIX参数指定redis的安装目录。
## 二、Redis的启动与基本操作
**1.运行redis**
在redis的安装目录下直接运行`./redis-server`就可以启动redis,但这是前端启动。如果我们想后台启动就需要：
①进入*redis-3.0.0.tar.gz*解压出来的文件夹，复制里面的redis.conf文件到安装目录下。然后将daemonize改为yes![redis_1](http://ou3np1yz4.bkt.clouddn.com/redis_1.jpg)
②执行`./redis-server redis.conf`运行redis。这样redis就后台运行了,我们可以使用`ps aux|grep redis`来查看redis的运行状态
![redis_2](http://ou3np1yz4.bkt.clouddn.com/redis_2.png)
我们可以使用以下命令来进入操作redis：
```linux
./redis-cli ##进入redis客户端
./redis-cli -h 192.168.72.121 -p 6379 ##连接指定ip和端口的redis服务器
./redis-cli shutdown ##关闭redis客户端
```
**2.redis中的五种类型**
先来看几个操作数据库的基本命令：
```linux
KEYS *                   ##获得当前数据库的所有键
EXISTS key [key ...]     ##判断键是否存在，返回个数，如果key有一样的也是叠加数
DEL key [key ...]        ##删除键，返回删除的个数
TYPE key                 ##获取减值的数据类型（string，hash，list，set，zset）
FLUSHALL                 ##清空所有数据库
Expire key second        ##设置key的过期时间
Ttl key                  ##查看key的有效期
Persist key              ##清除key的过期时间。Key持久化。
```
redis中所有的数据都是Key-value类型的，其中有五种主要数据类型：字符串类型（string），散列类型（hash），列表类型（list），集合类型（set），有序集合类型（zset）。而在这五种类型中，我们最常用的是字符串类型，散列类型。这里简单介绍一下字符串类型和散列类型：
①**字符串类型string**
```
SET         ##赋值，用法： SET key value
GET         ##取值，用法： GET key
INCR        ##递增数字，仅仅对数字类型的键有用，相当于Java的i++运算，用法： INCR key
INCRBY      ##增加指定的数字，仅仅对数字类型的键有用，相当于Java的i+=3，用法：INCRBY key increment，意思是key自增increment，increment可以为负数，表示减少。
DECR        ##递减数字，仅仅对数字类型的键有用，相当于Java的i–，用法：DECR key
DECRBY      ##减少指定的数字，仅仅对数字类型的键有用，相当于Java的i-=3，用法：DECRBY key decrement，意思是key自减decrement，decrement可以为正数，表示增加。
INCRBYFLOAT ##增加指定浮点数，仅仅对数字类型的键有用，用法：INCRBYFLOAT key increment
APPEND      ##向尾部追加值，相当于Java中的”hello”.append(“ world”)，用法：APPEND key value
STRLEN      ##获取字符串长度，用法：STRLEN key
MSET        ##同时设置多个key的值，用法：MSET key1 value1 [key2 value2 ...]
MGET        ##同时获取多个key的值，用法：MGET key1 [key2 ...]
```
②**散列类型hash**
```
HSET        ##赋值，用法：HSET key field value
HMSET       ##一次赋值多个字段，用法：HMSET key field1 value1 [field2 values]
HGET        ##取值，用法：HSET key field
HMGET       ##一次取多个字段的值，用法：HMSET key field1 [field2]
HGETALL     ##一次取所有字段的值，用法：HGETALL key
HEXISTS     ##判断字段是否存在，用法：HEXISTS key field
HSETNX      ##当字段不存在时赋值，用法：HSETNX key field value
HINCRBY     ##增加数字，仅对数字类型的值有用，用法：HINCRBY key field increment
HDEL        ##删除字段，用法：HDEL key field
HKEYS       ##获取所有字段名，用法：HKEYS key
HVALS       ##获取所有字段值，用法：HVALS key
HLEN        ##获取字段数量，用法：HLEN key
```
其他的数据类型就不详细介绍了，相关资料可以点击[传送门](https://www.baidu.com/s?wd=redis%E7%9A%84%E4%BA%94%E7%A7%8D%E7%B1%BB%E5%9E%8B&rsv_spt=1&rsv_iqid=0xe2ece0d100005fa4&issp=1&f=8&rsv_bp=0&rsv_idx=2&ie=utf-8&tn=baiduhome_pg&rsv_enter=1&rsv_n=2&rsv_sug3=17&rsv_sug1=14&rsv_sug7=100&rsv_t=eae6CtVWEeBxwTXJYEIsK1Rg%2BIZxWLgTM0hyCSOEYS2VOLZsg6CfpRxdvrRCXXlTZCe7&rsv_sug2=0&inputT=3842&rsv_sug4=3842)
## 三、Redis的持久化方案
Redis的所有数据都是保存到内存中的。
Rdb：快照形式，定期把内存中当前时刻的数据保存到磁盘。Redis默认支持的持久化方案,一直开启,不会被关闭。
![redis_Rdb](http://ou3np1yz4.bkt.clouddn.com/redis_3.png)
通过上图我们可以看到,**dump.rdb**会在以下情况保存一次。

- 900秒（15分钟）之内至少有1个KEY进行了改变
- 300秒（5分钟）之内至少有10个KEY进行了改变
- 60秒（1分钟）之内至少有10000个KEY进行了改变

aof形式：append only file。把所有对redis数据库操作的命令，增删改操作的命令。保存到文件中。数据库恢复时把所有的命令执行一遍即可。要想开启aof模式需要在**redis.conf**配置文件中将appendonly改为yes
![redis_aof](http://ou3np1yz4.bkt.clouddn.com/redis_4.png)
## 四、Redis集群的搭建
### 1.Redis集群特点
Redis集群搭建的方式有多种，例如使用zookeeper等，但从redis3.0之后版本支持redis-cluster集群，Redis-Cluster采用无中心结构，每个节点保存数据和整个集群状态,每个节点都和其他所有节点连接。其redis-cluster架构图如下：
![redis_cluster](http://ou3np1yz4.bkt.clouddn.com/redis_5.png)
其架构细节：
1、所有的redis节点彼此互联(PING-PONG机制),内部使用二进制协议优化传输速度和带宽。
2、节点的fail是通过集群中超过半数的节点检测失效时才生效。
3、客户端与redis节点直连,不需要中间proxy层.客户端不需要连接集群所有节点,连接集群中任何一个可用节点即可。
4、redis-cluster把所有的物理节点映射到[0-16383]slot上（不一定是平均分配）,cluster 负责维护node<->slot<->value。
5、Redis集群预分好16384个哈希槽，当需要在 Redis 集群中放置一个 key-value 时，根据 CRC16(key) mod 16384的值，决定将一个key放到哪个槽中。
### 2.Redis集群环境搭建
Redis集群中至少应该有三个节点。要保证集群的高可用，需要每个节点有一个备份机。
Redis集群至少需要6台服务器。由于条件限制,这里采用与淘淘商城相同的方式搭建伪分布式。在一台虚拟机运行6个redis实例。需要修改redis的端口号7001-7006。
**第一步**：创建6个redis实例，每个实例运行在不同的端口。需要修改redis.conf配置文件,将端口号修改成7001-7006。除此之外,还需要把cluster-enabled yes前的注释去掉。
**第二步**：启动每个redis实例。这里我们可以自己写一个shell脚本,这里给出我的也就是淘淘商城中所使用的脚本：
```
cd redis01
./redis-server redis.conf
cd ..
cd redis02
./redis-server redis.conf
cd ..
cd redis03
./redis-server redis.conf
cd ..
cd redis04
./redis-server redis.conf
cd ..
cd redis05
./redis-server redis.conf
cd ..
cd redis06
./redis-server redis.conf
cd ..
```
关闭集群的脚本也类似：
```
./redis-cli -p 7001 shutdown
./redis-cli -p 7002 shutdown
./redis-cli -p 7003 shutdown
./redis-cli -p 7004 shutdown
./redis-cli -p 7005 shutdown
./redis-cli -p 7006 shutdown
```
记得在运行脚本前要添加可执行（x）的权限：`chmod u+x fileName.sh`
**第三步**：使用ruby脚本搭建集群。
首先我们需要安装ruby运行环境
```linux
yum install ruby
yum install rubygems
```
然后我们需要安装ruby脚本运行使用的包,将这个文件放在集群文件根目录下，然后运行
```
gem install redis-3.0.0.gem
```
文件我上传在了[CSDN](http://download.csdn.net/download/a3212/10048482)。
这时我们就可以启动集群环境了,运行下面这条命令:
```
./redis-trib.rb create --replicas 1 192.168.72.121:7001 192.168.72.121:7002 192.168.72.121:7003 192.168.72.121:7004 192.168.72.121:7005  192.168.72.121:7006
```
从这条命令我们可以看出使用6个节点来创建一个集群，集群中每个主节点有1个从节点。运行过程中输入一个yes就成功了。需要注意的是在真正搭建的时候一定要关闭防火墙。这时候我们查看进程
**第四步**：连接Redis集群
因为每一个节点都是互联互通的,所以我们不论连哪个节点都是可以的。
## 五、使用Java操作Redis
redis的客户端有很多,从[官网](http://www.redis.cn/clients.html#java)中我们可以看出来,不仅支持的语言众多,而且很多语言有不止一种连接方式。
![redis_client](http://ou3np1yz4.bkt.clouddn.com/redis_6.png)
这里我们采用在JAVA中使用最广泛的Jedis作为实例。
### 1.连接单机版
```java
    @Test
	public void testJedis() throws Exception {
		// 第一步：创建一个Jedis对象。需要指定服务端的ip及端口。
		Jedis jedis = new Jedis("192.168.25.153", 6379);
		// 第二步：使用Jedis对象操作数据库，每个redis命令对应一个方法。
		String result = jedis.get("hello");
		// 第三步：打印结果。
		System.out.println(result);
		// 第四步：关闭Jedis
		jedis.close();
	}

```
使用起来很简单,不过通常在连接单机版的时候我们采用的是连接池的方式。
### 2.连接单机版使用连接池
```java
    @Test
	public void testJedisPool() throws Exception {
		// 第一步：创建一个JedisPool对象。需要指定服务端的ip及端口。
		JedisPool jedisPool = new JedisPool("192.168.25.153", 6379);
		// 第二步：从JedisPool中获得Jedis对象。
		Jedis jedis = jedisPool.getResource();
		// 第三步：使用Jedis操作redis服务器。
		jedis.set("jedis", "test");
		String result = jedis.get("jedis");
		System.out.println(result);
		// 第四步：操作完毕后关闭jedis对象，连接池回收资源。
		jedis.close();
		// 第五步：关闭JedisPool对象。
		jedisPool.close();
	}
```
连接集群的方式就又稍微不一样了。
### 3.连接集群版
```
    @Testjava
	public void testJedisCluster() throws Exception {
		// 第一步：使用JedisCluster对象。需要一个Set<HostAndPort>参数。Redis节点的列表。
		Set<HostAndPort> nodes = new HashSet<>();
		nodes.add(new HostAndPort("192.168.72.121", 7001));
		nodes.add(new HostAndPort("192.168.72.121", 7002));
		nodes.add(new HostAndPort("192.168.72.121", 7003));
		nodes.add(new HostAndPort("192.168.72.121", 7004));
		nodes.add(new HostAndPort("192.168.72.121", 7005));
		nodes.add(new HostAndPort("192.168.72.121", 7006));
		JedisCluster jedisCluster = new JedisCluster(nodes);
		// 第二步：直接使用JedisCluster对象操作redis。在系统中单例存在。
		jedisCluster.set("hello", "100");
		String result = jedisCluster.get("hello");
		// 第三步：打印结果
		System.out.println(result);
		// 第四步：系统关闭前，关闭JedisCluster对象。
		jedisCluster.close();
	}
```

---
>本文作者： catalinaLi
本文链接： http://catalinali.top/2017/buildredis/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。
