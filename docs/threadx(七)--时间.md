## threadx--时间

### 时间相关 `API` 汇总

[tx_time_get](####tx_time_get)

[tx_time_set](####tx_time_set)

#### tx_time_get

函数原型

```c
ULONG tx_time_get(VOID);
```
功能：获取当前系统的 `tick` 值

#### tx_time_set

函数原型

```c
VOID tx_time_set(ULONG new_time);
```
功能：设置当前系统的 `tick` 值