# EXP-0091：Decaps运行时support排序与decoder装载

- 日期：2026-08-17
- 状态：`retained`
- 配置：最大`r/w`存储，三块support，公开活动几何

## 目标与边界

让同一最大几何support排序器和decoder装载桥按已锁存profile处理活动`r/w`。该实验覆盖三块support
排序和syndrome逐bit写入，不包含输入存储support预取、decoder内部几何、error writer或residual。

## 实现

`trike_fixed_support_sorter`增加可选运行时几何，在start锁存公开`r/w`。每块固定接受/输出`w`项并执行
`w*(w-1)/2`次相邻compare-swap；坐标只控制数据mux，不影响状态深度。

`trike_decoder_load_adapter`把同一活动几何传给排序器，并按活动`r`固定展开little-endian syndrome word。
默认模式使用编译期几何，现有pipeline显式连接零值运行时端口。

## 验证与结论

运行时测试覆盖`r/w=7/1、13/3、23/5`，每档两套payload。排序器周期分别为7/28/61拍，组合装载桥
周期分别为22/50/94拍；逐块升序坐标、diag、syndrome地址/数据、读写次数和单次decoder start均通过，
成对payload周期相等。默认排序器43拍测试、默认装载桥测试和`make check-rtl`通过。
完整TRIKE160 Decaps参考保持4,743,972拍，`make ci-fast`通过。

运行时控制边界保留；最大输入存储直连、四档decoder集成和Vivado资源/时序为`待测`。
