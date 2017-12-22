---
title: ActiveMQ从入门到实践
date: 2017-12-22 09:48:26
tags: mq
categories: mq
keywords: mq
---

![mq_logo](http://ou3np1yz4.bkt.clouddn.com/mq_logo.jpg)
<!--more-->

## 一、什么是ActiveMQ

首先我们应该先了解J2EE中的一个重要规范：JMS(The Java Message Service)Java消息服务。而JMS的客户端之间可以通过JMS服务进行异步的消息传输。它主要有两种模型：点对点和发布订阅模型。

**点对点的模型特点：**：

- 每个消息只有一个消费者（Consumer）(即一旦被消费，消息就不再在消息队列中)。
- 发送者和接收者之间在时间上没有依赖性，也就是说当发送者发送了消息之后，不管接收者有没有正在运行，它不会影响到消息被发送到队列。
- 接收者在成功接收消息之后需向队列应答成功。

**发布订阅模型特点：**

- 每个消息可以有多个消费者
- 发布者和订阅者之间有时间上的依赖性。针对某个主题（Topic）的订阅者，它必须创建一个订阅者之后，才能消费发布者的消息，而且为了消费消息，订阅者必须保持运行的状态。
- 为了缓和这样严格的时间相关性，JMS允许订阅者创建一个可持久化的订阅。这样，即使订阅者没有被激活（运行），它也能接收到发布者的消息。

JMS还定义了五种不同的消息正文格式，以及调用的消息类型，允许你发送并接收以一些不同形式的数据，提供现有消息格式的一些级别的兼容性。

- StreamMessage -- Java原始值的数据流
- MapMessage--一套名称-值对
- TextMessage--一个字符串对象
- ObjectMessage--一个序列化的 Java对象
- BytesMessage--一个字节的数据流

其中我们用的最多的就是TextMessage字符串对象

消息中间件作为JMS的实现，在J2EE的企业应用中扮演着特殊的角色。ActiveMQ是一个易于使用的消息中间件。作为JMS的实现，消息中间件的使用步骤都大同小异，下面我们以ActiveMQ为例来介绍一下其使用。
## 二、ActiveMQ的基本使用
**ActiveMQ的安装：**
ActiveMQ安装很简单，只需从其[官网](http://activemq.apache.org/)下载至linux环境，解压并进入bin目录
```linux
./activemq start #启动
./activemq stop #停止
./activemq status #查看状态
```
使用启动命令运行就好了。然后我们打开浏览器进入管理后台http://yourip:8161/admin/
输入默认的账号密码：admin。就可以看到管控台了。
![mq_1](http://ou3np1yz4.bkt.clouddn.com/mq_1.jpg)
然后我们使用java操作ActiveMQ,mq的使用基本都需要创建连接、session、Destination这么几步，我们直接看代码吧。
**点对点的模型：**
生产者代码：
```java
	@Test
	public void testQueueProducer() throws Exception {
		//1、创建一个连接工厂对象，需要指定服务的ip及端口。
		ConnectionFactory connectionFactory = new ActiveMQConnectionFactory("tcp://192.168.25.161:61616");
		//2、使用工厂对象创建一个Connection对象。
		Connection connection = connectionFactory.createConnection();
		//3、开启连接，调用Connection对象的start方法。
		connection.start();
		//4、创建一个Session对象。
		//第一个参数：是否开启事务。如果true开启事务，第二个参数无意义。一般不开启事务false。
		//第二个参数：应答模式。自动应答或者手动应答。一般自动应答。
		Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
		//5、使用Session对象创建一个Destination对象。两种形式queue、topic，现在应该使用queue
		Queue queue = session.createQueue("test-queue");
		//6、使用Session对象创建一个Producer对象。
		MessageProducer producer = session.createProducer(queue);
		//7、创建一个Message对象，可以使用TextMessage。
		/*TextMessage textMessage = new ActiveMQTextMessage();
		textMessage.setText("hello Activemq");*/
		TextMessage textMessage = session.createTextMessage("hello activemq");
		//8、发送消息
		producer.send(textMessage);
		//9、关闭资源
		producer.close();
		session.close();
		connection.close();
	}
```
消费者代码：
``` java
	@Test
	public void testQueueConsumer() throws Exception {
		//创建一个ConnectionFactory对象连接MQ服务器
		ConnectionFactory connectionFactory = new ActiveMQConnectionFactory("tcp://192.168.25.161:61616");
		//创建一个连接对象
		Connection connection = connectionFactory.createConnection();
		//开启连接
		connection.start();
		//使用Connection对象创建一个Session对象
		Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
		//创建一个Destination对象。queue对象
		Queue queue = session.createQueue("spring-queue");
		//使用Session对象创建一个消费者对象。
		MessageConsumer consumer = session.createConsumer(queue);
		//接收消息
		consumer.setMessageListener(new MessageListener() {
			
			@Override
			public void onMessage(Message message) {
				//打印结果
				TextMessage textMessage = (TextMessage) message;
				String text;
				try {
					text = textMessage.getText();
					System.out.println(text);
				} catch (JMSException e) {
					e.printStackTrace();
				}
				
			}
		});
		//等待接收消息
		System.in.read();
		//关闭资源
		consumer.close();
		session.close();
		connection.close();
	}
```
当我们运行了生产者后，我们可以在管控台看到Queue中多了一条消息，并且还没有被消费
![mq_2](http://ou3np1yz4.bkt.clouddn.com/mq_2.jpg)
当我们运行消费者后就可以接收到生产者发送的消息。
![mq_3](http://ou3np1yz4.bkt.clouddn.com/mq_3.jpg)
并且管控台也出现了相应的变化
![mq_4](http://ou3np1yz4.bkt.clouddn.com/mq_4.jpg)
**发布订阅的模型：**
生产者代码：
```
    @Test
    public void testTopicProducer() throws Exception {
        //1、创建一个连接工厂对象，需要指定服务的ip及端口。
        ConnectionFactory connectionFactory = new ActiveMQConnectionFactory("tcp://192.168.72.121:61616");
        //2、使用工厂对象创建一个Connection对象。
        Connection connection = connectionFactory.createConnection();
        //3、开启连接，调用Connection对象的start方法。
        connection.start();
        //4、创建一个Session对象。
        //第一个参数：是否开启事务。如果true开启事务，第二个参数无意义。一般不开启事务false。
        //第二个参数：应答模式。自动应答或者手动应答。一般自动应答。
        Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
        //5、使用Session对象创建一个Destination对象。两种形式queue、topic，现在应该使用topic
        Topic topic = session.createTopic("test-topic");
        //6、使用Session对象创建一个Producer对象。
        MessageProducer producer = session.createProducer(topic);
        //7、创建一个Message对象，可以使用TextMessage。
		/*TextMessage textMessage = new ActiveMQTextMessage();
		textMessage.setText("hello Activemq");*/
        TextMessage textMessage = session.createTextMessage("topic message");
        //8、发送消息
        producer.send(textMessage);
        //9、关闭资源
        producer.close();
        session.close();
        connection.close();
    }
```
消费者代码：
``` java
    @Test
    public void testTopicConsumer() throws Exception {
        //创建一个ConnectionFactory对象连接MQ服务器
        ConnectionFactory connectionFactory = new ActiveMQConnectionFactory("tcp://192.168.72.121:61616");
        //创建一个连接对象
        Connection connection = connectionFactory.createConnection();
        //开启连接
        connection.start();
        //使用Connection对象创建一个Session对象
        Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
        //创建一个Destination对象。topic对象
        Topic topic = session.createTopic("test-topic");
        //使用Session对象创建一个消费者对象。
        MessageConsumer consumer = session.createConsumer(topic);
        //接收消息
        consumer.setMessageListener(new MessageListener() {

            @Override
            public void onMessage(Message message) {
                //打印结果
                TextMessage textMessage = (TextMessage) message;
                String text;
                try {
                    text = textMessage.getText();
                    System.out.println(text);
                } catch (JMSException e) {
                    e.printStackTrace();
                }

            }
        });
        System.out.println("topic消费者3启动。。。。");
        //等待接收消息
        System.in.read();
        //关闭资源
        consumer.close();
        session.close();
        connection.close();
    }
```
发布订阅模型具有严格的时间相关性，如果没有订阅者的话，发布者发布的内容就被浪费掉了。
## 三、ActiveMQ与Spring整合
Spring提供了JMSTemplate,极大地便利了MQ的使用，我们只需要提前在配置文件中配置相关的JMS配置，就可在代码中直接使用。
**Spring配置文件：**
``` xml
	<!-- 真正可以产生Connection的ConnectionFactory，由对应的 JMS服务厂商提供 -->
	<bean id="targetConnectionFactory" class="org.apache.activemq.ActiveMQConnectionFactory">
		<property name="brokerURL" value="tcp://192.168.25.161:61616" />
	</bean>
	<!-- Spring用于管理真正的ConnectionFactory的ConnectionFactory -->
	<bean id="connectionFactory" class="org.springframework.jms.connection.SingleConnectionFactory">
		<!-- 目标ConnectionFactory对应真实的可以产生JMS Connection的ConnectionFactory -->
		<property name="targetConnectionFactory" ref="targetConnectionFactory" />
	</bean>
	<!-- 配置生产者 -->
	<!-- Spring提供的JMS工具类，它可以进行消息发送、接收等 -->
	<bean id="jmsTemplate" class="org.springframework.jms.core.JmsTemplate">
		<!-- 这个connectionFactory对应的是我们定义的Spring提供的那个ConnectionFactory对象 -->
		<property name="connectionFactory" ref="connectionFactory" />
	</bean>
	<!--这个是队列(Queue)目的地，点对点的 -->
	<bean id="queueDestination" class="org.apache.activemq.command.ActiveMQQueue">
		<constructor-arg>
			<value>spring-queue</value>
		</constructor-arg>
	</bean>
	<!--这个是主题(Topic)目的地，一对多的 -->
	<bean id="topicDestination" class="org.apache.activemq.command.ActiveMQTopic">
		<constructor-arg value="itemAddTopic" />
	</bean>
	
	<!-- 接收消息配置 -->
	<!-- 配置监听器 -->
	<bean id="myMessageListener" class="cn.e3mall.search.listener.MyMessageListener" />
	<!-- 消息监听容器 -->
	<bean class="org.springframework.jms.listener.DefaultMessageListenerContainer">
		<property name="connectionFactory" ref="connectionFactory" />
		<property name="destination" ref="queueDestination" />
		<property name="messageListener" ref="myMessageListener" />
	</bean>
	
```
配置好后可在代码中使用以下方法
生产者代码：
``` java
    @Test
	public void testQueueProducer() throws Exception {
		// 第一步：初始化一个spring容器
		ApplicationContext applicationContext = new ClassPathXmlApplicationContext("classpath:spring/applicationContext-activemq.xml");
		// 第二步：从容器中获得JMSTemplate对象。
		JmsTemplate jmsTemplate = applicationContext.getBean(JmsTemplate.class);
		// 第三步：从容器中获得一个Destination对象
		Queue queue = (Queue) applicationContext.getBean("queueDestination");
		// 第四步：使用JMSTemplate对象发送消息，需要知道Destination
		jmsTemplate.send(queue, new MessageCreator() {
			
			@Override
			public Message createMessage(Session session) throws JMSException {
				TextMessage textMessage = session.createTextMessage("spring activemq test");
				return textMessage;
			}
		});
	}
```
消费者代码：
``` java
public class MyMessageListener implements MessageListener {
    //继承MessageListener接口并重新它的onMessage方法
	@Override
	public void onMessage(Message message) {
		
		try {
			TextMessage textMessage = (TextMessage) message;
			//取消息内容
			String text = textMessage.getText();
			System.out.println(text);
		} catch (JMSException e) {
			e.printStackTrace();
		}
```
消费者的使用是在Spring容器中注入一个监听器，所以我们需要在配置文件中配置它，它随着Spring的启动而启动，并且实时监听。当有消息向它发送时，他会立即进行逻辑处理。

---
>本文作者： catalinaLi
本文链接： http://catalinali.top/2017/useMQ/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。
