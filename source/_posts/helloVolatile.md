---
title: JAVA并发编程(一)：理解volatile关键字
date: 2018-08-15 10:11:12
tags: juc
categories: juc
keywords: juc
---

![volatile_logo](http://ou3np1yz4.bkt.clouddn.com/volatile_logo.png)
>Java中volatile这个热门的关键字，在面试中经常会被提及，在各种技术交流群中也经常被讨论：volatile关键字在java多线程中有着比较重要作用，volatile主要作用是可以保持变量在多线程中是实时可见的,是java中提供的最轻量的同步机制。

<!--more-->

## 一、JAVA内存模型概述
在了解volatile关键字之前，我们先来认识一下Java的内存模型。
Java线程之间的通信由Java内存模型（本文简称为JMM）控制，JMM决定一个线程对共享变量的写入何时对另一个线程可见。从抽象的角度来看，JMM定义了线程和主内存之间的抽象关系：线程之间的共享变量存储在主内存（Main Memory）中，每个线程都有一个私有的本地内存（Local Memory），本地内存中存储了该线程以读/写共享变量的副本。本地内存是JMM的一个抽象概念，并不真实存在。它涵盖了缓存、写缓冲区、寄存器以及其他的硬件和编译器优化。Java内存模型的抽象示意如图所示
![volatile_1](http://ou3np1yz4.bkt.clouddn.com/volatile_1.png)
如果线程A与线程B之间要通信的话，必须要经历下面2个步骤。
1）线程A把本地内存A中更新过的共享变量刷新到主内存中去。
2）线程B到主内存中去读取线程A之前已更新过的共享变量。
这个模型在单线程中没有什么问题，但是在多线程中就会产生一些数据的“脏读”等问题。
举个简单的例子：在java中，使用两个线程执行下面这个语句：
``` java
int i = 0;
i = i + 1;
```
我们期望的是在两个线程执行完之后获得i的结果是2，但事实真的会这样的吗？
我们反复执行后可以发现：结果可能是2，也可能是1。
每条线程执行时需要将i的值从主内存中读取到工作内存中。其中存在这么一种情况：初始时，两个线程分别读取i的值存入各自所在的工作内存当中，然后线程1进行加1操作，然后把i的最新值1写入到内存。此时线程2的工作内存当中i的值还是0，进行加1操作之后，i的值为1，然后线程2把i的值写入内存。当出现这种情况后返回的结果就成了1了。
这就是缓存一致性的问题，在解决这个问题前我们要先了解一下并发编程的三个概念：原子性，有序性，可见性。
## 二、并发编程中的三个概念
### 1.原子性
定义：原子操作意 为“不可被中断的一个或一系列操作。
比如 a=0；（a非long和double类型） 这个操作是不可分割的，那么我们说这个操作是原子操作。再比如：a++； 这个操作实际是a = a + 1；是可分割的，所以他不是一个原子操作。非原子操作都会存在线程安全问题，需要我们使用同步技术（sychronized）来让它变成一个原子操作。如果一个操作是原子操作，那么我们称它具有原子性。java的concurrent包下提供了一些原子类，我们可以通过阅读API来了解这些原子类的用法。比如：AtomicInteger、AtomicLong、AtomicReference等。
如果要实现更大范围操作的原子性，可以通过**锁**和**CAS算法**来实现。
### 2.可见性
定义：可见性是指当一个线程修改一个共享变量时，另外一个线程能读到这个修改的值。
举个简单的例子，看下面这段代码：
``` java
//线程1执行的代码
int i = 0;
i = 10;
 
//线程2执行的代码
j = i;
```
由上面的分析可知，当线程1执行 i =10这句时，会先把i的初始值加载到工作内存中，然后赋值为10，那么在线程1的工作内存当中i的值变为10了，却没有立即写入到主存当中。

此时线程2执行 j = i，它会先去主存读取i的值并加载到线程2的工作内存当中，注意此时内存当中i的值还是0，那么就会使得j的值为0，而不是10.

这就是可见性问题，线程1对变量i修改了之后，线程2没有立即看到线程1修改的值。
### 3.有序性
定义：即程序执行的顺序按照代码的先后顺序执行。
``` java
int i = 0;              
boolean flag = false;
i = 1;                //语句1  
flag = true;          //语句2
```
上面代码定义了一个int型变量，定义了一个boolean类型变量，然后分别对两个变量进行赋值操作。从代码顺序上看，语句1是在语句2前面的，那么JVM在真正执行这段代码的时候会保证语句1一定会在语句2前面执行吗？不一定，为什么呢？这里可能会发生指令重排序（Instruction Reorder）。
下面解释一下什么是指令重排序，一般来说，处理器为了提高程序运行效率，可能会对输入代码进行优化，它不保证程序中各个语句的执行先后顺序同代码中的顺序一致，但是它会保证程序最终执行结果和代码顺序执行的结果是一致的。
比如上面的代码中，语句1和语句2谁先执行对最终的程序结果并没有影响，那么就有可能在执行过程中，语句2先执行而语句1后执行。
但是要注意，虽然处理器会对指令进行重排序，但是它会保证程序最终结果会和代码顺序执行结果相同，那么它靠什么保证的呢？再看下面一个例子：
``` java
int a = 10;    //语句1
int r = 2;    //语句2
a = a + 3;    //语句3
r = a*a;     //语句4
```
这段代码有4个语句，那么可能的一个执行顺序是：
![volatile_2](http://ou3np1yz4.bkt.clouddn.com/volatile_2.png)
不可能，因为处理器在进行重排序时是会考虑指令之间的数据依赖性，如果一个指令Instruction 2必须用到Instruction 1的结果，那么处理器会保证Instruction 1会在Instruction 2之前执行。

虽然重排序不会影响单个线程内程序执行的结果，但是多线程呢？下面看一个例子：
```
//线程1:

context = loadContext();   //语句1
inited = true;             //语句2

 //线程2:
while(!inited ){
   sleep()
}
doSomethingwithconfig(context);
```
上面代码中，由于语句1和语句2没有数据依赖性，因此可能会被重排序。假如发生了重排序，在线程1执行过程中先执行语句2，而此是线程2会以为初始化工作已经完成，那么就会跳出while循环，去执行doSomethingwithconfig(context)方法，而此时context并没有被初始化，就会导致程序出错。
从上面可以看出，指令重排序不会影响单个线程的执行，但是会影响到线程并发执行的正确性。
也就是说，要想并发程序正确地执行，必须要保证原子性、可见性以及有序性。只要有一个没有被保证，就有可能会导致程序运行不正确。
## 三、深入理解volatile关键字
　在多线程并发编程中synchronized和volatile都扮演着重要的角色，volatile是轻量级的 synchronized。如果volatile变量修饰符使用恰当 的话，它比synchronized的使用和执行成本更低，因为它不会引起线程上下文的切换和调度。
### 1.volatile的作用
　一旦一个共享变量（类的成员变量、类的静态成员变量）被volatile修饰之后，那么就具备了两层语义：
　　1）保证了内存的可见性，即一个线程修改了某个变量的值，这新值对其他线程来说是立即可见的。
　　2）禁止进行指令重排序。
### 1.volatile不能保证原子性
我们来看下面这一段代码
``` java
/*
 * i++ 的原子性问题：i++ 的操作实际上分为三个步骤“读-改-写”
 * 		  int i = 10;
 * 		  i = i++; //10
 * 
 * 		  int temp = i;
 * 		  i = i + 1;
 * 		  i = temp;
 */
public class TestAtomicDemo {

	public static void main(String[] args) {
		AtomicDemo ad = new AtomicDemo();
		
		for (int i = 0; i < 10; i++) {
			new Thread(ad).start();
		}
	}
	
}

class AtomicDemo implements Runnable{
	
	private volatile int serialNumber = 0;
	
	@Override
	public void run() {
		
		try {
			Thread.sleep(200);
		} catch (InterruptedException e) {
		}
		
		System.out.println(getSerialNumber());
	}
	
	public int getSerialNumber(){
		return serialNumber++;
	}
}

```
反复运行这段代码，发现结果并不是每次都是0-9,而是有可能会有重复结果出现。
自增操作是不具备原子性的，它包括读取变量的原始值、进行加1操作、写入工作内存。那么就是说自增操作的三个子操作可能会分割开执行：
线程1对变量进行读取操作之后，被阻塞了的话，并没有对serialNumber值进行修改。虽然volatile能保证线程2对变量serialNumber的值读取是从内存中读取的，但是线程1没有进行修改，所以线程2根本就不会看到修改的值。

根源就在这里，自增操作不是原子性操作，而且volatile也无法保证对变量的任何操作都是原子性的。那么原子性问题究竟应该怎么解决呢？我们在下篇文章中会给出详细解答。
## 四、volatile关键字的应用场景
synchronized关键字是防止多个线程同时执行一段代码，那么就会很影响程序执行效率，而volatile关键字在某些情况下性能要优于synchronized，但是要注意volatile关键字是无法替代synchronized关键字的，因为volatile关键字无法保证操作的原子性。通常来说，使用volatile必须具备以下2个条件：

1）对变量的写操作不依赖于当前值
2）该变量没有包含在具有其他变量的不变式中

下面列举几个Java中使用volatile的几个场景。
**1.状态标记量**
``` java
volatile boolean flag = false;
 //线程1
while(!flag){
    doSomething();
}
  //线程2
public void setFlag() {
    flag = true;
}

根据状态标记，终止线程。
```
**2.单例模式中的double check**
``` java
class Singleton{
    private volatile static Singleton instance = null;

    private Singleton() {

    }

    public static Singleton getInstance() {
        if(instance==null) {
            synchronized (Singleton.class) {
                if(instance==null)
                    instance = new Singleton();
            }
        }
        return instance;
    }
}
```
为什么要使用volatile 修饰instance？
主要在于instance = new Singleton()这句，这并非是一个原子操作，事实上在 JVM 中这句话大概做了下面 3 件事情:
1.给 instance 分配内存
2.调用 Singleton 的构造函数来初始化成员变量
3.将instance对象指向分配的内存空间（执行完这步 instance 就为非 null 了）。

但是在 JVM 的即时编译器中存在指令重排序的优化。也就是说上面的第二步和第三步的顺序是不能保证的，最终的执行顺序可能是 1-2-3 也可能是 1-3-2。如果是后者，则在 3 执行完毕、2 未执行之前，被线程二抢占了，这时 instance 已经是非 null 了（但却没有初始化），所以线程二会直接返回 instance，然后使用，然后顺理成章地报错。

## 参考文章

- [《java并发编程的艺术》](https://www.baidu.com/s?wd=java%E5%B9%B6%E5%8F%91%E7%BC%96%E7%A8%8B%E7%9A%84%E8%89%BA%E6%9C%AF&rsv_spt=1&rsv_iqid=0xc652b9a6000070c7&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&rqlang=cn&tn=baiduhome_pg&rsv_enter=0&oq=java%25E5%25B9%25B6%25E5%258F%2591%25E7%25BC%2596%25E7%25A8%258B%25E7%259A%2584%25E8%2589%25BA%25E6%259C%25AFpdf&inputT=1301&rsv_t=9400ch8xJFe67WDXfsXzKSARdHHTqMDsYP9q4z0hVkvXwCg7TDPQj8n8kCqdXIhmXqYR&rsv_pq=cec2174c00008def&rsv_sug3=20&rsv_sug4=1301)
- [Java并发编程：volatile关键字解析](http://www.cnblogs.com/dolphin0520/p/3920373.html)
- [Java中volatile关键字详解（2）？真正了解volatile](https://blog.csdn.net/it_dx/article/details/70045286?locationNum=4&fps=1)

---

>本文作者： catalinaLi
本文链接： http://catalinali.top/2018/helloVolatile/



