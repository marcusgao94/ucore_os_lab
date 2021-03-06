# 练习1
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

# 练习2
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

# 练习3
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
 以上这段代码就是将%cr0的某一位置成1,开启保护模式。
 ``` 
 ljmp $PROT_MODE_CSEG, $protcseg
 ```
 长跳转指令开始保护模式

# 练习4
1. <br>
 用readsec函数读取磁盘
 ```
 static void
readsect(void *dst, uint32_t secno) {
    // wait for disk to be ready
    waitdisk();

    outb(0x1F2, 1);                         // count = 1
    outb(0x1F3, secno & 0xFF);
    outb(0x1F4, (secno >> 8) & 0xFF);
    outb(0x1F5, (secno >> 16) & 0xFF);
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);
    outb(0x1F7, 0x20);                      // cmd 0x20 - read sectors

    // wait for disk to be ready
    waitdisk();

    // read a sector
    insl(0x1F0, dst, SECTSIZE / 4);
}
 ```

2. <br>
  1. 读取ELF的头部，通过储存在头部的幻数判断ELF文件是否合法。
  2. 按照ELF文件头的描述表，调用readseg函数，将从1扇区开始的ELF文件载入内存的对应位置。
  3. 根据ELF头部储存的入口信息，找到内核的入口。 

# 练习5
按照程序中已经给出的提出完成每一步即可。输出是：
```
ebp: 0x00007b08	eip: 0x001009a6	args: 0x00010094 0x00000000 0x00007b38 0x00100092 
    kern/debug/kdebug.c:306: print_stackframe+21
ebp: 0x00007b18	eip: 0x00100cac	args: 0x00000000 0x00000000 0x00000000 0x00007b88 
    kern/debug/kmonitor.c:125: mon_backtrace+10
ebp: 0x00007b38	eip: 0x00100092	args: 0x00000000 0x00007b60 0xffff0000 0x00007b64 
    kern/init/init.c:48: grade_backtrace2+33
ebp: 0x00007b58	eip: 0x001000bb	args: 0x00000000 0xffff0000 0x00007b84 0x00000029 
    kern/init/init.c:53: grade_backtrace1+38
ebp: 0x00007b78	eip: 0x001000d9	args: 0x00000000 0x00100000 0xffff0000 0x0000001d 
    kern/init/init.c:58: grade_backtrace0+23
ebp: 0x00007b98	eip: 0x001000fe	args: 0x001032fc 0x001032e0 0x0000130a 0x00000000 
    kern/init/init.c:63: grade_backtrace+34
ebp: 0x00007bc8	eip: 0x00100055	args: 0x00000000 0x00000000 0x00000000 0x00010094 
    kern/init/init.c:28: kern_init+84
ebp: 0x00007bf8	eip: 0x00007d68	args: 0xc031fcfa 0xc08ed88e 0x64e4d08e 0xfa7502a
```
最后一行ebp的值为0x7bf8。根据代码的内容，再下一个ebp就是0，也就是最开始的初始化的堆栈的位置（bootmain.S中将ebp设为0，然后call bootmain）。由此可见，这里最后一行就是bootmain所在处。 由于在call bootmain之前先将esp栈顶指针设置为了start所在的0x7c00，那么在call bootmain时先将返回地址压栈，再将old ebp压栈，相差了8个字节，所以当前的ebp应为0x7bf8。

# 练习6
1. <br>
 在mmu.h中可以看到gatedesc的定义，一共有64位，8个字节  
 低16位和高16位拼起来是中断处理代码的入口

2. <br>
 见工程中

3. <br>
 见工程中

# Challenge 
1. 在trap/trap.c的trap_dispatch函数中对段寄存器做修改。  
    对T_SWITCH_TOU
    ```
    tf->tf_cs = USER_CS;
    tf->tf_ds = USER_DS;
    tf->tf_es = USER_DS;
    tf->tf_ss = USER_DS;
    ```
    对T_SWITCH_TOK
    ```
    tf->tf_cs = KERNEL_CS;
    tf->tf_ds = KERNEL_DStf->tf_es = KERNEL_DS;
    ```

2. 修改权限  
    对T_SWITCH_TOU
    ```
    tf->tf_eflags |= FL_IOPL_MASK;
    ```
    对T_SWITCH_TOK
    ```
    tf->tf_eflags &= ~FL_IOPL_MASK;
    ```

3. 设置正确的iret时的栈位置  
    对T_SWITCH_TOU
    ```
    *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
    ```
    对T_SWITCH_TOK
    ```
    struct trapframe *switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
    memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
    *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
    ```

4. 在kern/init/init.c的lab1_switch_to_user函数中  
    修改正确的栈地址
    ```
    asm volatile(
            "sub $0x8, %%esp \n"
            "int %0 \n"
            "movl %%ebp, %%esp"
            :
            : "i"(T_SWITCH_TOU)
    );
    ```

5. 在lab1_switch_to_kernel函数中  
    修改正确的栈地址
    ```
    asm volatile(
            "int %0 \n"
            "movl %%ebp, %%esp \n"
            :
            : "i"(T_SWITCH_TOK)
    );
    ```