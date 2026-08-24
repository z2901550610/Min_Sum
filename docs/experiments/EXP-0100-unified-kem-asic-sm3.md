# EXP-0100 单发射统一KEM ASIC与全局SM3

## 目标与假设

KeyGen、Encaps和Decaps由公开2-bit operation选择，一次事务只运行一个阶段。参考Racing BIKE统一硬件的
单FSM、共享哈希/乘法资源与静态RAM分配方式，先把三个阶段内部SM3 lane提升为一个芯片级物理服务。

## 硬件边界

- 新增`trike_kem_asic_top`和`trike_kem_operation_control`，统一8-bit输入及PK/SK/CT/SS输出。
- operation在空闲start边界锁存，busy期间不切换；三个stage start严格one-hot。
- Decaps的H验证状态为一次复位一笔事务；同一复位周期内第二个Decaps命令固定返回error。
- KeyGen、Encaps和Decaps postprocess使用`USE_EXTERNAL_COMPRESS`连接唯一`trike_sm3_service`。
- 三阶段多项式核、采样器和持久/工作RAM保留独立层次；该实验不声明这些资源已经合并。
- 官方TRIKE-2 KeyGen/Encaps为`r=15581`，项目K-sign Decaps为四档运行时参数；不形成同参数端到端KEM结论。

## 验证与结果

- `tb_trike_kem_operation_control`覆盖三种operation、busy期间重启和非法operation。
- SymbiYosys/Z3证明start one-hot与busy期间operation稳定，五类cover witness可达。
- Verilator完整层次JSON统计`trike_kem_asic_top`恰好一个`sm3_compress`。
- 同一层次统计包含4个参数化`trike_poly_mul_core`实例，作为下一服务化实验的结构基线。
- KeyGen外置SM3保持PK/SK byte golden与53,995,036拍。
- Encaps外置SM3保持CT/SS byte golden与2,378,447拍。
- Decaps postprocess外置SM3保持有效/拒绝golden与257,417拍。
- Slang与fatal-warning Verilator通过；Vivado资源、Fmax与功耗为`待测`。

## 结论

保留。统一ASIC具备公开单发射控制和一个物理SM3 lane，功能与固定周期边界保持。下一资源收敛项为运行时
几何多项式服务与scratch RAM生命周期分配；必须用同条件实现结果评估mux/布线代价后再保留。
