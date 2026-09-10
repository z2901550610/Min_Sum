# 错题本

只记录有证据放弃的方向：条件、原因、证据与重试条件。成功修改更新所属设计，
测试留自动日志，未完成候选留路线图；不再分配EXP或维护实验流水账。

| 方向与条件 | 放弃原因和证据 | 何时值得重试 |
| --- | --- | --- |
| K=3 base_sign与slot 0打包 | 省16 BRAM Tile但整体WNS降0.093 ns，当时性能优先，撤回 | 存储优先级或时序余量改变 |
| ram_t双缓冲地址交织 | BRAM Tile不变，LUT增342 | 实际原生RAM几何能减少Tile |
| K-sign valid并入统一比较键 | LUT增164、WNS降0.339 ns | 比较树或映射方式改变 |
| correction线性计数/K RAM预译码 | 当时实现时序退化，撤回 | 能切断实际关键路径并同条件复测 |
| delta pair合并到单块TDP | 同拍2读1写需三个独立地址，双端口无法维持吞吐 | 调度/端口预算改变，或允许固定额外周期 |
| ram_m拆成9+9 bit | K=3实测BRAM反增，未再跑K=4 | 原生宽深几何或端口绑定改变 |
| ram_accum公共地址广播 | L16/L32均时序退化，资源收益不稳定 | 布局/扇出机制改变；不能套用ram_t收益 |
| 共享H4变量除法/取模寻址 | 首轮统一KEM出现189级逻辑路径，不能形成100 MHz基线；EXP-0111 | 改为无深除法映射并重新route；原报告provenance不完整 |
| 64-bit base递归depth 2/3 | Yosys独立base LC为2690/3312，高于depth 1的1766；EXP-0117 | base宽度/器件/重组结构改变；仅本地估计 |
| EXP-0121 compare-select三元mux | 定向及proof/cover通过，Yosys无收益，保留显式mask | 综合映射或结构改变后再测，不能据此声称物理等价 |
| 直接折叠的双读RAM绑定 | 求逆RAMB36本地估计4→7，原地XOR/恢复回到4；EXP-0123 | 端口结构或原生RAM成本改变 |

## 历史查询

上表数字属于当时配置，不能作为当前RTL或物理结论。旧EXP、矩阵和归档图保存在
Git提交`a17f0f1b7c24ca6ed832fc4497d26d85fa36c656`，按需只读查阅：

```sh
git ls-tree -r --name-only a17f0f1 docs/experiments docs/archive reports/qor
git show a17f0f1:docs/design/optimization_exploration_history.md
```

单项全文用`git show a17f0f1:<上面列出的路径>`；旧EXP/RUN编号仅用于追溯。
