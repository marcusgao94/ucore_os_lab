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

- #练习3

1. <br>
 因为开机时在实模式，只支持20位的地址，开启A20后可以支持32位地址  
 开启A20的方法是如下这段代码
 ```
 seta20.1:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.1

    movb $0xd1, %al                                 # 0xd1 -> port 0x64
    outb %al, $0x64                                 # 0xd1 means: write data to 8042's P2 port

seta20.2:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.2

    movb $0xdf, %al                                 # 0xdf -> port 0x60
    outb %al, $0x60                                 # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1
 ```
 先把0xd1写入0x64端口，再把0xdf写入0x60端口

2. <br>
 初始化GDT的代码是这段
 ```
 gdt:
    SEG_NULLASM                                     # null seg
    SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)           # code seg for bootloader and kernel
    SEG_ASM(STA_W, 0x0, 0xffffffff)                 # data seg for bootloader and kernel

gdtdesc:
    .word 0x17                                      # sizeof(gdt) - 1
    .long gdt                                       # address gdt
 ```
 `lgdt gdtdesc`就是载入全局描述符表

3. <br>
 ```
 movl %cr0, %eax
 orl $CR0_PE_ON, %eax
 movl %eax, %cr0
 ```
 这段代码就是将%cr0的某一位置成1,开启保护模式。
 ``` 
 ljmp $PROT_MODE_CSEG, $protcseg
 ```
 长跳转指令开始保护模式
