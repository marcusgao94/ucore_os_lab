# 练习1

 此时只是初始化TCB空间，而没有实际线程与其对应，大部分变量的值实际上是在真正调用do_fork创建新线程的时候赋值，所以此处变量值基本都赋成空或0

1. 
  context变量保存的是当前进程的上下文，其中包括eip，esp，ebx，ecx，edx，esi，edi，ebp寄存器的值，用于保存当前进程的运行状态。该变量主要用于切换进程，在进程调度切换进程时需要根据context中保存的值来切换至新的进程。   

  trapframe变量保存了中断发生时的进程的相关寄存器的信息，其中既有硬件保存的信息，也有软件需要保存的信息。trapframe用于处理中断的时候，在本实验中主要在do_fork时设置好对应的函数、参数、返回值等信息，通过forkrets完成fork操作，并将运行环境切换到trapframe中设置好信息，随之切换到kernel_thread_entry开始运行地线程。

# 练习2

首先调用alloc_proc获得一块空间，然后为进程分配栈空间，复制父进程的栈数据和上下文到子进程，将子进程添加到进程链表，将状态设置为唤醒状态，最后返回进程号。

1. 
  是，通过get_pid()函数为每个进程分配一个唯一的pid。当新进程创建需要分配id时，get_pid()函数首先将上一个分配出去的id加1得到新id，若该id超过max限制则置为1。然后遍历所有线程组成的链表，寻找next_safe（比上个分配出去的id大的最小id）并将其与新id比较，若next_safe大于新id，则说明新id未被占用可以分配，直接分配之；否则将新id加1，重复上述过程，直到找到一个合法的id。因此，这样分配出去的所有id都是唯一的。

# 练习3

1. 
  分析proc_run函数

  ```
  if (proc != current) {
    bool intr_flag;
    struct proc_struct *prev = current, *next = proc;
    local_intr_save(intr_flag);                        //关闭中断
    {
        current = proc;                                //设置proc为当前线程
        load_esp0(next->kstack + KSTACKSIZE);          //载入新的esp，完成栈切换
        lcr3(next->cr3);                               //载入新的CR3，完成页表基址切换
        switch_to(&(prev->context), &(next->context)); //完成上下文切换
    }
    local_intr_restore(intr_flag);                     //打开中断
  }
  ```

2. 
  创建运行了2个内核线程。分别是idleproc和init_main

3. 
  分别是起到关闭中断和打开中断的作用，能够保护这两条命令中间的语句正常执行不被打断，确保栈、页表基址、上下文切换正确无误，不出异常。