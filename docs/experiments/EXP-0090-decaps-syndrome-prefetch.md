# EXP-0090：Decaps输入存储到syndrome固定预取

- 日期：2026-08-13
- 状态：`retained`
- 配置：最大几何输入RAM，公开profile活动范围，64-bit word

## 目标与边界

把EXP-0088的support/t0/u/v同步读口连接到EXP-0089的运行时syndrome核。该实验覆盖完整输入装载、
固定预取和syndrome运算，不包含support排序、decoder、residual或postprocess。

## 实现

`trike_decaps_syndrome_prefetch`按`h0 -> t0 -> u -> v`顺序读取；每项使用独立FETCH/DATA状态，
valid等待期间保持BRAM输出且不重复发读请求。weight与word数只在start锁存，访问次数由公开profile固定。

`trike_decaps_syndrome_store_core`连接预取器和运行时syndrome，`trike_decaps_input_syndrome_core`先完整
接受`SK || CT`，再单次启动同步预取和算术，避免输入写入与运算读取争用同一RAM端口。

## 验证与结论

小几何`r=7/13/23`逐word匹配独立环乘模型；每档两套payload的support/t0/u/v读次数与周期相等。
最大RAM几何上的项目TRIKE160端到端事务接受8,386 byte、输出197个word，两套payload均匹配golden，
从start到done固定1,349,546拍。`make check-rtl`通过。

固定预取边界保留；TRIKE256/384/512完整syndrome长回归和Vivado资源/时序为`待测`。
