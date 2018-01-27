---
title: 使用JSONP解决ajax跨域
date: 2018-01-08 16:26:23
tags: jsonp
categories: jsonp
keywords: jsonp
---

![jsonp_logo](http://ou3np1yz4.bkt.clouddn.com/jsonp_logo.jpg)
>在日常开发中，不免遇到跨域的问题。在这里我们介绍使用Jsonp来解决ajax跨域的问题。

<!--more-->
## 什么是跨域?
跨域，指的是浏览器不能执行其他网站的脚本。它是由浏览器的同源策略造成的，是浏览器施加的安全限制。简单的理解就是开发时当客户端所在的工程与服务端的ip不同或者端口不同时进行请求，就产生了跨域，进而不能请求数据。
## 什么是JSONP?
官方的说法是:JSONP(JSON with Padding)是一个非官方的协议，它允许在服务器端集成Script tags返回至客户端，通过javascript callback的形式实现跨域访问（这仅仅是JSONP简单的实现形式）。
我们都知道，JSON是一种数据交换格式。而JSONP是一种的数据调用方式。它利用&lt;script&gt;标签可以跨域的特性，将需要跨域获取的数据包在&lt;script&gt;标签中来达到目的。当我们需要使用JSONP时，客户端调用服务端时传递一个callback，这样服务端根据callback的有无就可以判断是否需要使用JSONP。可以简单的理解为带callback的json就是jsonp。
## JSONP的使用
AJAX的使用与平常无异，只需要将dataType改为jsonp即可
``` javascript
		$.ajax({
			url : url,
			dataType : "jsonp",
			type : "GET",
			success : function(data){
                ...
			}
		});
```
服务端接收到以后，只需要手动判断一下有无callback再手动拼一对括号即可,这里以java为例
``` java
	@ResponseBody
	@RequestMapping(value="xxx")
	public String testJsonp(String callback) {
		Student result = new Student();
		//响应结果之前，判断是否为jsonp请求
		if (StringUtils.isNotBlank(callback)) {
			//把结果封装成一个js语句响应
			return callback + "(" + JsonUtils.objectToJson(result)  + ");";
		}
		return JsonUtils.objectToJson(result);
	}
```
在Spring 4.1以上的版本也可以使用MappingJacksonValue来响应
``` java
	@ResponseBody
	@RequestMapping(value="xxx")
	public Object testJsonp(String callback) {
	    Student result = new Student();
		//响应结果之前，判断是否为jsonp请求
		if (StringUtils.isNotBlank(callback)) {
			//把结果封装成一个js语句响应
			MappingJacksonValue mappingJacksonValue = new MappingJacksonValue(result);
			mappingJacksonValue.setJsonpFunction(callback);
			return mappingJacksonValue;
		}
		return result;
	}
```

怎么样，简单几步就可以跨域来访问服务端了。

---

>本文作者： catalinaLi
本文链接： http://catalinali.top/2018/useJSONP/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。