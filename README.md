# linux_0.12_update
Now,I wand to read linux_0.12 and change it to make it can be used on my computer(x64).
It is a long time to do this,because l am a new hand.
Hope everting is ok.

if you want to contact me：
  email：987543907@qq.com     xupengcheng@citos.cn

# 2019/6/2  13：15
成功将网上linux0.00的代码用NASM汇编格式重写
1. 加入A20总线判断a
2. 将定时器0改为RTC时钟
目前问题和方向：
A20总线的检测在我的计算机上是可以运行的，但PIC已经被弃用，需要验证此代码在我的计算机上能否正确运行，如果不可以，需要研究APIC，使这段代码能够正确运行，得到想要的结果。
  参考资料为：
  https://my.oschina.net/findurl/blog/188123
  https://blog.csdn.net/weixin_33737774/article/details/86952055
  
 Successfully rewritten the online linux0.00 code in NASM  format
 1.  add the A20 bus  judge
 2. Change timer 0 to RTC clock
 The detection of the A20 bus is operational on my computer, but PIC has been deprecated and needs to verify that this code works if can operate correctly on my computer. If not, I need to study APIC to make this code work correctly. , get the results you want.
 Reference material is：
   https://my.oschina.net/findurl/blog/188123
   https://blog.csdn.net/weixin_33737774/article/details/86952055
# 2019/6/4 16.18
成功在我的电脑上实现linux0.00
发现两个问题
  1. cli使用后，int n 不能使用，在真实硬件上会重启；
  2. 8259 PIC还是兼容的，我上面的判断是错误的。但是A20总线确实默认开启，我现在还这么认为。
  
Successfully implemented linux0.00 on my computer
Found two problems
   1. After cli is used, INT n cannot be used and will restart on real hardware.
   2. The 8259 PIC is still compatible. My judgment above is wrong. But the A20 bus does open by default, and I still think so.
# 2019/6.5 
项目终结，太多不兼容代码，没有移植。

虽然失败；积累了很多基础知识
