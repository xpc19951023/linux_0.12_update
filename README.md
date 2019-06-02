# linux_0.12_update
Now,I wand to read linux_0.12 and change it to make it can be used on my computer(x64).
It is a long time to do this,because l am a new hand.
Hope everting is ok.



#2019/6/2  13：15
成功将网上linux0.00的代码用NASM回编格式重写
1.加入A20总线判断
2.将定时器0改为RTC时钟
目前问题和方向：
A20总线的检测在我的计算机上是可以运行的，但PIC已经被弃用，需要验证此代码在我的计算机上能否正确运行，如果不可以，需要研究APIC，使这段代码能够正确运行，得到想要的结果。
  参考资料为：
  https://my.oschina.net/findurl/blog/188123
  https://blog.csdn.net/weixin_33737774/article/details/86952055
  
 
 
