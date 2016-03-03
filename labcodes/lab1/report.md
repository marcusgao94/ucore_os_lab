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
符合规范的硬盘主引导扇区，在sign.c可以看到，最后两个字分别为0x55和0xAA

- #练习2

