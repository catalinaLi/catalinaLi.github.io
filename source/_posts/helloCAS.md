---
title: JAVA并发编程(二)：理解CAS机制
date: 2018-08-19 14:09:25
tags: juc
categories: juc
keywords: juc
---

![volatile_logo](http://ou3np1yz4.bkt.clouddn.com/helloCAS_logo.jpg)
>也许大家已经听说过，锁分两种，一个叫悲观锁，一种称之为乐观锁。Synchronized就是悲观锁的一种，也称之为独占锁，加了synchronized关键字的代码基本上就只能以单线程的形式去执行了，它会导致其他需要该资源的线程挂起，直到前面的线程执行完毕释放所资源。而另外一种乐观锁是一种更高效的机制，它的原理就是每次不加锁去执行某项操作，如果发生冲突则失败并重试，直到成功为止，其实本质上不算锁，所以很多地方也称之为自旋。

<!--more-->

## 一、并发编程中的原子性问题
在上篇[JAVA并发编程(一)：理解volatile关键字](http://catalinali.top/2018/helloVolatile/)的结尾留了一个原子性的问题：
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
运行结果并不总是0-10。要想解决这个问题，你可能会说加Synchronized同步锁：加了同步锁之后，serialNumber++操作变成了原子性操作，所以最终的输出一定是0-9，代码实现了线程安全。
``` java
	public static void main(String[] args) {
		AtomicDemo ad = new AtomicDemo();
		
		for (int i = 0; i < 10; i++) {
			synchronized (TestAtomicDemo.class) {
				new Thread(ad).start();				
			}
		}
	}
```
但是众所周知的是Synchronized同步锁比较耗费性能，在某些情况下并不是一个好的选择，那有没有什么好的办法呢？在JDK1.5之后，java.util.concurrent.atomic包下为我们封装了常用的原子变量，他们底层就是使用了**CAS**（compare and swap）算法来保证原子性，我们将上面例子中的serialNumber改为使用AtomicInteger修饰，然后运行发现也可以得到正确的结果。
``` java
//	private volatile int serialNumber = 0;
	
	private AtomicInteger serialNumber = new AtomicInteger(0);
```

## 二、什么是CAS？
CAS是英文单词Compare And Swap的缩写，翻译过来就是比较并替换。
CAS机制当中使用了3个基本操作数：内存地址V，旧的预期值A，要修改的新值B。
更新一个变量的时候，只有当变量的预期值A和内存地址V当中的实际值相同时，才会将内存地址V对应的值修改为B。
来看一个例子：
我们现在有两个线程：
1.在内存地址V当中，存储着值为10的变量。
2.此时线程1想要把变量的值增加1。对线程1来说，旧的预期值A=10，要修改的新值B=11。
3.在线程1要提交更新之前，另一个线程2抢先一步，把内存地址V中的变量值率先更新成了11。
4.线程1开始提交更新，首先进行A和地址V的实际值比较（Compare），发现A不等于V的实际值，提交失败。
5.线程1重新获取内存地址V的当前值，并重新计算想要修改的新值。此时对线程1来说，A=11，B=12。这个重新尝试的过程被称为自旋。
6.这一次比较幸运，没有其他线程改变地址V的值。线程1进行Compare，发现A和地址V的实际值是相等的。
7.线程1进行SWAP，把地址V的值替换为B，也就是12。
从思想上来说，Synchronized属于悲观锁，悲观地认为程序中的并发情况严重，所以严防死守。CAS属于乐观锁，乐观地认为程序中的并发情况不那么严重，所以让线程不断去尝试更新。
## 三、CAS的缺点
CAS机制这么巧妙，是不是在任何地方都比同步锁要好？然而并不是这样的，CAS机制有以下几个问题：

- **CPU开销较大**
在并发量比较高的情况下，如果许多线程反复尝试更新某一个变量，却又一直更新不成功，循环往复，会给CPU带来很大的压力。
- **不能保证代码块的原子性**
CAS机制所保证的只是一个变量的原子性操作，而不能保证整个代码块的原子性。比如需要保证3个变量共同进行原子性的更新，就不得不使用Synchronized了。
- **ABA问题**
什么是ABA呢？简单说就是一个值从A改成了B，又从B改成了A。
1.假设内存中有一个值为A的变量，存储在地址V当中。
2.此时有三个线程想使用CAS的方式更新这个变量值，每个线程的执行时间有略微的偏差。线程1和线程2已经获得当前值，线程3还未获得当前值。
3.接下来，线程1先一步执行成功，把当前值成功从A更新为B；同时线程2因为某种原因被阻塞住，没有做更新操作；线程3在线程1更新之后，获得了当前值B。
4.再之后，线程2仍然处于阻塞状态，线程3继续执行，成功把当前值从B更新成了A。
5.最后，线程2终于恢复了运行状态，由于阻塞之前已经获得了“当前值”A，并且经过compare检测，内存地址V中的实际值也是A，所以成功把变量值A更新成了B。
6.这个过程中，线程2获取到的变量值A是一个旧值，尽管和当前的实际值相同，但内存地址V中的变量已经经历了A->B->A的改变。
从表面看起来运行结果好像没什么问题，但是结合实际情况就会出现问题了。比如取款时有可能发生两个线程同时扣款成功的情况。所以，真正要做到严谨的CAS机制，我们在Compare阶段不仅要比较期望值A和地址V中的实际值，还要比较变量的版本号是否一致。
在Java当中，AtomicStampedReference类就实现了用版本号做比较的CAS机制。
## 参考文章

- [漫画：什么是 CAS 机制？](https://mp.weixin.qq.com/s?__biz=MzIxMjE5MTE1Nw==&mid=2653192625&idx=1&sn=cbabbd806e4874e8793332724ca9d454&chksm=8c99f36bbbee7a7d169581dedbe09658d0b0edb62d2cbc9ba4c40f706cb678c7d8c768afb666&scene=21#wechat_redirect)

---

>本文作者： catalinaLi
本文链接： http://catalinali.top/2018/helloCAS/



