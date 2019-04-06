title: "JUnit-test的用法"
date: 2015-01-20 00:07:56
categories: Java
tags: 调试
---
为了方便调试，不用每写一个类都需要写一个main方法对其测试，所以Java编写会经常用到JUnit测试。
###新建一个JUnit.test测试包，如下图:
![new](https://github.com/huaqianlee/blog-file/blob/master/image/blognewjunit.png)
###JUnit测试

可以在原文件类的方法上面加上@Test作为JUnit测试单元运行，也可以新建JUnit文件测试，编写方法如下:
```bash
public class PersonTest {

	@BeforeClass // 测试类加载之前运行
	public static void setUpBeforeClass() throws Exception {
		System.out.println("Before");
	}

	@Before  // 每个测试方法运行前运行， 常用
	public void setUp() throws Exception {
		System.out.println("所有的测试方法运行之前运行！！");
	}
	
	@Test  // 注解，给程序看
	public void testEat(){
		
		cn.itcast.Person p = new cn.itcast.Person();
		p.eat();
		
	}
	
	@Test
	public void testRun(){
		cn.itcast.Person p = new cn.itcast.Person();
		p.run();
	}

	@After // 每个测试方法运行后运行 ，常用
	public void tearDown() throws Exception {
		System.out.println("所有的测试方法运行之后运行！！");
	}

    	@AfterClass //测试类加载之后运行
	public static void tearDownAfterClass() throws Exception {
		System.out.println("After");
}
```

###运行JUnit

可以单独运行某个测试方法,也可以选中类,运行所以的测试方法,如下图:
![run](https://github.com/huaqianlee/blog-file/blob/master/image/blogrunjunit.png)




















