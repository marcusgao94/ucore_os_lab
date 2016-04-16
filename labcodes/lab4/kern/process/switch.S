.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    # 4(%esp)是prev->context的地址，第一步就是让eax寄存器存了prev->context结构体的地址
    movl 4(%esp), %eax          # eax points to from
    # 按照context结构的顺序，0(%eax)就是eip，第二步把esp放到context结构的eip变量中
    popl 0(%eax)                # save eip !popl
    # 后面依次把各个寄存器的值放到context结构对应的成员变量中
    movl %esp, 4(%eax)
    movl %ebx, 8(%eax)
    movl %ecx, 12(%eax)
    movl %edx, 16(%eax)
    movl %esi, 20(%eax)
    movl %edi, 24(%eax)
    movl %ebp, 28(%eax)

    # restore to's registers
    # 4(%esp)是next->context的地址，第一步就是让eax寄存器保存next->context结构体的地址
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
                                # eax now points to to
    # 按照context结构的顺序，依次把各个成员变量的值放到对应的寄存器中
    movl 28(%eax), %ebp
    movl 24(%eax), %edi
    movl 20(%eax), %esi
    movl 16(%eax), %edx
    movl 12(%eax), %ecx
    movl 8(%eax), %ebx
    movl 4(%eax), %esp

    pushl 0(%eax)               # push eip

    ret

