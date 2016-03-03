- #练习1

1. <br>
    1. 用gcc命令将以下.c文件生成.o文件
    > kern/init/init.c
    kern/libs/readline.c
    ...
    libs/string.c

    2. 用ld命令连接bin/kernel目录下，上述生成的.o文件

    3. 再用gcc命令将以下文件生成.o文件
    > boot/bootasm.S
    boot/bootmain.c
    ...
    tools/sign.c

    4. 连接bin/bootblock目录下的文件

    5. 用dd命令生成img文件

2.  <br>
符合规范的硬盘主引导扇区，大小为512字节，最后两个字分别为0x55和0xAA

- #练习2
  
1. <br>
 按照实验指导书lab1的附录B中的介绍，把tools/gdbinit改成  
 ```
 target remote : 1234
 set architecture i8086
 ```
 运行
 ```
 make debug
 ```
 qemu停在第一条指令出。用`x /10i $pc` 可以看到当前的指令。用`si(stepi)`指令可以看到单步执行的过程

2. <br>
 接着在tools/gdbinit后面加上
 ```
 b *0x7c00
 continue
 ```
 可以看到gdb的提示信息
 > breakpoint at 0x7c00  
 
 证明断点设置正常

3. <br>
 在上一步的基础上，输入`x /10i $pc`。比较gdb的输出和bootasm.S和booblock.asm是一致的

4. <br>
 由于代码中还没写好时钟中断的处理，因此先用labcodes_answer/lab1_result里的文件。
 将tools/gdbinit改成
 ```
 target remote : 1234
 set architecture i8086
 break bootmain
 continue
 ```
