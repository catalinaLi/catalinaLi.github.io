---
title: 详解jdbcTemplate和namedParameterJdbcTemplate
date: 2017-08-24 17:41:55
tags: [jdbcTemplate,namedParameterJdbcTemplate]
categories: jdbcTemplate
keywords: [jdbcTemplate,namedParameterJdbcTemplate,jdbc]
---
![jdbcTemplate_logo](http://ou3np1yz4.bkt.clouddn.com/jdbcTemplate_logo.jpg)
>我们开发DAO层时用的最多的就是ORM框架(Mybatis,hibernate)了。在有些特殊的情况下,ORM框架的搭建略显笨重,这时最好的选择就是Spring中的jdbcTemplate了。本文对jdbcTemplate进行详解，并且会对具名参数namedParameterJdbcTemplate进行讲解。

---
<!--more -->
# jdbcTemplate讲解

### jdbcTemplate提供的主要方法:
- execute方法：可以用于执行任何SQL语句，一般用于执行DDL语句；
- update方法及batchUpdate方法：update方法用于执行新增、修改、删除等语句；batchUpdate方法用于执行批处理相关语句；
- query方法及queryForXXX方法：用于执行查询相关语句；
- call方法：用于执行存储过程、函数相关语句。

### jdbcTemplate环境搭建:
1 在spring配置文件中加上jdbcTemplate的bean:
``` xml
	<!--注入jdbcTemplate-->
	<bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
		<property name="dataSource" ref="dataSource"/>
	</bean>
```
注意:在这之前我们需要先配置好数据库数据源dateSource。
2.在使用jdbcTemplate类中使用@Autowired进行注入
```java
    @Autowired
    private JdbcTemplate jdbcTemplate;
```
### jdbcTemplate方法测试:
我们准备一个数据库
![jdbcTemplate_1](http://ou3np1yz4.bkt.clouddn.com/jdbcTemplate_1.png)
准备数据库对应的实体pojo,实体的名称都要对应数据库的字段名称：
``` java
public class User {

  private Long id;
  private String username;
  private String password;

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public String getUsername() {
    return username;
  }

  public void setUsername(String username) {
    this.username = username;
  }

  public String getPassword() {
    return password;
  }

  public void setPassword(String password) {
    this.password = password;
  }

  @Override
  public String toString() {
    return "User{" +
            "id=" + id +
            ", username='" + username + '\'' +
            ", password='" + password + '\'' +
            '}';
  }
}
```
**1.查询单个对象queryForObject:**
``` java
    @Test
    public void testQuery(){
        String sql = "select id,username,password from user where id=?";

        BeanPropertyRowMapper<User> rowMapper = new BeanPropertyRowMapper<User>(User.class);
        User user = jdbcTemplate.queryForObject(sql, rowMapper,1);
        System.out.println(user);
    }
```
输出结果: User{id=1, username='123', password='123'}
**2.查询多个对象query:**
``` java
    @Test
    public void testMutiQuery(){
        String sql = "select id,username,password from user";

        BeanPropertyRowMapper<User> rowMapper = new BeanPropertyRowMapper<User>(User.class);
        List<User> users = jdbcTemplate.query(sql, rowMapper);
        for (User user : users) {
            System.out.println(user);
        }
    }
```
输出结果: 
User{id=1, username='123', password='123'}
User{id=2, username='1234', password='1234'}
**3.查询count、avg、sum等函数返回唯一值:**
``` java
    @Test
    public void testCountQuery(){
        String sql = "select count(*) from user";

        BeanPropertyRowMapper<User> rowMapper = new BeanPropertyRowMapper<User>(User.class);
        Integer result = jdbcTemplate.queryForObject(sql, Integer.class);
        System.out.println(result);
    }
```
输出结果:2
**4.增删改方法测试:**
**新增:**
```
    @Test
    public void testCreate(){
        String sql = "insert into user (username,password) values (?,?)";
        int create = jdbcTemplate.update(sql, new Object[]{255, 255});
        System.out.println(create);
    }
```
输出结果为1,去数据库查看也确实插入这条。
![jdbcTemplate_2](http://ou3np1yz4.bkt.clouddn.com/jdbcTemplate_2.png)
**修改:**
``` java
    @Test
    public void testUpdate(){
        String sql = "update user set username=? , password=? where id=?";
        int update = jdbcTemplate.update(sql, new Object[]{256, 256,3});
        System.out.println(update);
    }
```
输出结果为1,并且确实数据已经修改
**删除:**
``` java
    @Test
    public void testDelete(){
        String sql = "delete from user where id=?";
        int delete = jdbcTemplate.update(sql, new Object[]{3});
        System.out.println(delete);
    }
```
**5.批量操作:**
``` java
    @Test
    public void testBatch(){
        List<Object[]> batchArgs=new ArrayList<Object[]>();
        batchArgs.add(new Object[]{777,888});
        batchArgs.add(new Object[]{666,888});
        batchArgs.add(new Object[]{555,888});
        String sql = "insert into user (username,password) values (?,?)";
        jdbcTemplate.batchUpdate(sql, batchArgs);
    }
```
以上方法基本满足了日常我们多DAO层进行的操作,不过当你进行CRUD操作时如果传入的参数不确定,这时候你可能会想起ORM框架的便利。没关系！Spring也为我们提供了这样的操作NamedParameterJdbcTemplate。
# NamedParameterJdbcTemplate讲解
在经典的 JDBC 用法中, SQL 参数是用占位符 ? 表示,并且受到位置的限制. 定位参数的问题在于, 一旦参数的顺序发生变化, 就必须改变参数绑定. 
在 Spring JDBC 框架中, 绑定 SQL 参数的另一种选择是使用具名参数(named parameter).
**那么什么是具名参数？**
具名参数: SQL 按名称(以冒号开头)而不是按位置进行指定. 具名参数更易于维护, 也提升了可读性. 具名参数由框架类在运行时用占位符取代
具名参数只在 NamedParameterJdbcTemplate 中得到支持。NamedParameterJdbcTemplate可以使用全部jdbcTemplate方法,除此之外,我们来看看使用它的具名参数案例:
**具名新增：**
```java
    @Test
    public void testNamedParameter(){
        String sql = "insert into user (username,password) values (:username,:password)";
        User u = new User();
        u.setUsername("555");
        SqlParameterSource sqlParameterSource=new BeanPropertySqlParameterSource(u);
        namedParameterJdbcTemplate.update(sql,sqlParameterSource);
    }

```
我们来看看结果
![jdbcTemplate_3](http://ou3np1yz4.bkt.clouddn.com/jdbcTemplate_3.png)
这样我们就可以根据pojo类的属性值使用JDBC来操作数据库了。
**获取新增的主键:**
NamedParameterJdbcTemplate还新增了KeyHolder类,使用它我们可以获得主键,类似Mybatis中的useGeneratedKeys。
```java
   @Test
    public void testKeyHolder(){
        String sql = "insert into user (username,password) values (:username,:password)";
        User u = new User();
        u.setUsername("555");
        SqlParameterSource sqlParameterSource=new BeanPropertySqlParameterSource(u);
        KeyHolder keyHolder = new GeneratedKeyHolder();
        namedParameterJdbcTemplate.update(sql, sqlParameterSource, keyHolder);
        int k = keyHolder.getKey().intValue();
        System.out.println(k);
    }
```
输出结果就是新增的主键。

# 参考资料
- [Spring JdbcTemplate详解](http://www.cnblogs.com/caoyc/p/5630622.html)
- [Spring框架笔记（二十五）——NamedParameterJdbcTemplate与具名参数](https://my.oschina.net/happyBKs/blog/497798)
- [使用Spring的NamedParameterJdbcTemplate完成DAO操作](http://blog.csdn.net/qq_20545159/article/details/48287621)

>本文作者： catalinaLi
本文链接： http://catalinali.top/2017/useJDBC/
版权声明： 原创文章，有问题请评论中留言。非商业转载请注明作者及出处。