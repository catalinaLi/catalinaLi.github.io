---
title: Spring中的ApplicationContextAware接口的使用
date: 2017-08-23 14:45:57
tags: Spring
categories: Spring
keywords: [Spring,ApplicationContextAware]
---
![appContext_logo](http://ou3np1yz4.bkt.clouddn.com/appContext_logo.jpg)
>最近在看项目代码时发现一个类在项目各个地方都能进行调用,仔细研究后发现这个类实现了ApplicationContextAware这个接口,这个接口可以很方便的获取到Spring的上下文applicationContext。现在就跟我来一起看看如何使用吧。

---
<!-- more -->
## 使用方法
我们先新建一个测试类AppCache,在这个类中我定义了一个静态的DictService属性。而DictService类我也提前写好了,里面只输出了一句话用作测试。

``` java
/**
 * <pre>
 * Description: 测试ApplicationContextAware接口
 * Copyright:   Copyright (c)2017
 * Author:      lllx
 * Version:     1.0
 * </pre>
 */
@Service
public class DictServiceImpl implements DictService {

    @Override
    public void sayHello() {
        System.out.println("Hello ApplicationContextAware");
    }
}

```

使用测试类AppCache实现这个接口,填写它的setApplicationContext方法。Spring容器在加载的时候会调用一次setApplicationContext,并将上下文ApplicationContext传递给这个方法。我们拿到上下文后就可以做很多事情了。这里我使用它来获取了DictService这个bean。然后创建了一个静态的sayHello测试方法调用了DictService中的sayHello。

``` java
/**
 * <pre>
 * Description: 测试ApplicationContextAware接口
 * Copyright:   Copyright (c)2017
 * Author:      lllx
 * Version:     1.0
 * </pre>
 */

public class AppCache implements ApplicationContextAware {

    private static DictService dictService;

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        dictService = applicationContext.getBean(DictService.class);
    }

    public static void sayHello(){
        dictService.sayHello();
    }
}

```

接下来我们需要把测试类AppCache注入到Spring容器中,在Spring的配置文件中添加测试类的bean。

``` xml
<!--继承ApplicationContextAware接口的类-->
<bean id="appController" class="top.catalinali.controller.AppCache"/>

```

我们新建一个Junit测试类,来调用自己定义的AppCache中的方法sayHello。

``` java
/**
 * <pre>
 * Description: 测试ApplicationContextAware接口
 * Copyright:   Copyright (c)2017
 * Author:      lllx
 * Version:     1.0
 * </pre>
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = "classpath:applicationContext.xml")
public class AppTest {

    @Test
    public void TestApp(){
        AppCache.sayHello();
    }
}

``` 
测试结果

![appContext_1](http://ou3np1yz4.bkt.clouddn.com/appContext_1.png)
可以看到我们成功输出了Hello ApplicationContextAware这句话。用这样的方法,我们就可以在项目的各个位置来调用AppCache中的方法。除此之外我们也可以使用上下文进行一些别的事情,大家就可以自由发挥啦！

## 结语
其实我们进入ApplicationContextAware接口内部可以看到他只有一个抽象的setApplicationContext方法,

```java
public interface ApplicationContextAware extends Aware {
    void setApplicationContext(ApplicationContext var1) throws BeansException;
}

```

并且他又继承了一个Aware接口。而且这个接口是空的

``` java
package org.springframework.beans.factory;

public interface Aware {

}

```

这就很有意思了,具体原因就留给大家来讨论吧。
---

>本文作者： catalinaLi
本文链接： http://catalinali.top/2017/UseApplicationContextAware/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。