---
title: 微信开发之微信网页授权获取openid
date: 2018-02-26 16:21:09
tags: wechat
categories: wechat
keywords: wechat OAuth
---
![wechatOAuth_logo](http://ou3np1yz4.bkt.clouddn.com/wechatOAuth_logo.jpg)

>不知觉间已经接触了几次微信支付开发，而要进行微信支付就需要用户的唯一标识:openid。还记得第一次获取用户openid的时候就踩了很多坑。这两天又接触了一下，想着索性就把他记录下来，也便于以后查阅

<!--more-->

## 一、准备工具
不管开发什么，官方的文档应该是第一个想到的这里把官方文档贴出来：**[微信网页授权文档](https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140842)**
除此之外，我们还需要一个**内网穿透**的工具在开发环境下让微信能访问到我们的域名。我使用的是natapp。此类工具网上有很多，大家可以自行寻找。
这里我们使用微信提供的**[测试账号](https://mp.weixin.qq.com/debug/cgi-bin/sandbox?t=sandbox/login)**来作为演示
## 二、开始开发
内网穿透就不在这里演示了，下面我们直入主题：
**1.填写网页授权域名**
在这篇文档的一开始就埋了一个坑
![wechatOAuth_1](http://ou3np1yz4.bkt.clouddn.com/wechatOAuth_1.png)
这段话就是说，我们在开发前需要在图片中框红的位置填入我们所要开发的域名。这里我们使用的是测试环境，所以需要在测试账号管理页面的这个位置填入我们自己的域名,这里要注意填入域名的规则。
![wechatOAuth_2](http://ou3np1yz4.bkt.clouddn.com/wechatOAuth_2.png)
**2.文档阅读**
接着阅读文档我们可以发现网页授权有两种scope,
snsapi_base和snsapi_userinfo。两种scope都可以获取到opeid，不同的是snsapi_userinfo除了openid外还可以获取到用户的基本信息，但是需要用户手动进行确认。
再往下阅读我们可以看到官方文档的授权步骤

- 第一步：用户同意授权，获取code
- 第二步：通过code换取网页授权access_token以及openid
- 第三步：刷新access_token（如果需要）
- 第四步：拉取用户信息(需scope为 snsapi_userinfo)

我们只需要openid，所以我们只开发到第二步就好了。下面我们就按着官方步骤来开发。

**3.获取code**
查看文档后我们发现我们需要拼接一个url并且访问它。url的参数文档中写的很清楚了。看他的例子也能看个清楚。这里比较重要的是redirect_uri。这个参数所填的是一个链接。我们访问url后会自动转发到这个链接并且将我们需要的code以及拼接url中的state的值作为参数。这个redirect_uri的值要填入的是我们代码中的controller的位置。
所以这里我们需要一段代码：
``` java
/**
 * <pre>
 * Description: wechat OAuth2.0
 * Author:		lllx
 * Version:		1.0
 * Created at:	2018/2/1
 * </pre>
 */
@RestController
@RequestMapping("/weixin")
@Slf4j
public class WeixinController {

    @GetMapping("/auth")
    public void auth(@RequestParam("code") String code,@RequestParam("state") String state){
        log.info("auth开始了。。。。");
        log.info("code={}",code);
        log.info("state={}",state);
    }
}

```
我拼接的url，这里大家要注意根据自己的情况进行拼接。拼接成功后需要在**微信app**中进行访问
```
https://open.weixin.qq.com/connect/oauth2/authorize?appid=xxx&redirect_uri=http://xxx/sell/weixin/auth&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect
```
访问后的结果
![wechatOAuth_3](http://ou3np1yz4.bkt.clouddn.com/wechatOAuth_3.png)
这样我们就拿到了code
**4.获取openid**
继续查看文档，发现我们只需要使用获取到的code再访问另一个url就可以获取到我们想要的了。接着上面的代码
``` java
/**
 * <pre>
 * Description: wechat OAuth2.0
 * Author:		lllx
 * Version:		1.0
 * Created at:	2018/2/1
 * </pre>
 */
@RestController
@RequestMapping("/weixin")
@Slf4j
public class WeixinController {

    @GetMapping("/auth")
    public void auth(@RequestParam("code") String code,@RequestParam("state") String state){
        log.info("auth开始了。。。。");
        log.info("code={}",code);
        log.info("state={}",state);
        String url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=xxxx&secret=xxxx&code="+code+"&grant_type=authorization_code";
        RestTemplate restTemplate = new RestTemplate();
        String result = restTemplate.getForObject(url, String.class);
        log.info("result={}",result);
    }
}
```
这时我们再次访问第三步拼接的url就可以看到如下结果。
![wechatOAuth_4](http://ou3np1yz4.bkt.clouddn.com/wechatOAuth_4.png)
将结果格式化一下我们可以就看到我们想要的openid
![wechatOAuth_5](http://ou3np1yz4.bkt.clouddn.com/wechatOAuth_5.png)

## 三、总结
流程看起来还是很简单的。但以上只是一个最简单、最直接的手工获取openid的例子。真正在使用过程中需要结合自身的业务流程来进行开发，这时可能就有些麻烦了。此时我们也可以借助一些网上第三方sdk来开发。例如:weixin-java-tools。

---
>本文作者： catalinaLi
本文链接： http://catalinali.top/2018/wechatOAuth/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。
