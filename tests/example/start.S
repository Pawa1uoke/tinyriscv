    .section .init;               # 定义.init段
    .globl _start;			      # 声明全局符号_start, 在别的文件中也可以调用
    .type _start,@function        # _start是一个函数

_start:                        	  # _start标签, 用来指示start地址
.option push                   	  # 临时性的保存
.option norelax                	  # 不允许链接器松弛
	la gp, __global_pointer$      # 伪指令, 对应auipc和lw; 赋值gp
.option pop                       # 临时性的恢复
	la sp, _sp                    # 将_sp的值赋给sp寄存器
#ifdef SIMULATION 
    li x26, 0x00                  # li s10, 0x00
    li x27, 0x00                  # li s11, 0x00
#endif

	/* Load data section */
	la a0, _data_lma              # 数据段的数据在flash的起始地址
	la a1, _data 				  # 数据段的数据在ram的起始地址
	la a2, _edata                 # 数据段的结束地址
	bgeu a1, a2, 2f
1:                                # 将flash存放的数据搬到ram里
	lw t0, (a0)
	sw t0, (a1)
	addi a0, a0, 4
	addi a1, a1, 4
	bltu a1, a2, 1b
2:

	/* Clear bss section */
	la a0, __bss_start
	la a1, _end
	bgeu a0, a1, 2f
1:                                 # 将bss段的内容清零
	sw zero, (a0)
	addi a0, a0, 4
	bltu a0, a1, 1b
2:

    call _init					   # 伪指令, 对应auipc和jalr; call rd, symbol;PC+8的值保存到rd寄存器, 然后PC设置为symbol值
    call main                      # 进入到C语言的main函数

#ifdef SIMULATION
    li x26, 0x01                   # 设置x26寄存器的值为1, 表示仿真结束
#endif

loop:
    j loop                         # 死循环, 原地跳转
