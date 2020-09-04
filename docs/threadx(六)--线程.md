## thread-线程

小知识：`_txe_thread_create` 一般会做参数检查 `_tx_thread_create` 实现具体的功能

### `API` 官方文档

[API手册](https://docs.microsoft.com/en-us/azure/rtos/threadx/appendix-a)

### 线程相关 `API` 汇总

[tx_thread_create](####tx_thread_create)

[tx_thread_delete](####tx_thread_delete)

[tx_thread_suspend](####tx_thread_suspend)

[tx_thread_resume](####tx_thread_resume)

[tx_thread_sleep](####tx_thread_sleep)

[tx_thread_relinquish](####tx_thread_relinquish)

[tx_thread_priority_change](####tx_thread_priority_change)

[tx_thread_time_slice_change](####tx_thread_time_slice_change)

[tx_thread_reset](####tx_thread_reset)

[tx_thread_terminate](####tx_thread_terminate)

#### tx_thread_create

函数原型
```c
UINT  tx_thread_create(TX_THREAD *thread_ptr, 
                       CHAR *name_ptr, 
                       VOID (*entry_function)(ULONG id), 
                       ULONG entry_input,
                       VOID *stack_start, 
                       ULONG stack_size, 
                       UINT priority, 
                       UINT preempt_threshold,
                       ULONG time_slice, 
                       UINT auto_start)
```

函数各个参数及含义

| 参数              | 含义                                                                                                                                                                                                  |
|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| thread_ptr        | 线程控制块指针                                                                                                                                                                                        |
| name_ptr          | 线程名指针                                                                                                                                                                                            |
| entry_function    | 线程入口函数，当线程从此函数返回时，它将处于已完成状态并无限期挂起                                                                                                                                    |
| entry_input       | 线程入口函数参数                                                                                                                                                                                      |
| stack_start       | 线程栈的起始地址                                                                                                                                                                                      |
| stack_size        | 线程栈大小                                                                                                                                                                                            |
| priority          | 线程优先级，值的范围为 `0` 到 `TX_MAX_PRIORITES-1`，其中值 `0` 表示最高优先级                                                                                                                         |
| preempt_threshold | 禁止抢占优先级阈值，`0` 到 `TX_MAX_PRIORITIES-1`。只有高于此级别的优先级才能抢占此线程。此值必须小于或等于指定的优先级。等于线程优先级的值禁用抢占阈值，设为 `0` 时，禁止抢占，此值在运行时可动态改变 |
| time_slice        | 时间片，使用抢占阈值可禁用时间片。时间片值范围为 `1` 到 `0xFFFF`（含）。值 `TX_NO_TIME_SLICE`（值为 `0`）将禁用此线程的时间片。                                                                       |
| auto_start        | 自动启动选项，设置线程是立即启动还是处于挂起状态，选项包括 `TX_AUTO_START(0x01)` 和 `TX_DONT_START(0x00)`。如果 `TX_DONT_START`，应用程序稍后必须调用 `tx_thread_resume` 才能运行线程。               |

#### tx_thread_delete

函数原型

```c
UINT  tx_thread_delete(TX_THREAD *thread_ptr)
```
函数各个参数及含义

| 参数       | 含义                   |
|------------|------------------------|
| thread_ptr | 要删除的线程控制块指针 |


#### tx_thread_suspend

函数原型
```c
UINT  tx_thread_suspend(TX_THREAD *thread_ptr)
```
函数各个参数及含义

| 参数       | 含义                   |
|------------|------------------------|
| thread_ptr | 要挂起的线程控制块指针 |

#### tx_thread_resume

函数原型

```c
UINT  tx_thread_resume(TX_THREAD *thread_ptr)
```

函数各个参数及含义

| 参数       | 含义                   |
|------------|------------------------|
| thread_ptr | 要恢复的线程控制块指针 |

#### tx_thread_sleep

函数原型

```c
UINT  tx_thread_sleep(ULONG timer_ticks)
```

函数各个参数及含义

| 参数        | 含义                 |
|-------------|----------------------|
| timer_ticks | 线程要挂起的 tick 数 |

#### tx_thread_relinquish

函数原型

```c
void tx_thread_relinquish(void)
```
作用：将当前 `CPU` 的使用权让出给同优先级的线程或更高优先级的线程，如果没有同优先级或更高优先级的线程就绪，此函数简单的返回。

#### tx_thread_priority_change

函数原型

```c
UINT  tx_thread_priority_change(TX_THREAD *thread_ptr, UINT new_priority, UINT *old_priority)
```

函数参数及含义

| 参数         | 含义                   |
|--------------|------------------------|
| thread_ptr   | 要改变优先级的线程句柄 |
| new_priority | 新的优先级             |
| old_priority | 旧的优先级             |

#### tx_thread_time_slice_change

函数原型
```c
UINT  tx_thread_time_slice_change(TX_THREAD *thread_ptr, ULONG new_time_slice, ULONG *old_time_slice)
```

函数参数及含义

| 参数           | 含义                   |
|----------------|------------------------|
| thread_ptr     | 要改变时间片的线程句柄 |
| new_time_slice | 新的时间片             |
| old_time_slice | 旧的时间片             |


#### tx_thread_reset

函数原型

```c
UINT  tx_thread_reset(TX_THREAD *thread_ptr)
```
函数参数及含义

| 参数       | 含义               |
|------------|--------------------|
| thread_ptr | 要复位的线程的句柄 |

注意：应用程序调用此函数之后必须调用 `tx_thread_resume` 来让线程运行起来

#### tx_thread_terminate

函数原型

```c
UINT  tx_thread_terminate(TX_THREAD *thread_ptr)
```
函数参数及含义

| 参数       | 含义               |
|------------|--------------------|
| thread_ptr | 要终止的线程的句柄 |

注意：线程终止之后就不能再运行，除非删除或重新创建

