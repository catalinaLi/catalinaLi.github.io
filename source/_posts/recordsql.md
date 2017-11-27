---
title: 记录：mysql中的case when|on duplicate key update|重复插入返回主键的用法
date: 2017-09-27 16:17:44
tags: mysql
categories: mysql
keywords: [mysql,Mybatis]
---

![case_logo](http://ou3np1yz4.bkt.clouddn.com/case_logo.jpg)
在平时的开发中不免接触到数据库,这里记录一些平时开发中遇到的细节问题，与大家共勉。

---

<!--more-->
## mysql中的条件控制：case函数
在操作数据库的开发中不免遇到一些类似if else的判断,这时候就用到了Case函数,首先我们用网上用了好多次的例子来看看它的用法:
```sql
case when sex = '1' then '男'  
     when sex = '2' then '女'  
     else '其他' end
```
 利用这个格式我们可以就可以完成类似if else的操作,比如:
 
```sql
SELECT
    SUM(
    case 
    when V.IN_OUT = '2' then -AMOUNT
    when V.IN_OUT = '1' then AMOUNT end) AMOUNT
FROM
    tb_financial
```
怎么样,很简单吧！
## mysql中重复插入时更新
为了防止数据重复插入报错,我们可以让重复插入主键相同的数据时改为更新这条数据。
我们使用mysql官网的例子:
```sql
INSERT INTO t1 (a,b,c) VALUES (1,2,3)
  ON DUPLICATE KEY UPDATE c=c+1;

UPDATE t1 SET c=c+1 WHERE a=1;
```
按照[官网](https://dev.mysql.com/doc/refman/5.5/en/insert-on-duplicate.html)的说法,如果列a被声明为UNIQUE并包含该值 1，则这两个语句具有类似的效果。当列b也是唯一的时候,则相当于下面这条sql:
```sql
UPDATE t1 SET c=c+1 WHERE a=1 OR b=2 LIMIT 1;
```
但是,并不建议ON DUPLICATE KEY UPDATE在具有**多个唯一索引**的表上使用。
## MyBatis+MySQL 返回插入的主键ID
在使用Mybatis想返回插入的主键ID也很简单,只需要在insert的Mapper中添加useGeneratedKeys="true"和keyProperty="实体中主键属性名"两个属性:
```sql
<insert id="InsertTBFinancial" useGeneratedKeys="true" keyProperty="id">
		INSERT INTO Tb_financial
			(id,
			 amount,
			 comment)
		VALUES
			(#{id},
			 #{amount},
			 #{comment})
  	</insert>
```
这样在调用此方法后实体中的主键值就会自动返回:
```java
Financial Financial = new Financial();  
Financial.setId("chenzhou");  
Financial.setAmount("xxxx");  
Financial.setComment("测试插入数据返回主键功能");  
  
System.out.println("插入前主键为："+user.getId());  
userDao.insertAndGetId(user);//插入操作  
System.out.println("插入后主键为："+user.getId());  
```
---
>本文作者： catalinaLi
本文链接： http://catalinali.top/2017/recordsql/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。