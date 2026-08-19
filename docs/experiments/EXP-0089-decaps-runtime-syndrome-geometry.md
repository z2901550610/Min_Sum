# EXP-0089：Decaps运行时syndrome环几何

- 日期：2026-08-13
- 状态：`retained`
- 配置：最大几何乘法核，公开运行时`r/w/word`活动上界

## 目标与边界

让syndrome算术在同一最大几何实例中按已锁存profile计算不同环长度。该实验覆盖运行时环乘和syndrome
控制，不包含EXP-0088存储读口直连、support排序、residual或postprocess。

## 实现

`trike_poly_mul_core`增加可选`RUNTIME_GEOMETRY`模式，在start边界锁存公开`r`、word数和稀疏重量。
活动几何控制操作数加载、product/result清零、稠密归约、稀疏地址回卷、末word mask和输出长度。
默认模式仍使用编译期参数，KeyGen、Encaps和求逆器接口显式连接零值运行时端口。

`trike_decaps_syndrome_core`同样锁存公开活动几何，并把该边界传给共享乘法核；H0/t0/u/v接受数、
中间syndrome RAM范围和输出last均只由公开profile决定。

## 验证与结论

小几何runtime golden覆盖`r=7,w=2`、`r=13,w=3`和`r=23,w=5`，每组使用两套不同payload；逐word
syndrome与testbench环乘模型一致，同配置周期成对相等。独立多项式reference保持dense 1,967,372拍、
sparse 69,366拍；TRIKE syndrome reference保持2,038,763拍并逐word通过。`make check-rtl`通过。
该运行时算术边界保留；最大四档完整syndrome周期与Vivado资源/时序为`待测`。
