    .global     _tx_thread_system_stack_ptr
    .global     _tx_initialize_unused_memory
    .global     __RAM_segment_used_end__
    .global     _tx_timer_interrupt
    .global     __main
    .global     __tx_SVCallHandler
    .global     __tx_PendSVHandler
    .global     g_pfnVectors
    .global     __tx_NMIHandler                     @ NMI
    .global     __tx_BadHandler                     @ HardFault
    .global     __tx_SVCallHandler                  @ SVCall
    .global     __tx_DBGHandler                     @ Monitor
    .global     __tx_PendSVHandler                  @ PendSV
    .global     __tx_SysTickHandler                 @ SysTick
    .global     __tx_IntHandler                     @ Int 0

SYSTEM_CLOCK          =   80000000 @ 系统时钟
TX_TICK_PER_SECOND    =   1000     @ 1s 的时钟数
SYSTICK_CYCLES        =   ((SYSTEM_CLOCK / TX_TICK_PER_SECOND) -1) @滴答定时器 reload 值

    .text 32
    .align 4
    .syntax unified

@VOID   _tx_initialize_low_level(VOID)
@{
    .global  _tx_initialize_low_level
    .thumb_func
_tx_initialize_low_level:

@    关闭全局中断
    CPSID   i

@   _tx_initialize_unused_memory = __RAM_segment_used_end__ + 4
@   设置未使用的 RAM 指针

    LDR     r0, =_tx_initialize_unused_memory       @ Build address of unused memory pointer
    LDR     r1, =__RAM_segment_used_end__           @ Build first free address
    ADD     r1, r1, #4                              @
    STR     r1, [r0]                                @ Setup first unused memory pointer

@   设置中断向量表的偏移 SCB->VTOR = g_pfnVectors  g_pfnVectors 为程序的起始地址：0x08000000
    MOV     r0, #0xE000E000                         @ Build address of NVIC registers
    LDR     r1, =g_pfnVectors                           @ Pickup address of vector table
    STR     r1, [r0, #0xD08]                        @ Set vector table address

@   _tx_thread_system_stack_ptr = g_pfnVectors
    LDR     r0, =_tx_thread_system_stack_ptr        @ Build address of system stack pointer
    LDR     r1, =g_pfnVectors                           @ Pickup address of vector table
    LDR     r1, [r1]                                @ Pickup reset stack pointer
    STR     r1, [r0]                                @ Save system stack pointer

@   DWT->CTRL 寄存器 CYCCNTENA 位置 1
    LDR     r0, =0xE0001000                         @ Build address of DWT register
    LDR     r1, [r0]                                @ Pickup the current value
    ORR     r1, r1, #1                              @ Set the CYCCNTENA bit
    STR     r1, [r0]                                @ Enable the cycle count register

@   SysTick->LOAD = SYSTICK_CYCLES 设置滴答定时器
    MOV     r0, #0xE000E000                         @ Build address of NVIC registers
    LDR     r1, =SYSTICK_CYCLES
    STR     r1, [r0, #0x14]                         @ Setup SysTick Reload Value

@   SysTick->CTRL 的 0 1 2 三个位置 1 使能滴答定时器
    MOV     r1, #0x7                                @ Build SysTick Control Enable Value
    STR     r1, [r0, #0x10]                         @ Setup SysTick Control


@   设置中断优先级
    LDR     r1, =0x00000000                         @ Rsrv, UsgF, BusF, MemM
    STR     r1, [r0, #0xD18]                        @ Setup System Handlers 4-7 Priority Registers

    LDR     r1, =0xFF000000                         @ SVCl, Rsrv, Rsrv, Rsrv
    STR     r1, [r0, #0xD1C]                        @ Setup System Handlers 8-11 Priority Registers
                                                    @ Note: SVC must be lowest priority, which is 0xFF

    LDR     r1, =0x40FF0000                         @ SysT, PnSV, Rsrv, DbgM
    STR     r1, [r0, #0xD20]                        @ Setup System Handlers 12-15 Priority Registers
                                                    @ Note: PnSV must be lowest priority, which is 0xFF

@
@    /* Return to caller.  */
@
    BX      lr
@}
@

@/* Define shells for each of the unused vectors.  */
@
    .global  __tx_BadHandler
    .thumb_func
__tx_BadHandler:
    B       __tx_BadHandler

@ /* added to catch the hardfault */

    .global  __tx_HardfaultHandler
    .thumb_func
__tx_HardfaultHandler:
    B       __tx_HardfaultHandler


@ /* added to catch the SVC */

    .global  __tx_SVCallHandler
    .thumb_func
__tx_SVCallHandler:
    B       __tx_SVCallHandler


@ /* Generic interrupt handler template */
    .global  __tx_IntHandler
    .thumb_func
__tx_IntHandler:
@ VOID InterruptHandler (VOID)
@ {
    PUSH    {r0, lr}
#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY
    BL      _tx_execution_isr_enter             @ Call the ISR enter function
#endif

@    /* Do interrupt handler work here */
@    /* BL <your C Function>.... */

#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY
    BL      _tx_execution_isr_exit              @ Call the ISR exit function
#endif
    POP     {r0, lr}
    BX      LR
@ }

@ /* System Tick timer interrupt handler */
    .global  __tx_SysTickHandler
    .global  SysTick_Handler
    .thumb_func
__tx_SysTickHandler:
    .thumb_func
@ 滴答定时器的中断服务函数
SysTick_Handler:
@ VOID TimerInterruptHandler (VOID)
@ {
@
    PUSH    {r0, lr}
#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY
    BL      _tx_execution_isr_enter             @ Call the ISR enter function
#endif
    BL      _tx_timer_interrupt
#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY
    BL      _tx_execution_isr_exit              @ Call the ISR exit function
#endif
    POP     {r0, lr}
    BX      LR
@ }


@ /* NMI, DBG handlers */
    .global  __tx_NMIHandler
    .thumb_func
__tx_NMIHandler:
    B       __tx_NMIHandler

    .global  __tx_DBGHandler
    .thumb_func
__tx_DBGHandler:
    B       __tx_DBGHandler
