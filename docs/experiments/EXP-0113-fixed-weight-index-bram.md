# EXP-0113：固定重量采样索引存储BRAM化

## 目标与假设

统一KEM最大几何固定重量采样器保存`877 x 19-bit`索引。显式同步`ram_bram`边界可让Vivado映射
Block RAM，降低FF数量和共享采样区域的布线拥塞，同时保持Reference C扫描次序与固定周期。

## 硬件边界

- `trike_fixed_weight_sampler`使用一个简单双口同步RAM保存已选择索引。
- 每个position仍接收一个32-bit随机字并扫描全部公开`weight`项。
- 读地址、比较、最后一项写入和输出握手的状态序列保持不变。
- 数据阵列不复位；地址大于当前position的条目均已在本事务的公开固定窗口中写入。

## 验证与结论

- `make check-rtl`与`make ci-fast`通过。
- 定向sampler/DRNG/H4单测通过，周期分别保持40/1,448/2,313拍（测试几何）。
- KeyGen四种服务组合保持53,995,036拍；Encaps三种组合保持2,378,447拍；Decaps postprocess
  三种组合保持257,417拍，全部通过byte golden或reference检查。
- [RUN-20260825-04](../../reports/vivado/manifests/RUN-20260825-04-trike-kem-asic-gui.toml)的层次报告确认
  `u_sampler_service/u_sampler/u_index_mem`映射为1个RAMB36，`u_sampler`为338 LUT、143 FF和1个RAMB36。
- 该GUI运行整体为113,484 LUT、106,282 FF、40,061 Slice和655 Block RAM Tile；内部setup WNS为
  `-3.914 ns`，最差路径转移到共享SM3结果寄存器到Encaps摘要寄存器的全局布线。
- Windows源码revision、compile defines和XDC文件名未嵌入报告，因而只确认目标层次的BRAM映射，
  不把整体资源变化作为相对RUN-20260825-02的严格增减量。
- 方案保留；下一物理优化边界是保持SM3握手周期不变的结果寄存器复制与局部扇出。
