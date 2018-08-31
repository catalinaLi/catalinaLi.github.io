---
title: JAVA并发编程(六)：线程本地变量ThreadLocal与TransmittableThreadLocal
date: 2018-08-28 09:44:53
tags: juc
categories: juc
keywords: juc
---

![volatile_logo](http://ou3np1yz4.bkt.clouddn.com/ThreadLocal_logo.jpg)
>我们知道有时候一个对象的共享变量会被多个线程所访问，这时就会有线程安全问题。当然我们可以使用synchorinized 关键字来为此变量加锁，进行同步处理。从而限制只能有一个线程来使用此变量，但是加锁会大大影响程序执行效率，此外我们还可以使用ThreadLocal来解决对某一个变量的访问冲突问题。

<!--more-->

## 一、ThreadLocal 概述
当使用ThreadLocal维护变量的时候 它为每一个使用该变量的线程提供一个独立的变量副本，即每个线程内部都会有一个该变量，这样同时多个线程访问该变量并不会彼此相互影响，因此他们使用的都是自己从内存中拷贝过来的变量的副本， 这样就不存在线程安全问题，也不会影响程序的执行性能。
ThreadLocal 的几个方法： ThreadLocal 可以存储任何类型的变量对象， get返回的是一个Object对象，但是我们可以通过泛型来制定存储对象的类型。
```
public T get() { } // 用来获取ThreadLocal在当前线程中保存的变量副本
public void set(T value) { } //set()用来设置当前线程中变量的副本
public void remove() { } //remove()用来移除当前线程中变量的副本
protected T initialValue() { } //initialValue()是一个protected方法，一般是用来在使用时进行重写的
```
Thread 在内部是通过ThreadLocalMap来维护ThreadLocal变量表， 在Thread类中有一个threadLocals 变量，是ThreadLocalMap类型的，它就是为每一个线程来存储自身的ThreadLocal变量的， ThreadLocalMap是ThreadLocal类的一个内部类，这个Map里面的最小的存储单位是一个Entry， 它使用ThreadLocal作为key， 变量作为 value，这是因为在每一个线程里面，可能存在着多个ThreadLocal变量

初始时，在Thread里面，threadLocals为空，当通过ThreadLocal变量调用get()方法或者set()方法，就会对Thread类中的threadLocals进行初始化，并且以当前ThreadLocal变量为键值，以ThreadLocal要保存的副本变量为value，存到threadLocals。 
然后在当前线程里面，如果要使用副本变量，就可以通过get方法在threadLocals里面查找
我们来看一个使用示例：
```
public class Test {
    ThreadLocal<Long> longLocal = new ThreadLocal<Long>();
    ThreadLocal<String> stringLocal = new ThreadLocal<String>();
 
     
    public void set() {
        longLocal.set(Thread.currentThread().getId());
        stringLocal.set(Thread.currentThread().getName());
    }
     
    public long getLong() {
        return longLocal.get();
    }
     
    public String getString() {
        return stringLocal.get();
    }
     
    public static void main(String[] args) throws InterruptedException {
        final Test test = new Test();
         
         
        test.set();
        System.out.println(test.getLong());
        System.out.println(test.getString());
     
         
        Thread thread1 = new Thread(){
            public void run() {
                test.set();
                System.out.println(test.getLong());
                System.out.println(test.getString());
            };
        };
        thread1.start();
        thread1.join();
         
        System.out.println(test.getLong());
        System.out.println(test.getString());
    }
}
```
输出结果为
```
1 
main 
9 
Thread-0 
1 
main
```

## 二、父子线程传递InheritableThreadLocal

以上方案在父子线程中就有了局限性，如果子线程想要拿到父线程的中的ThreadLocal值怎么办呢？比如会有以下的这种代码的实现。由于ThreadLocal的实现机制,在子线程中get时,我们拿到的Thread对象是当前子线程对象,那么他的ThreadLocalMap是null的,所以我们得到的value也是null。
```
final ThreadLocal threadLocal=new ThreadLocal(){
            @Override
            protected Object initialValue() {
                return "xiezhaodong";
            }
        };
 new Thread(new Runnable() {
            @Override
            public void run() {
                threadLocal.get();//NULL
            }
        }).start();
```
JDK已经为这种情况提供了实现方案:InheritableThreadLocal。大致的解释了一下InheritableThreadLocal为什么能解决父子线程传递Threadlcoal值的问题。
1）在创建InheritableThreadLocal对象的时候赋值给线程的t.inheritableThreadLocals变量
2）在创建新线程的时候会check父线程中t.inheritableThreadLocals变量是否为null，如果不为null则copy一份ThradLocalMap到子线程的t.inheritableThreadLocals成员变量中去
3）因为复写了getMap(Thread)和CreateMap()方法,所以get值得时候，就可以在getMap(t)的时候就会从t.inheritableThreadLocals中拿到map对象，从而实现了可以拿到父线程ThreadLocal中的值

所以,在最开始的代码示例中，如果把ThreadLocal对象换成InheritableThreadLocal对象，那么get到的字符会是“xiezhaodong”而不是NULL

## 二、线程池传递TransmittableThreadLocal
我们在使用线程的时候往往不会只是简单的new Thrad对象，而是使用线程池，当然线程池的好处多多。这里不详解，既然这里提出了问题，那么线程池会给InheritableThreadLocal带来什么问题呢？我们列举一下线程池的特点：

1）为了减小创建线程的开销，线程池会缓存已经使用过的线程
2）生命周期统一管理,合理的分配系统资源

对于第一点，如果一个子线程已经使用过，并且会set新的值到ThreadLocal中，那么第二个task提交进来的时候还能获得父线程中的值吗？答案是不能，如果我们能够，在使用完这个线程的时候清除所有的localMap，在submit新任务的时候在重新重父线程中copy所有的Entry。然后重新给当前线程的t.inhertableThreadLocal赋值。这样就能够解决在线程池中每一个新的任务都能够获得父线程中ThreadLocal中的值而不受其他任务的影响，因为在生命周期完成的时候会自动clear所有的数据。Alibaba的一个库解决了这个问题[github:alibaba/transmittable-thread-local](https://github.com/alibaba/transmittable-thread-local)
**如何使用**
这个库最简单的方式是这样使用的,通过简单的修饰，使得提交的runable拥有了上一节所述的功能。具体的API文档详见github，这里不再赘述
```
TransmittableThreadLocal<String> parent = new TransmittableThreadLocal<String>();
parent.set("value-set-in-parent");

Runnable task = new Task("1");
// 额外的处理，生成修饰了的对象ttlRunnable
Runnable ttlRunnable = TtlRunnable.get(task); 
executorService.submit(ttlRunnable);

// Task中可以读取, 值是"value-set-in-parent"
String value = parent.get();
```
**原理简述**
这个方法TtlRunnable.get(task)最终会调用构造方法，返回的是该类本身，也是一个Runable,这样就完成了简单的装饰。最重要的是在run方法这个地方。
```
public final class TtlRunnable implements Runnable {
    private final AtomicReference<Map<TransmittableThreadLocal<?>, Object>> copiedRef;
    private final Runnable runnable;
    private final boolean releaseTtlValueReferenceAfterRun;

    private TtlRunnable(Runnable runnable, boolean releaseTtlValueReferenceAfterRun) {
    //从父类copy值到本类当中
        this.copiedRef = new AtomicReference<Map<TransmittableThreadLocal<?>, Object>>(TransmittableThreadLocal.copy());
        this.runnable = runnable;//提交的runable,被修饰对象
        this.releaseTtlValueReferenceAfterRun = releaseTtlValueReferenceAfterRun;
    }
    /**
     * wrap method {@link Runnable#run()}.
     */
    @Override
    public void run() {
        Map<TransmittableThreadLocal<?>, Object> copied = copiedRef.get();
        if (copied == null || releaseTtlValueReferenceAfterRun && !copiedRef.compareAndSet(copied, null)) {
            throw new IllegalStateException("TTL value reference is released after run!");
        }
        //装载到当前线程
        Map<TransmittableThreadLocal<?>, Object> backup = TransmittableThreadLocal.backupAndSetToCopied(copied);
        try {
            runnable.run();//执行提交的task
        } finally {
        //clear
            TransmittableThreadLocal.restoreBackup(backup);
        }
    }
}
```
在上面的使用线程池的例子当中，如果换成这种修饰的方式进行操作，B任务得到的肯定是父线程中ThreadLocal的值，解决了在线程池中InheritableThreadLocal不能解决的问题。
**如何更新父线程ThreadLocal值？**
如果线程之间出了要能够得到父线程中的值，同时想更新值怎么办呢？在前面我们有提到，当子线程copy父线程的ThreadLocalMap的时候是浅拷贝的,代表子线程Entry里面的value都是指向的同一个引用，我们只要修改这个引用的同时就能够修改父线程当中的值了,比如这样:
```
@Override
          public void run() {
              System.out.println("========");
              Span span=  inheritableThreadLocal.get();
              System.out.println(span);
              span.name="liuliuliu";//修改父引用为liuliuliu
              inheritableThreadLocal.set(new Span("zhangzhangzhang"));
              System.out.println(inheritableThreadLocal.get());
          }
```
这样父线程中的值就会得到更新了。能够满足父线程ThreadLocal值的实时更新，同时子线程也能共享父线程的值。不过场景倒是不是很常见的样子。

## 参考文章

- [Java并发编程：深入剖析ThreadLocal](https://www.cnblogs.com/dolphin0520/p/3920407.html)
- [ThreadLocal父子线程传递实现方案](https://blog.csdn.net/a837199685/article/details/52712547)

---

>本文作者： catalinaLi
本文链接： http://catalinali.top/2018/helloThreadLocal/



