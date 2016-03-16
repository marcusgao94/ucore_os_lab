# 练习1
按照代码中给出的注释一步步进行。  

1. 
    先修改default_init_memmap函数。首先对每个page初始化并加入空闲列表，从基地址base开始连续插入地址，建立好free_list链表

2. 
    修改default_alloc_pages。如果需要的块数大于空闲的块数，直接返回空。遍历链表，找一个连续空闲块数大于n的页，找到后把n个块从free_list中删除，更新它们的property，ref信息。如果遍历链表结束还没找到就返回空。

3. 
    修改default_free_pages。先把这n个释放掉的快插入free_list。然后检查后面的块是否可以合并，如果是就合并。再检查新释放出来的n个块是否在一段空闲块的后面，如果是就和前面的合并。

4. 进一步改进的空间  
    由于在代码中多次要遍历freelist查找合适的地址和内存块，目前遍历复杂度为O(n)，若能使用平衡树结构维护freelist的信息，能够将以上查找过程的复杂度优化到O(logn)。此外，在现有的页机制下都是各页维护各自的参数，如果改为按块维护，效率也会有所提升。

# 练习2
按照注释中的提示，首先根据虚拟地址找到对应一级页表的表项，判断该表项是否存在，如果不存在判断是否需要分配二级页表，若需要则设置好相关参数，得到页目录项。根据最后返回的项，将物理地址转化为虚拟地址，最后根据la得到对应的页表项。整个过程比较简单，需要注意的是返回值比较复杂。需要先将后十二位置零，转换成kernel虚址二级页表基址，然后加上偏移，返回找到二级页表项的地址。

1. 
    在mmu.h文件中可找到以下关于每个组成部分的含义说明：

    ```
    #define PTE_P           0x001                   // Present  
    #define PTE_W           0x002                   // Writeable  
    #define PTE_U           0x004                   // Use  
    #define PTE_PWT         0x008                   // Write-Throug  
    #define PTE_PCD         0x010                   // Cache-Disabl  
    #define PTE_A           0x020                   // Accesse  
    #define PTE_D           0x040                   // Dirt  
    #define PTE_PS          0x080                   // Page Size  
    #define PTE_MBZ         0x180                   // Bits must be zero  
    #define PTE_AVAIL       0xE00                   // Available for software use 
                                                    // The PTE_AVAIL bits aren't used by the kernel or interpreted by the  
                                                    // hardware, so user processes are allowed to set them arbitrarily.  
    ```

    从上到下一次是从最低位到最高位

2.  
    硬件先发出信号，将控制权限交给操作系统。操作系统判断异常种类，若为页缺失则从硬盘取数据放到内存中，否则需要转入中断处理服务并报错。

# 练习3
首先确保页存在，然后用pte2page函数找到pte所在的页。把这个页的ref减1.如果已经没有ref了，就释放掉这一页。然后释放pte指向的页。最后由于页表改变，要清空tlb

1. 
    Page的全局变量为pages。 pages变量对应的是每一个页的虚拟地址，而页表项和页目录项都指向一个页，它们保存的是页的物理地址，通过pte2page、pde2page可以将pte、pte中保存的页映射到page中的虚拟地址对应的页。

2. 
    需要修改pages变量的地址，如果把它的虚拟地址映射到0处就实现了page的虚拟地址等于物理地址。
