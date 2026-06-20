# 🛒 购物商城系统 — 完整技术解读文档

> **适用对象**：想从零理解一个 Java Web 项目的读者。本文档从架构到每一行代码、从技术起源到运行原理，逐层拆解。

---

## 目录

1. [项目概览](#1-项目概览)
2. [整体架构：三层 MVC 模型](#2-整体架构三层-mvc-模型)
3. [技术栈全景图](#3-技术栈全景图)
4. [HTTP 协议基础](#4-http-协议基础)
5. [前端技术深度讲解](#5-前端技术深度讲解)
   - [5.1 HTML](#51-html)
   - [5.2 CSS](#52-css)
   - [5.3 JavaScript](#53-javascript)
   - [5.4 JSP（Java Server Pages）](#54-jspjava-server-pages)
6. [后端技术深度讲解](#6-后端技术深度讲解)
   - [6.1 Servlet](#61-servlet)
   - [6.2 JDBC](#62-jdbc)
   - [6.3 HTTP Session & Cookie](#63-http-session--cookie)
   - [6.4 MySQL 数据库](#64-mysql-数据库)
7. [前端页面逐个拆解](#7-前端页面逐个拆解)
8. [后端类逐个拆解](#8-后端类逐个拆解)
9. [数据流完整走通](#9-数据流完整走通)
10. [数据库设计详解](#10-数据库设计详解)
11. [web.xml 完整解读](#11-webxml-完整解读)
12. [常见问题排查指南](#12-常见问题排查指南)
13. [运行部署指南](#13-运行部署指南)

---

## 1. 项目概览

```
项目名称：购物商城系统（Shopping System）
技术路线：Servlet + JSP + JavaBean + JDBC
数据库：   MySQL 5.x / 8.x
服务器：   Apache Tomcat 8.5+
开发模式：MVC 三层架构
```

**核心业务**：用户注册 → 登录 → 浏览商品 → 加入购物车 → 提交订单 → 查看订单。

---

## 2. 整体架构：三层 MVC 模型

```
┌─────────────────────────────────────────────────────┐
│                     浏览器 (Browser)                  │
│             HTML + CSS + JavaScript                  │
└───────────────┬─────────────────────────────────────┘
                │  HTTP 请求 (GET/POST)
                ▼
┌─────────────────────────────────────────────────────┐
│              表示层 View (JSP)                        │
│   login.jsp  register.jsp  index.jsp                 │
│   goodDetail.jsp  cart.jsp  orderList.jsp            │
│   message.jsp                                        │
│   职责：展示界面、收集用户输入、显示数据                   │
└───────────────┬─────────────────────────────────────┘
                │  调用 Servlet
                ▼
┌─────────────────────────────────────────────────────┐
│            控制层 Controller (Servlet)                 │
│   LoginServlet  RegisterServlet                      │
│   CartServlet   OrderServlet                         │
│   职责：接收请求、参数校验、调用业务层、页面跳转            │
└───────────────┬─────────────────────────────────────┘
                │  调用 Service
                ▼
┌─────────────────────────────────────────────────────┐
│           业务逻辑层 Model (Service)                   │
│   UserService  GoodsService  OrderService            │
│   职责：业务规则处理（如注册前查重）、组装数据              │
└───────────────┬─────────────────────────────────────┘
                │  调用 DAO
                ▼
┌─────────────────────────────────────────────────────┐
│          数据访问层 Model (DAO)                        │
│   UserDao  GoodsDao  OrderDao                        │
│   职责：执行 SQL、封装结果集为 Java 对象                 │
└───────────────┬─────────────────────────────────────┘
                │  JDBC
                ▼
┌─────────────────────────────────────────────────────┐
│              数据库 (MySQL)                           │
│   user 表   items 表   orders 表   ordersitem 表      │
└─────────────────────────────────────────────────────┘
```

> **购物车是例外**：它不走三层架构，直接以 Java 对象形式存储在 **HttpSession** 中，没有 DAO/Service。因为购物车数据是临时的、用户级别的，用 Session 比写数据库更高效。

---

## 3. 技术栈全景图

| 层级 | 技术 | 作用 |
|------|------|------|
| 前端结构 | **HTML5** | 定义页面骨架（表单、表格、图片、链接） |
| 前端样式 | **CSS3** | 控制视觉呈现（颜色、布局、圆角、阴影） |
| 前端行为 | **JavaScript (ES5)** | 注册页表单客户端校验 |
| 动态页面 | **JSP** | Java 代码嵌入 HTML，动态生成页面内容 |
| 后端入口 | **Servlet** | 接收 HTTP 请求，协调业务流程 |
| 数据库连接 | **JDBC** | Java 程序与 MySQL 之间的桥梁 |
| 数据库 | **MySQL** | 持久化存储用户、商品、订单数据 |
| 会话保持 | **HttpSession** | 在多次 HTTP 请求间保持用户状态（购物车） |
| 客户端痕迹 | **Cookie** | 在浏览器端记录"最近浏览商品" |

---



## 4. HTTP 协议基础

> HTTP 是整个 Web 的"通用语言"。理解它是理解 Servlet/JSP 的前提。

### 起源

HTTP（HyperText Transfer Protocol）由 Tim Berners-Lee 于 1989 年在 CERN（欧洲核子研究中心）提出。1991 年发布 HTTP/0.9（仅支持 GET、纯文本响应），1996 年 HTTP/1.0 发布（引入 POST、Header、状态码），1997 年 HTTP/1.1 成为标准（持久连接、管线化、Host 头），这是 **Java Servlet 规范默认使用的版本**。2015 年 HTTP/2.0（二进制帧、多路复用），2022 年 HTTP/3.0（基于 QUIC/UDP）。

### 请求-响应模型

```
浏览器 (Client) ──① HTTP Request──▶ 服务器 (Tomcat)
浏览器 (Client) ◀──② HTTP Response── 服务器 (Tomcat)
```

每次交互都是独立的：浏览器发请求，服务器返回响应，连接关闭（或复用）。服务器不会主动联系浏览器。

### HTTP 请求解剖

```
POST /LoginServlet HTTP/1.1         ← 请求行（方法 + URI + 协议版本）
Host: localhost:8080                ← 请求头（HTTP/1.1 唯一必填）
Content-Type: application/x-www-form-urlencoded
Content-Length: 37
Cookie: JSESSIONID=AB12CD34EF56     ← Session ID 在此传递
                                    ← 空行分隔 headers 和 body
username=zhangsan&password=123456   ← 请求体（仅 POST/PUT/PATCH 有）
```

### HTTP 响应解剖

```
HTTP/1.1 200 OK                     ← 状态行（版本 + 状态码 + 原因短语）
Content-Type: text/html; charset=UTF-8
Set-Cookie: JSESSIONID=XY78ZW...    ← 设置 Cookie
                                    ← 空行
<!DOCTYPE html>                     ← 响应体
<html>...</html>
```

### 常用状态码速查

| 状态码 | 名称 | 本项目何时触发 |
|--------|------|---------------|
| **200** | OK | 所有正常页面返回 |
| **302** | Found（重定向） | `response.sendRedirect()` |
| **404** | Not Found | 访问不存在的 URL |
| **405** | Method Not Allowed | GET 访问仅处理 POST 的 Servlet |
| **500** | Internal Server Error | Java 代码未捕获异常 |

### GET vs POST 深入对比

| 对比维度 | GET | POST |
|----------|-----|------|
| 参数位置 | URL 查询串 `?key=val` | HTTP 请求体 |
| 地址栏可见 | 可见、可收藏 | 不可见 |
| 长度限制 | ~2048 字符 | 无理论限制 |
| 安全性 | 低（URL 暴露、日志记录） | 较高 |
| 缓存 | 浏览器可缓存 | 通常不缓存 |
| 幂等性 | 幂等（多次请求结果同） | 非幂等（可能产生副作用） |
| **本项目使用** | 浏览商品、购物车、订单 | 登录、注册 |

### 请求转发 vs 重定向

```
【forward：服务器内部转发】
  Browser ──req1──▶ Servlet ──forward──▶ JSP
           ◀──────────── resp ──────────
  地址栏不变 | 1 次请求 | request 数据保留

【redirect：客户端重定向】  
  Browser ──req1──▶ Servlet ──302──▶ Browser
           ◀──302 Location: /target──
  Browser ──req2──▶ /target
           ◀──resp──
  地址栏变化 | 2 次请求 | request 数据丢失
```

**本项目选择策略**：

| 场景 | 使用 | 原因 |
|------|------|------|
| 登录成功 | redirect → /index.jsp | 防止刷新时重复提交登录表单 |
| 登录失败 | forward → login.jsp | 保留错误消息在 request 中 |
| 注册成功 | forward → message.jsp | 传递成功消息 + meta 自动跳转 |
| 注册失败 | forward → register.jsp | 保留错误消息 + 已填数据 |
| 购物车操作 | redirect → showCart | 防止刷新重复操作购物车 |
| 提交订单 | forward → message.jsp | 防止刷新重复生成订单 |

---



## 5. 前端技术深度讲解

### 5.1 HTML

**起源**：HTML（HyperText Markup Language）由 Tim Berners-Lee 于 1990 年在 CERN 发明。他同时发明了第一个浏览器和第一个 Web 服务器。核心思想是"超文本"——通过超链接将全球文档互联。

**演进路线**：HTML 1.0(1991) → HTML 2.0(1995) → HTML 3.2(1997) → HTML 4.01(1999) → XHTML 1.0(2000) → HTML5(2014)

**浏览器渲染流水线**：
```
解析 HTML → 构建 DOM 树 → CSS 计算样式 → 布局(Layout) → 绘制(Paint)
(字符串→Token)  (Token→树)    (选择器匹配)    (计算坐标)    (光栅化→像素)
```

**本项目使用的全部 HTML 标签**：

| 标签 | 所在页面 | 用途 |
|------|---------|------|
| `<form>` | login.jsp, register.jsp | 表单容器，action 指定提交地址，method 指定 GET/POST |
| `<input type="text">` | login.jsp, register.jsp | 文本输入，name 标识字段 |
| `<input type="password">` | login.jsp, register.jsp | 密码输入（显示为•••） |
| `<button>` | login.jsp, register.jsp | 提交按钮，type="submit" |
| `<table>` `<tr>` `<td>` `<th>` | cart.jsp, orderList.jsp | 表格展示购物车/订单列表 |
| `<img>` | index.jsp, goodDetail.jsp, cart.jsp | 商品图片 |
| `<a>` | 所有页面 | 超链接导航/操作 |
| `<div>` | 所有页面 | 块级布局容器 |
| `<link>` | 所有页面 | 引入外部 CSS 样式表 |
| `<script>` | register.jsp | 嵌入 JavaScript 代码 |
| `<meta>` | 所有页面 | 字符编码声明 + 刷新跳转 |
| `<span>` | orderList.jsp | 行内容器（状态着色） |
| `<label>` | login.jsp, register.jsp | 表单标签 |
| `<style>` | 所有页面 | 内嵌 CSS |

### 5.2 CSS

**起源**：1994 年 Håkon Wium Lie（当时在 CERN）提出 CSS 构想。动机是 HTML 标签被滥用做样式，内容与表现混杂。1996 年 CSS1 成为 W3C 推荐标准。

**层叠优先级（从高到低）**：
```
!important > 内联 style="" > #id > .class > 标签 > 继承 > 浏览器默认
```

同权重时**后出现的覆盖先出现的**。

**CSS 盒模型**：
```
┌──────── margin（外边距，透明）────────┐
│  ┌──── border（边框）────────────┐  │
│  │  ┌── padding（内边距）──────┐  │  │
│  │  │  ┌─ content（内容区）─┐  │  │  │
│  │  │  └────────────────────┘  │  │  │
│  │  └──────────────────────────┘  │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```
`box-sizing: border-box` → 宽度 = content+padding+border（不含margin）

**本项目 CSS 技巧清单**：

| 技巧 | 关键 CSS | 页面 | 效果 |
|------|----------|------|------|
| 外部样式表 | `<link href="css/main.css">` | 所有 | 复用通用样式 |
| Flexbox 两栏 | `display: flex;` | goodDetail.jsp | 图片左、详情右 |
| 浮动布局 | `float: left; float: right;` | index.jsp 顶栏 | 标题左浮、导航右浮 |
| 清除浮动 | `overflow: hidden;` | 顶栏 | 防止高度塌陷 |
| 卡片阴影 | `box-shadow: 0 2px 10px rgba(0,0,0,0.1)` | 所有容器 | 立体层次感 |
| 圆角 | `border-radius: 8px` | 所有容器 | 现代感 |
| 水平居中 | `margin: 30px auto;` | 容器 | 居中 |
| 悬停交互 | `.btn:hover { background: #1a6ed8 }` | 所有按钮 | 交互反馈 |
| 聚焦高亮 | `input:focus { border-color: #2d8cf0 }` | 登录/注册 | 高亮当前输入 |
| 盒尺寸 | `box-sizing: border-box` | 输入框 | padding 计入总宽 |
| 过渡动画 | `transition: box-shadow 0.3s` | 商品卡片 | 悬停平滑变化 |
| 竖排居中 | `line-height: 40px` | 顶栏 | 单行文字垂直居中 |
| 边框合并 | `border-collapse: collapse` | 表格 | 相邻边框合并 |
| 去下划线 | `text-decoration: none` | 所有 `<a>` | 去掉默认下划线 |

**统一配色**：`#2d8cf0`（蓝）、`#e4393c`（红）、`#999`（灰）

### 5.3 JavaScript

**起源**：1995 年 5 月，网景公司的 Brendan Eich 被要求开发浏览器"胶水语言"，10 天完成原型。命名：Mocha → LiveScript → JavaScript（蹭 Java 热度）。

**JS 引擎工作原理**：
```
源码 → 词法分析 → 语法分析 → AST 抽象语法树 → 字节码 → JIT 编译 → 机器码执行
```

**前端+后端双重校验的必要性**：

| | 前端校验（JS） | 后端校验（Servlet） |
|---|---|---|
| 执行位置 | 浏览器 | 服务器 |
| 速度 | 即时（无网络延迟） | 需等待请求-响应往返 |
| 可靠性 | **不可信**（用户可禁用JS/篡改） | **可信**（服务器完全控制） |
| 目的 | 提升用户体验（快速反馈） | 保证数据安全（最后防线） |

> **安全铁律**：前端校验是给用户的"便利"，后端校验是给系统的"保险"。永远不能只依赖前端校验！

**本项目 JS 代码逐行注解**（register.jsp）：

```javascript
function validateForm() {
    // document.forms[0] → 获取页面第一个 <form>
    // .username → 通过 name 属性定位元素
    // .value → 获取用户输入的字符串
    // .trim() → 去除首尾空白
    var username = document.forms[0].username.value.trim();
    var password = document.forms[0].password.value;
    var repassword = document.forms[0].repassword.value;

    // === 严格相等（值和类型都相同）
    if (username === "") { alert("用户名不能为空！"); return false; }

    // .length 字符数
    if (password.length < 6) { alert("密码至少6位！"); return false; }

    // !== 严格不等
    if (password !== repassword) { alert("两次密码不一致！"); return false; }

    // 正则：^开头 \S+非空白 @ @符号 \. 转义点 $结尾
    var email = document.forms[0].email.value.trim();
    if (email !== "" && !/^\S+@\S+\.\S+$/.test(email)) {
        alert("邮箱格式不正确！"); return false;
    }

    return true; // 全部通过 → 表单提交
}
```

**HTML 绑定方式**：
```html
<form action="RegisterServlet" method="post" onsubmit="return validateForm()">
```
- `return false` → 事件取消，表单不提交
- `return true` → 表单正常提交
- 缺少 `return` 关键字则函数返回值无效，表单无论如何都会提交

### 5.4 JSP

**起源**：1998 年 Sun Microsystems 面对微软 ASP（1996年发布）的压力，于 1999 年发布 JSP 1.0。设计初衷是"页面设计师和 Java 开发者可分工协作"。

**JSP 生命周期（本质是 Servlet 的变身）**：

```
.jsp 文件  ──① Jasper 翻译──▶  _jsp.java (Servlet 子类)  ──② javac 编译──▶  _jsp.class
                                                                                │
只执行一次（首次访问）                                                   ③ 实例化 & init()
                                                                                │
                                                                                ▼
                                                                       _jspService(req, resp)
                                                                       处理每次请求
                                                                       HTML文本 → out.write()
```

**JSP 代码翻译示例**：

```jsp
<!-- JSP 源码 -->
<h1>欢迎, <%=user.getUsername()%>!</h1>
<%
    for (Goods g : goodsList) {
%>
    <div><%=g.getName()%></div>
<%
    }
%>
```

```java
// 翻译后的 _jspService() 等价代码
out.write("<h1>欢迎, ");
out.print(user.getUsername());    // <%= %> 翻译为 out.print()
out.write("!</h1>\n");
for (Goods g : goodsList) {       // <% %> 原样保留
    out.write("    <div>");
    out.print(g.getName());
    out.write("</div>\n");
}
```

**JSP 九大隐式对象的作用域**：

| 对象 | 作用域 | 存活时间 | 线程安全 |
|------|--------|---------|---------|
| `pageContext` | 当前页面 | 一次请求 | 安全（不共享）|
| `request` | 一次请求 | forward 期间 | 安全（不共享）|
| `session` | 一个用户 | 直到超时/invalidate | ⚠️ 并发请求可能竞争 |
| `application` | 整个应用 | 服务器运行期间 | ⚠️ 所有用户共享 |

**本项目 JSP 三种使用模式**：

| 模式 | 代表页面 | 流程 |
|------|---------|------|
| Servlet→JSP 展示 | cart.jsp, orderList.jsp | Servlet 处理 → 数据入 request/session → forward → JSP 取数据渲染 |
| JSP 自处理 | index.jsp, goodDetail.jsp | JSP 直接调 DAO 查库 → 渲染（无对应 Servlet）|
| 消息中转 | message.jsp | Servlet 设置消息 → forward → 显示 + 延时跳转 |

---



## 6. 后端技术深度讲解

### 6.1 Servlet

**起源**：Servlet 于 1997 年随 Java Servlet API 1.0 发布，是 Java 对 CGI（Common Gateway Interface）的替代方案。CGI 每次请求都启动一个新进程，性能极差；Servlet 则用多线程处理请求，一个进程即可服务大量并发。

**生命周期**：
```
① 加载&实例化 → ② init() 初始化 → ③ service()/doGet()/doPost() 处理请求
                                       ↕   (可循环多次)
                                    ④ destroy() 销毁
```

Tomcat 通过 `web.xml` 找到 URL 与 Servlet 的映射关系。当请求 `/LoginServlet` 时，Tomcat 调用对应 Servlet 的 `service()` 方法，`HttpServlet.service()` 会根据 HTTP 方法（GET/POST）分派到 `doGet()` 或 `doPost()`。

**本项目中的用法**：

```xml
<!-- web.xml 中注册映射 -->
<servlet>
    <servlet-name>LoginServlet</servlet-name>
    <servlet-class>servlet.LoginServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>LoginServlet</servlet-name>
    <url-pattern>/LoginServlet</url-pattern>    ← 浏览器访问这个 URL
</servlet-mapping>
```

**请求转发 vs 重定向**：

| | `forward()` | `sendRedirect()` |
|---|---|---|
| 浏览器地址栏 | 不变 | 变 |
| 请求次数 | 1 次（服务器内部） | 2 次（浏览器重新发请求） |
| request 数据 | 保留 | 丢失（新请求） |
| 适用场景 | 携带错误信息回原页面 | 登录成功后跳首页 |

### 6.2 JDBC

**起源**：JDBC（Java Database Connectivity）于 1997 年随 JDK 1.1 发布，是 Java 定义的一套访问数据库的标准接口。各数据库厂商提供各自的驱动实现。

**原理**：
```
Java程序 ──调用──▶ JDBC接口(java.sql.*) ──调用──▶ MySQL驱动(jar) ──网络──▶ MySQL服务器
```

**本项目六步标准流程**：

```java
// ① 加载驱动
Class.forName("com.mysql.cj.jdbc.Driver");
// ② 建立连接（TCP 连接到 MySQL 3306 端口）
Connection conn = DriverManager.getConnection(url, user, password);
// ③ 创建预编译语句（防 SQL 注入）
PreparedStatement pst = conn.prepareStatement("SELECT * FROM user WHERE username=?");
// ④ 设置参数（索引从 1 开始）
pst.setString(1, username);
// ⑤ 执行并获取结果
ResultSet rs = pst.executeQuery();
while (rs.next()) { ... }  // 逐行遍历
// ⑥ 释放资源（先开的后关：rs → pst → conn）
rs.close(); pst.close(); conn.close();
```

> `PreparedStatement` 使用 `?` 占位符 + `setXxx()` 传参，**自动转义特殊字符**，从根本上防止 SQL 注入。

**本项目事务处理（OrderDao）**：

```java
conn.setAutoCommit(false);   // 关闭自动提交，开启事务
try {
    // 插入 orders 表
    pst.executeUpdate();
    // 插入 ordersitem 表（可能多条）
    for (OrdersItem item : items) { pst.executeUpdate(); }
    conn.commit();            // 全部成功，提交
} catch (Exception e) {
    conn.rollback();          // 任何一步失败，回滚全部
}
```

> 事务的 **ACID** 特性：Atomicity（原子性）、Consistency（一致性）、Isolation（隔离性）、Durability（持久性）。

### 6.3 HTTP Session & Cookie

**起源**：HTTP 协议本身是**无状态**的。1994 年 Netscape 发明了 Cookie 来解决这个问题。Session 则是服务器端的状态保持方案。

**原理对比**：

| | Cookie | Session |
|---|---|---|
| 存储位置 | 浏览器（客户端） | 服务器内存 |
| 安全性 | 低（可被篡改） | 高（用户不可见） |
| 容量 | 约 4KB | 理论上无限制 |
| 生命周期 | 可设过期时间 | 默认 30 分钟无活动销毁 |
| 关联方式 | — | 靠 Cookie 里的 `JSESSIONID` 关联 |

**本项目中的用法**：

```
【Session 存储购物车】
  CartServlet → session.setAttribute("cart", cart)
  cart.jsp    → session.getAttribute("cart")

【Session 存储登录用户】
  LoginServlet → session.setAttribute("user", user)
  所有页面     → session.getAttribute("user") 判断登录状态

【Cookie 记录浏览历史】
  goodDetail.jsp → Cookie("viewedGoods", "3,1,5,2,8")
                    cookie.setMaxAge(60*60*24*7)  // 7天有效
                    response.addCookie(cookie)
```

### 6.4 MySQL 数据库

**起源**：MySQL 由瑞典公司 MySQL AB 于 1995 年发布，是全球最流行的开源关系型数据库。

**原理**：关系型数据库将数据组织为**表**（Table），表由**行**（Row）和**列**（Column）组成。通过 SQL（Structured Query Language）进行 CRUD 操作。

**本项目四张表的 ER 关系**：

```
  user (用户)                    items (商品)
  ┌──────────┐                  ┌──────────┐
  │ id (PK)  │                  │ id (PK)  │
  │ username │                  │ name     │
  │ password │                  │ price    │
  └────┬─────┘                  └────┬─────┘
       │ 1:N                         │ 1:N
       ▼                             ▼
  orders (订单)               ordersitem (订单项)
  ┌──────────────┐            ┌──────────────┐
  │ id (PK)      │◄───────────│ orders_id(FK) │
  │ orderId      │  1:N       │ good_id (FK)  │
  │ user_id (FK) │            │ num, price    │
  │ state, price │            └──────────────┘
  └──────────────┘
```

> **为什么拆分成 orders 和 ordersitem 两张表？** 避免数据冗余。一个订单买 3 件商品，拆表后订单基本信息只存 1 行，商品明细存 ordersitem。

---



## 7. 前端页面逐个拆解

### 7.1 login.jsp — 登录页

**URL**：`/login.jsp` 或通过 `/LoginServlet` (GET) 进入  
**职责**：展示登录表单、处理退出操作。

```jsp
<%-- 处理退出操作 --%>
<% if ("logout".equals(request.getParameter("action"))) {
    session.invalidate();           // 销毁 Session（清除 user + cart）
    response.sendRedirect("login.jsp");
    return;
} %>

<%-- 显示错误消息 --%>
<% String msg = (String)request.getAttribute("message");
   if (msg != null) { %>
    <div class="error"><%=msg%></div>
<% } %>

<form action="LoginServlet" method="post">
    <input type="text" name="username" placeholder="请输入用户名" required>
    <input type="password" name="password" placeholder="请输入密码" required>
    <button type="submit">登 录</button>
</form>
```

### 7.2 register.jsp — 注册页

**URL**：`/register.jsp`  
**职责**：注册表单 + 前端 JS 校验 + 后端 Servlet 校验。

**双重校验流程**：
```
用户点"注册" → [JS前端校验] ─不通过→ alert()阻止提交
                │通过
                ▼
          POST /RegisterServlet → [Servlet后端校验]
                ├─失败→ forward register.jsp + 错误消息
                └─成功→ forward message.jsp（2秒后跳登录页）
```

**JS 校验函数**（核心代码）：
```javascript
function validateForm() {
    var username = document.forms[0].username.value.trim();
    if (username === "") { alert("用户名不能为空！"); return false; }
    if (password.length < 6) { alert("密码至少6位！"); return false; }
    if (password !== repassword) { alert("两次密码不一致！"); return false; }
    if (email !== "" && !/^\S+@\S+\.\S+$/.test(email)) {
        alert("邮箱格式不正确！"); return false;
    }
    return true;
}
```

**后端校验**（RegisterServlet.doPost()）：
```java
// 非空校验（防止绕过前端 JS 直接发 HTTP 请求）
if (username == null || username.trim().isEmpty()) { /* forward 回注册页 */ }
// 密码一致性
if (!password.equals(repassword)) { /* forward 回注册页 */ }
// 用户名查重（前端做不到，必须查数据库）
if (!userService.register(user)) { /* forward 回注册页 */ }
```

### 7.3 index.jsp — 商品首页

**URL**：`/index.jsp`（web.xml 配置为欢迎页）  
**职责**：展示全部商品 + 顶栏导航 + 登录状态判断。

**数据获取**：index.jsp 直接调用 DAO（不经过 Servlet→Service），因为首页逻辑极简单。

```jsp
<%
    GoodsDao goodsDao = new GoodsDao();
    List<Goods> goodsList = goodsDao.findAll();  // SELECT * FROM items
    for (Goods good : goodsList) {
%>
    <div class="product-item">
        <a href="goodDetail.jsp?id=<%=good.getId()%>">
            <img src="images/<%=good.getPicture()%>">
        </a>
        <div class="name"><%=good.getName()%></div>
        <div class="price">¥<%=good.getPrice()%></div>
        <a href="CartServlet?operation=add&id=<%=good.getId()%>">加入购物车</a>
    </div>
<%  }  %>
```

### 7.4 goodDetail.jsp — 商品详情页

**URL**：`/goodDetail.jsp?id=3`  
**职责**：展示单个商品 + Cookie 浏览历史。

**Cookie 浏览历史实现**：
```jsp
<%
    // ① 读取旧 Cookie
    Cookie[] cookies = request.getCookies();
    String viewed = "";
    for (Cookie c : cookies) {
        if ("viewedGoods".equals(c.getName())) viewed = c.getValue();
    }

    // ② 更新列表：去重 + 插队首 + 限5条
    List<String> ids = new ArrayList<>(Arrays.asList(viewed.split(",")));
    ids.removeIf(String::isEmpty);
    ids.remove(String.valueOf(currentId));       // 去重
    ids.add(0, String.valueOf(currentId));       // 插队首
    if (ids.size() > 5) ids = ids.subList(0, 5);

    // ③ 写回 Cookie（7天有效）
    Cookie ck = new Cookie("viewedGoods", String.join(",", ids));
    ck.setMaxAge(60 * 60 * 24 * 7);
    response.addCookie(ck);  // ★ 必须在任何 HTML 输出之前调用

    // ④ 批量查商品
    List<Goods> history = goodsDao.getGoodsByIds(String.join(",", ids));
%>
```

### 7.5 cart.jsp — 购物车页

**URL**：`/CartServlet?operation=showCart`（CartServlet 转发）  
**职责**：展示购物车、移除/清空/提交订单。

**Session 中 Cart 数据结构**：
```
Cart {
    items: LinkedHashMap<Integer, CartItem> {
        3 → CartItem { good=耐克鞋(¥500), num: 2, price: 1000.0 }
        6 → CartItem { good=小米3(¥1999), num: 1, price: 1999.0 }
    }
    num: 3          ← 每次增删后 recalculate() 自动更新
    price: 2999.0
}
```

**四个操作按钮**：

| 按钮 | URL | 效果 |
|------|-----|------|
| 移除 | `CartServlet?operation=remove&id=3` | Map.remove() → redirect 防刷新重复 |
| 清空 | `CartServlet?operation=clear` | Map.clear() → redirect |
| 继续购物 | `index.jsp` | 返回首页 |
| 提交订单 | `OrderServlet?operation=genOrders` | 写库+清车 |

### 7.6 orderList.jsp — 我的订单页

**URL**：`/OrderServlet?operation=showUsersOrders`  
**数据链路**：OrderServlet → OrderService → OrderDao → SQL → request.setAttribute → forward → JSP 渲染

### 7.7 message.jsp — 消息提示页

**职责**：统一消息展示中转页。支持 `<meta http-equiv='Refresh' content='2;URL=...'>` 延时自动跳转，无需 JavaScript。

---



## 8. 后端类逐个拆解

> 完整源码位于 `solution/src/` 下，共 18 个 Java 文件。

### 8.1 PO 层（实体类，6个）

| 类 | 对应表 | 关键字段 |
|----|--------|---------|
| `User.java` | user | id, username, password, email, phone |
| `Goods.java` | items | id, name, city, price, number, picture |
| `Cart.java` | 无（Session） | items(Map), num, price + addGood/removeGood/clear/recalculate |
| `CartItem.java` | 无（Session） | good(Goods), num, price（setNum时自动重算price） |
| `Orders.java` | orders | id, orderId, num, price, state, items(List), userId |
| `OrdersItem.java` | ordersitem | id, num, price, goodId, good |

> Cart 用 `LinkedHashMap<Integer, CartItem>` 保持商品加入顺序。

### 8.2 Util 层（工具类，2个）

| 类 | 方法 | 说明 |
|----|------|------|
| `DButil.java` | `getConn()` | 加载驱动 → DriverManager.getConnection → 返回 Connection |
| | `closeAll(con, pst, rs)` | 按 rs→pst→con 顺序安全关闭 |
| `IdUtils.java` | `genId()` | `System.currentTimeMillis()` + `String.format("%02d", random)` → 唯一订单号 |

### 8.3 DAO 层（数据访问层，3个）

| 类 | 方法 | SQL/逻辑 |
|----|------|---------|
| `GoodsDao` | `findAll()` | `SELECT * FROM items ORDER BY id` |
| | `findById(id)` | `SELECT * FROM items WHERE id=?` |
| | `find(id,name,city)` | 动态拼接 WHERE 子句（预留筛选功能） |
| | `getGoodsByIds(ids)` | `SELECT * FROM items WHERE id IN (?,?,...)` — 动态生成等量占位符 |
| `UserDao` | `login(username, password)` | `SELECT * FROM user WHERE username=? AND password=?` |
| | `register(user)` | `INSERT INTO user (...) VALUES (?,?,?,?)` |
| | `existUsername(username)` | `SELECT COUNT(*) FROM user WHERE username=?` |
| `OrderDao` | `addOrders(orders, user)` | **事务**：`setAutoCommit(false)` → INSERT orders（获取自增主键）→ 循环 INSERT ordersitem → `commit()` / `rollback()` |
| | `findOrdersByUserId(userId)` | `SELECT * FROM orders WHERE user_id=? ORDER BY orderId DESC` |

### 8.4 Service 层（业务逻辑层，3个）

| 类 | 方法 | 关键业务规则 |
|----|------|-------------|
| `UserService` | `login()` | 透传 |
| | `register(user)` | **先查重**（existUsername），不重复才写入 |
| `GoodsService` | findAll/findById/getGoodsByIds | 全部透传 |
| `OrderService` | addOrders/findOrdersByUserId | 全部透传（事务在 DAO 层） |

### 8.5 Servlet 层（控制层，4个）

| 类（URL） | 方法 | 流程 |
|-----------|------|------|
| `LoginServlet` (/LoginServlet) | GET → forward login.jsp | POST → Service.login() → 成功：session.setAttribute+redirect /index.jsp；失败：forward login.jsp+msg |
| `RegisterServlet` (/RegisterServlet) | POST → 后端校验（非空/一致性/查重）→ 成功：forward message.jsp；失败：forward register.jsp |
| `CartServlet` (/CartServlet) | operation=add: 检查登录→查商品→cart.addGood()→存Session→redirect | remove: cart.removeGood()→redirect | clear: cart.clear()→redirect | showCart: forward cart.jsp |
| `OrderServlet` (/OrderServlet) | operation=genOrders: 取Cart→生成订单号→组装Orders+OrdersItem→事务写入→session.removeAttribute("cart")→forward message.jsp | 默认: 查询用户订单→forward orderList.jsp |

---



## 9. 数据流完整走通

以"注册 → 登录 → 浏览 → 加购 → 下单 → 查看"为例：

```
① 注册
   POST /RegisterServlet → RegisterServlet → UserService.register() → UserDao.register()
                                                                        → INSERT INTO user

② 登录
   POST /LoginServlet → LoginServlet → UserService.login() → UserDao.login()
                                                              → SELECT ... WHERE username=? AND password=?
                      ← session.setAttribute("user", user)
                      ← redirect /index.jsp

③ 首页
   GET /index.jsp → 编译执行 JSP → GoodsDao.findAll() → SELECT * FROM items
                                  ← 返回 HTML（含全部商品）

④ 详情
   GET /goodDetail.jsp?id=3 → JSP → GoodsDao.findById(3) → SELECT ... WHERE id=3
                                 → Cookie 读写浏览历史

⑤ 加购
   GET /CartServlet?operation=add&id=3 → CartServlet.addCart()
      → 查登录态 → GoodsService.findById(3) → cart.addGood(goods)
      → session.setAttribute("cart", cart)
      → redirect /CartServlet?operation=showCart

⑥ 看购物车
   GET /CartServlet?operation=showCart → forward /cart.jsp
      → session.getAttribute("cart") → 渲染表格

⑦ 提交订单
   GET /OrderServlet?operation=genOrders → OrderServlet.genOrders()
      → IdUtils.genId() → 组装 Orders + OrdersItem
      → OrderService.addOrders() → OrderDao.addOrders() [事务]
         → INSERT INTO orders → 获取自增主键 → INSERT INTO ordersitem (×N)
      → session.removeAttribute("cart")
      → forward /message.jsp

⑧ 查看订单
   GET /OrderServlet?operation=showUsersOrders → OrderServlet.showUsersOrders()
      → OrderService.findOrdersByUserId() → SELECT * FROM orders WHERE user_id=?
      → forward /orderList.jsp
```

---

## 10. 数据库设计详解

**完整 SQL**：`solution/db/shopping.sql`  
**数据库**：shopping | **字符集**：utf8 | **引擎**：InnoDB（支持事务和外键）

### 四张表结构

| 表名 | 用途 | 关键字段 |
|------|------|----------|
| `user` | 用户信息 | id(PK), username(UQ,NN), password(NN), email, phone |
| `items` | 商品信息 | id(PK), name, city, price, number, picture |
| `orders` | 订单主表 | id(PK), orderId(NN), num, price, state(D:0), user_id(FK) |
| `ordersitem` | 订单明细 | id(PK), num, price, orders_id(FK), good_id(FK) |

### ER 关系

```
user ──1:N──▶ orders ──1:N──▶ ordersitem ◀──N:1── items
```

### 设计要点

1. **orders 和 ordersitem 拆分**：消除数据冗余。一个订单买 3 件商品，拆表后订单基本信息只存 1 行。
2. **购物车不建表**：临时数据存 Session，避免频繁写库。
3. **InnoDB 引擎**：支持外键约束和事务（订单写入必须用事务保证一致性）。

---

## 11. web.xml 完整解读

**路径**：`web/WEB-INF/web.xml`  
**全称**：Web 应用程序部署描述符（Deployment Descriptor）

### 配置结构

```xml
<web-app version="3.1">
    <display-name>Shopping System</display-name>

    <!-- 每个 Servlet 需要一对 <servlet> + <servlet-mapping> -->
    <servlet>
        <servlet-name>LoginServlet</servlet-name>          <!-- 内部名称 -->
        <servlet-class>servlet.LoginServlet</servlet-class> <!-- 完整类路径 -->
    </servlet>
    <servlet-mapping>
        <servlet-name>LoginServlet</servlet-name>          <!-- 关联上面 -->
        <url-pattern>/LoginServlet</url-pattern>            <!-- 浏览器访问的 URL -->
    </servlet-mapping>

    <!-- RegisterServlet / CartServlet / OrderServlet 结构同上 -->

    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>              <!-- 根路径 / 自动跳转 -->
    </welcome-file-list>
</web-app>
```

### URL 映射原理

```
浏览器请求：http://localhost:8080/shopping/LoginServlet
                                ──────── ───────────
                               Context Path  Servlet Path

Tomcat 处理：
① 匹配 Context Path → 找到 shopping 应用
② 匹配 Servlet Path → 在 <url-pattern> 中查找 "/LoginServlet"
③ 找到 <servlet-name> → 在 <servlet> 中查找 LoginServlet
④ 找到 <servlet-class> → servlet.LoginServlet
⑤ 加载类 → 调用 service() → doGet()/doPost()
```

> Servlet 3.0+ 支持 `@WebServlet("/LoginServlet")` 注解替代 XML 配置。本项目使用 `web.xml` 是为了**理解底层映射原理**。

---

## 12. 常见问题排查指南

### 12.1 数据库连接失败

| 检查项 | 操作 |
|--------|------|
| MySQL 服务是否启动？ | `net start mysql` (Win) / `systemctl status mysqld` (Linux) |
| 数据库名是否正确？ | `DButil.java` 中 url 的 `/shopping` 部分 |
| 用户名密码？ | MySQL 中 `SELECT user,host FROM mysql.user;` |
| JDBC 驱动 jar？ | 确认在 `WEB-INF/lib/` 下 |

### 12.2 中文乱码

| 检查点 | 配置 |
|--------|------|
| JSP 页面 | `<%@ page contentType="text/html; charset=UTF-8" %>` |
| Servlet | `request.setCharacterEncoding("UTF-8")` |
| JDBC URL | `?useUnicode=true&characterEncoding=utf-8` |
| 数据库 | 表和字段字符集为 `utf8` |
| MySQL 配置 | `my.ini` 中 `default-character-set=utf8` |

### 12.3 Session 丢失

| 可能原因 | 解决 |
|---------|------|
| 30分钟超时 | Tomcat 默认 session-timeout=30min |
| 调用了 `session.invalidate()` | 退出登录会清除 |
| 浏览器禁用 Cookie | Session 依赖 `JSESSIONID` Cookie |
| 更换浏览器/隐私模式 | 不同窗口 Session 独立 |

### 12.4 刷新页面导致购物车重复添加

**原因**：如果 `addCart()` 用 `forward` 而非 `redirect`，浏览器地址栏仍是添加操作的 URL，刷新会再次执行添加。

**解决**：本项目已使用 `sendRedirect`，刷新时指向 `showCart`，不会重复添加。

### 12.5 编译错误：找不到 javax.servlet

```bash
# 编译时需指定 servlet-api.jar 路径
javac -cp "C:\tomcat\lib\servlet-api.jar" -d WEB-INF/classes src/**/*.java
```

> 部署时不需要在 `WEB-INF/lib` 中放 `servlet-api.jar`，Tomcat 自带。

---

## 13. 运行部署指南

### 环境要求

| 软件 | 版本 | 作用 |
|------|------|------|
| JDK | >= 1.8 | Java 运行环境 |
| MySQL | 5.x / 8.x | 数据库 |
| Tomcat | >= 8.5 | Servlet/JSP 容器 |
| mysql-connector-java.jar | 5.x / 8.x | JDBC 驱动 |

### 部署步骤

```
1. 启动 MySQL，执行 db/shopping.sql
   mysql -u root -p < solution/db/shopping.sql

2. 修改 DButil.java 中的数据库连接信息

3. 编译 Java 源文件到 WEB-INF/classes/
   javac -d WEB-INF/classes -cp "WEB-INF/lib/*" src/**/*.java

4. 将 solution/web/ 复制到 Tomcat 的 webapps/ 下，重命名为 shopping

5. 确保 mysql-connector-java.jar 在 WEB-INF/lib/ 下

6. 启动 Tomcat，访问 http://localhost:8080/shopping/
```

### 项目目录结构

```
solution/
├── db/shopping.sql                  # 建库脚本 + 商品数据
├── src/
│   ├── po/          (6个)            # 实体类
│   ├── dao/         (3个)            # 数据访问层
│   ├── service/     (3个)            # 业务逻辑层
│   ├── servlet/     (4个)            # 控制层
│   └── util/        (2个)            # 工具类
├── web/
│   ├── WEB-INF/web.xml              # 部署描述符
│   ├── css/ js/ images/             # 静态资源
│   └── *.jsp        (7个)            # 前端页面
└── Web编程技术课程设计报告.docx
```

---

> 📌 **阅读建议**：新手建议按"前端页面 → PO 实体类 → DAO → Service → Servlet → 数据库"的顺序阅读。前端最直观，后端自上而下（Servlet→Service→DAO）追调用链。