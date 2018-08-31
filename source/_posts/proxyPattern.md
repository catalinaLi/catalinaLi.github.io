---
title: （转载）Java设计模式之代理模式
date: 2018-08-29 11:22:19
tags: design-patterns
categories: design-patterns
keywords: design-patterns
---
![volatile_logo](http://ou3np1yz4.bkt.clouddn.com/proxyPattern_logo.jpg)
>设计模式是语言的表达方式，它能让语言轻便而富有内涵、易读却功能强大。代理模式在Java中十分常见，有为扩展某些类的功能而使用静态代理，也有如Spring实现AOP而使用动态代理，更有RPC实现中使用的调用端调用的代理服务。代理模型除了是一种设计模式之外，它更是一种思维，所以探讨并深入理解这种模型是非常有必要的。

<!--more-->
本文转载自

- [Java的三种代理模式](https://www.cnblogs.com/cenyu/p/6289209.html)
- [浅析JAVA设计模式之代理模式(七)](https://blog.csdn.net/minidrupal/article/details/28588507)
    
   代理(Proxy)是一种设计模式,提供了对目标对象另外的访问方式;即通过代理对象访问目标对象.这样做的好处是:可以在目标对象实现的基础上,增强额外的功能操作,即扩展目标对象的功能.这里使用到编程中的一个思想:不要随意去修改别人已经写好的代码或者方法,如果需改修改,可以通过代理的方式来扩展该方法。

   代理模式的关键点是:代理对象与目标对象.代理对象是对目标对象的扩展,并会调用目标对象
   
   代理的实现可以分为静态代理和动态代理，动态代理又分为JDK动态代理和CGlib动态代理，下面我们依次来说明一下这三种方式：
    
## 一、静态代理
静态代理在使用时,需要定义接口或者父类,被代理对象与代理对象一起实现相同的接口或者是继承相同父类.

下面举个案例来解释:
模拟保存动作,定义一个保存动作的接口:IUserDao.java,然后目标对象实现这个接口的方法UserDao.java,此时如果使用静态代理方式,就需要在代理对象(UserDaoProxy.java)中也实现IUserDao接口.调用的时候通过调用代理对象的方法来调用目标对象.
需要注意的是,代理对象与目标对象要实现相同的接口,然后通过调用相同的方法来调用目标对象的方法.
代码示例:
接口:IUserDao.java
```
/**
 * 接口
 */
public interface IUserDao {

    void save();
}
```
目标对象:UserDao.java
```
/**
 * 接口实现
 * 目标对象
 */
public class UserDao implements IUserDao {
    public void save() {
        System.out.println("----已经保存数据!----");
    }
}
```
代理对象:UserDaoProxy.java
```
/**
 * 代理对象,静态代理
 */
public class UserDaoProxy implements IUserDao{
    //接收保存目标对象
    private IUserDao target;
    public UserDaoProxy(IUserDao target){
        this.target=target;
    }

    public void save() {
        System.out.println("开始事务...");
        target.save();//执行目标对象的方法
        System.out.println("提交事务...");
    }
}
```
测试类:App.java
```
/**
 * 测试类
 */
public class App {
    public static void main(String[] args) {
        //目标对象
        UserDao target = new UserDao();

        //代理对象,把目标对象传给代理对象,建立代理关系
        UserDaoProxy proxy = new UserDaoProxy(target);

        proxy.save();//执行的是代理的方法
    }
}
```
静态代理总结:
1.可以做到在不修改目标对象的功能前提下,对目标功能扩展.
2.缺点:
因为代理对象需要与目标对象实现一样的接口,所以会有很多代理类,类太多.同时,一旦接口增加方法,目标对象与代理对象都要维护.

如何解决静态代理中的缺点呢?答案是可以使用动态代理方式.
## 二、JDK动态代理
动态代理有以下特点:
1.代理对象,不需要实现接口
2.代理对象的生成,是利用JDK的API,动态的在内存中构建代理对象(需要我们指定创建代理对象/目标对象实现的接口的类型)
3.动态代理也叫做:JDK代理,接口代理

JDK中生成代理对象的API
代理类所在包:java.lang.reflect.Proxy
JDK实现代理只需要使用newProxyInstance方法,但是该方法需要接收三个参数,完整的写法是:
```
static Object newProxyInstance(ClassLoader loader, Class<?>[] interfaces,InvocationHandler h )
```
注意该方法是在Proxy类中是静态方法,且接收的三个参数依次为:

- ClassLoader loader,:指定当前目标对象使用类加载器,获取加载器的方法是固定的
- Class<?>[] interfaces,:目标对象实现的接口的类型,使用泛型方式确认类型
- InvocationHandler h:事件处理,执行目标对象的方法时,会触发事件处理器的方法,会把当前执行目标对象的方法作为参数传入
代码示例:
接口类IUserDao.java以及接口实现类,目标对象UserDao是一样的,没有做修改.在这个基础上,增加一个代理工厂类(ProxyFactory.java),将代理类写在这个地方,然后在测试类(需要使用到代理的代码)中先建立目标对象和代理对象的联系,然后代用代理对象的中同名方法

代理工厂类:ProxyFactory.java

```
/**
 * 创建动态代理对象
 * 动态代理不需要实现接口,但是需要指定接口类型
 */
public class ProxyFactory{

    //维护一个目标对象
    private Object target;
    public ProxyFactory(Object target){
        this.target=target;
    }

   //给目标对象生成代理对象
    public Object getProxyInstance(){
        return Proxy.newProxyInstance(
                target.getClass().getClassLoader(),
                target.getClass().getInterfaces(),
                new InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                        System.out.println("开始事务2");
                        //执行目标对象方法
                        Object returnValue = method.invoke(target, args);
                        System.out.println("提交事务2");
                        return returnValue;
                    }
                }
        );
    }

}
```
测试类:App.java

```
/**
 * 测试类
 */
public class App {
    public static void main(String[] args) {
        // 目标对象
        IUserDao target = new UserDao();
        // 【原始的类型 class cn.itcast.b_dynamic.UserDao】
        System.out.println(target.getClass());

        // 给目标对象，创建代理对象
        IUserDao proxy = (IUserDao) new ProxyFactory(target).getProxyInstance();
        // class $Proxy0   内存中动态生成的代理对象
        System.out.println(proxy.getClass());

        // 执行方法   【代理对象】
        proxy.save();
    }
}
```
总结:
代理对象不需要实现接口,但是目标对象一定要实现接口,否则不能用动态代理

## 二、CGLIB代理
### CGLIB概述
上面的静态代理和动态代理模式都是要求目标对象是实现一个接口的目标对象,但是有时候目标对象只是一个单独的对象,并没有实现任何的接口,这个时候就可以使用以目标对象子类的方式类实现代理,这种方法就叫做:Cglib代理

CGLIB也提供了一个处理器接口（这里成为回调接口）net.sf.cglib.proxy.MethodInterceptor（相当于JDK代理的InvocationHandler接口），它自定义了一个intercept方法（相当于JDK代理的invoke方法），用于集中处理在动态代理类对象上的方法调用，通常在该方法中实现对委托类的代理访问。
``` java
        // 该方法负责集中处理动态代理类上的所有方法调用。第一个参数是代理类对象，第二个参数是委托类被调用的方法的类对象
       // 第三个是该方法的参数，第四个是生成在代理类里面，除了方法名不同，其他都和被代理方法一样的（参数，方法体里面的东西）一个方法的类对象。
       public Object intercept(Object proxy, Method method, Object[] args, MethodProxy methodproxy) throws Throwable
```
然后CGLIB也提供了一个生成代理类的类net.sf.cglib.proxy.Enhancer（相当于JDK代理的java.lang.reflect.Proxy），它提供了一组静态方法来为一组接口动态地生成代理类及其对象。本文创建代理用到的Enhancer的静态方法如下：
```
public Object intercept(Object proxy,Method method, Object[] args,  MethodProxy methodproxy) throws Throwable
       //为指定类装载器、接口及调用处理器生成动态代理类实例
       public static  Object create(Class class ,Callback callback h){}
       public static  Object create(Class class,Class[] interfaces,Callback h){}
       public static Object create(Classclass, Class[] interfaces, CallbackFilter filter, Callback[] hs)
       public Object create(Class[] argumentTypes, Object[] arguments){}
```
 这个create方法相当于JDK代理的newProxyInstance方法，该方法的参数具体含义如下：
 
- Class class：指定一个被代理类的类对象。
- Class[]interfaces：如果要代理接口，指定一组被代理类实现的所有接口的类对象。
- Callback h：指定一个实现了处理器接口（这里称回调接口）的对象。
- CallbackFilter filter：指定一个方法过滤器。
- Callback[]hs：指定一组实现了处理器接口的对象。
- Class[] argumentTypes：指定某个构造器的参数类型
- Object[] arguments：指定某个gouz

### 如何使用？
   1.  通过实现 MethodInterceptor接口创建自己的处理器；
   2.  通过给Enhancer类的create()方法传进被代理类的类对象、实现了MethodInterceptor接口的处理器对象，得到一个代理类对   象。
   3.  其中Enhancer类通过反射机制获得代理类的构造函数，有一个参数类型是处理器接口类型。
   4.  Enhancer类再通过构造函数对象创建动态代理类实例，构造时处理器对象作为参数被传入。
   5.  当客户端调用了代理类的方法时，该方法调用了处理器的intercept()方法并给intercept()方法传进委托类方法的类对象，intercept方法再调用委托类的真实方法。
  (1)建一个reallyCglibProxy包，所有程序都放在该包下，我在Spring的包库里面找到两个包：asm.jar和cblib-2.1.3.jar，最好在Spring里面同时拷贝这两个包到项目的类库下，不要分别从网上下载，可能会冲突。
  (2)建一个被代理类（RealSubject.java）。
```
package reallyCglibProxy;
//被代理类
public class RealSubject {
	public void print() {
		System.out.println("被代理的人郭襄");
	}
}
```
  （3）建一个用户自定义的处理器类LogHandler.java，需要实现处理接口，在intercept（）方法里写上被代理类的方法调用前后要进行的动作。这个intercept（）方法我们不用直接调用，是让将来自动生成的代理类去调用的。
```
package reallyCglibProxy;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import jdkDynamicProxy.LonHanderReflectTool;
import net.sf.cglib.proxy.Enhancer;
import net.sf.cglib.proxy.MethodInterceptor;
import net.sf.cglib.proxy.MethodProxy;
 
//相当于实现jdk的InvocationHandler接口
public class LogHandler implements MethodInterceptor{
	private Object delegate; //被代理类的对象
	//绑定被代理类的对象
	public Object bind(Object delegate)throws Exception{
		this.delegate=delegate;
	return Enhancer.create(delegate.getClass(),this);
	}  
	//相当于InvocationHandler接口里面的invoke()方法
	@Override
	public Object intercept(Object proxy, Method method, Object[] args,
			MethodProxy methodproxy) throws Throwable {
		Object result=null;
		System.out.println("我是代理人郭靖，开始代理");
		
		//method.invoke()或者methodproxy.invoke()都可以
		result=method.invoke(delegate,args);
		//result=methodproxy.invoke(delegate,args);
		System.out.println("我是代理人郭靖，代理完毕");
 
		//调用工具类反射jdk的Proxy生成的代理类，可参考《五》中这个工具类
		LonHanderReflectTool.ReflectClass(proxy.getClass().getName());
		return result;
	}
}

```
(4)编写测试客户端（TestReallyCglibProxy.java）。
```
package reallyCglibProxy;
public class TestReallyCglibProxy {
	public static void main(String[] args)throws Exception {
		RealSubject sub1=new RealSubject();
		LogHandler hander=new LogHandler();
		RealSubject sub2=(RealSubject)hander.bind(sub1);
		sub2.print();
	}
}

```
输出结果：
```
我是代理人郭靖，开始代理

被代理的人郭襄

我是代理人郭靖，代理完毕
```
从结果可以看出，成功自动生成了代理类RealSubject$$EnhancerByCGLIB$$48574fb2，并成功实现了代理的效果，而且还代理了RealSubject类从父类继承的finalize、equals、toString、hashCode、clone这几个方法。

### CBLIB方法过滤器
如果现在有个要求，被代理类的print方法不用处理。当最简单的方式是修改方法拦截器（即intercept方法），在里面进行判断，如果是print()方法就不做任何逻辑处理，直接调用，这样子使得编写拦截器（相当于JDK代理里的处理器）逻辑变复杂，不易维护。我们可以使用CGLIB提供的方法过滤器（CallbackFilter），使得被代理类中不同的方法，根据我们的逻辑要求，调用不同的处理器，从而使用不同的拦截方法（处理器方法）。
基本步骤如下:
（1）修改一下被代理类（RealSubject.java），增加一个方法print2。
```
package reallyCglibProxy;
//被代理类
public class RealSubject {
	public void print() {
		System.out.println("被代理的人郭襄");
	}
	public void print2() {
		System.out.println("我是print2方法哦");
	}
}
```
（2）新建一个用户自定义的方法过滤器类MyProxyFilter.java。
```
package reallyCglibProxy;
 
import java.lang.reflect.Method;
 
import net.sf.cglib.proxy.Callback;
 
import net.sf.cglib.proxy.CallbackFilter;
 
import net.sf.cglib.proxy.NoOp;
 
//自定义方法过滤器类
 
public class MyProxyFilterimplements CallbackFilter {
 
    public int accept(Method method) {
 
    /**
    *这句话可发现，所有被代理的方法都会被过滤一次。Enhancer的源代码中看到下面一段代码
    while(it1.hasNext()){
    MethodInfomethod=(MethodInfo)it1.next();
    MethodactualMethod=(it2!=null)?(Method)it2.next():null;
    intindex=filter.accept(actualMethod);
    if(index>=callbackTypes.length){
    thrownewIllegalArgumentException("Callbackfilterreturnedanindexthatistoolarge:"+index);
    }
    上段代码可以看到所有的被代理的方法，本例子中就是print、print2、从父类继承的finalize、equals、toString、
    hashCode、clone这几个方法）都被调用accept方法进行过滤，给每个方法返回一个整数，
    本例子是0或者1，从而选择不同的处理器。
    */
 
System.out.println(method.getDeclaringClass()+"类的"+method.getName()+"方法被检查过滤！");
 
    /* 
    如果调用是print方法，则要调用0号位的拦截器去处理
         */
 
    if("print".equals(method.getName()))   
 
    //0号位即LogHandler里面 new Callback[]{this,NoOp.INSTANCE}中的this，它在这个数组第0位置
 
return 1; 
 
    /*     
      1号位即LogHandler里面 new Callback[]{this,NoOp.INSTANCE}中的NoOp.INSTANCE，它在这个数组第1位置。
    NoOp.INSTANCE是指不做任何事情的拦截器。
在这里就是任何人都有权限访问print方法，即这个方法没有代理，直接调用
     */
 
return 0;   
 
    }
 
}
```
（3）修改一下用户自定义的处理器类LogHandler.java
```
package reallyCglibProxy;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import jdkDynamicProxy.LonHanderReflectTool;
import net.sf.cglib.proxy.Callback;
import net.sf.cglib.proxy.Enhancer;
import net.sf.cglib.proxy.MethodInterceptor;
import net.sf.cglib.proxy.MethodProxy;
import net.sf.cglib.proxy.NoOp;
//相当于实现jdk的InvocationHandler接口
public class LogHandler implements MethodInterceptor{
	private Object delegate; //被代理类的对象
	//绑定被代理类的对象
	public Object bind(Object delegate)throws Exception{
		this.delegate=delegate;
	/**
	 *传进不同的拦截器（相当于JDK代理里面的处理器）,NoOp.INSTANCE是cglib已经写好的不做任何事情的拦截器，传进去的new Callback[]是一个数组，现在数组有两个拦截器对象，分别是this,和NoOp.INSTANCE，它们分别在数组的第0位和第一位对应着自定义过滤器MyProxyFilter里的accept方法返回的整数，如果是0就调用this拦截器，如果是1就调用NoOp.INSTANCE所以自定义过滤器MyProxyFilter里的accept方法返回的整数最大就是拦截器数组的长度，比如本例子当中，只能是0或者1，不能是2，因为这个数组只有两个元素，最大位置就是1号位。
	 */
	return Enhancer.create(delegate.getClass(), null, new MyProxyFilter(), new Callback[]{this,NoOp.INSTANCE});	
	}  
	//相当于InvocationHandler接口里面的invoke()方法
	
	public Object intercept(Object proxy, Method method, Object[] args,
			MethodProxy methodproxy) throws Throwable {
		Object result=null;
		System.out.println("我是代理人郭靖，开始代理");
		
		//method.invoke()或者methodproxy.invoke()都可以
		result=method.invoke(delegate,args);
		//result=methodproxy.invoke(delegate,args);
		System.out.println("我是代理人郭靖，代理完毕");
 
		//调用工具类反射jdk的Proxy生成的代理类，可参考《五》中这个工具类
		//LonHanderReflectTool.ReflectClass(proxy.getClass().getName());
		return result;
	}
}
```
(4) 修改测试客户端（TestReallyCglibProxy.java）。
```
package reallyCglibProxy;
publicclass TestReallyCglibProxy {
	publicstaticvoid main(String[] args)throws Exception {
		RealSubject sub1=new RealSubject();
		LogHandler hander=new LogHandler();
		RealSubject sub2=(RealSubject)hander.bind(sub1);
		sub2.print();
        sub2.print2();
	}
}
```
输出结果：
```
class reallyCglibProxy.RealSubject类的print2方法被检查过滤！

class reallyCglibProxy.RealSubject类的print方法被检查过滤！

class java.lang.Object类的finalize方法被检查过滤！

class java.lang.Object类的equals方法被检查过滤！

class java.lang.Object类的toString方法被检查过滤！

class java.lang.Object类的hashCode方法被检查过滤！

class java.lang.Object类的clone方法被检查过滤！

被代理的人郭襄

我是代理人郭靖，开始代理

我是print2方法哦

我是代理人郭靖，代理完毕
```

   从结果可以看出，print方法没有被代理，print2方法被代理了，有了方法过滤器，被代理类被代理的方法（本文例子中就是print、print2、从父类继承的finalize、equals、toString、hashCode、clone这几个方法）都被调用accept方法进行过滤，给每个方法返回一个整数，本例子是0或者1，从而选择不同的处理器。

  

## 参考文章

- [Java的三种代理模式](https://www.cnblogs.com/cenyu/p/6289209.html)
- [浅析JAVA设计模式之代理模式(七)](https://blog.csdn.net/minidrupal/article/details/28588507)

---

>本文作者： catalinaLi
本文链接： http://catalinali.top/2018/proxyPattern/







