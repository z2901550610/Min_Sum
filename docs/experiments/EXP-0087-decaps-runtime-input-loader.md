# EXP-0087：Decaps四档运行时输入事务前端

- 日期：2026-08-13
- 状态：`retained`
- 配置：`TRIKE_UNIFIED_PARAMS`，四档项目Min-Sum参数，8-bit `SK || CT`

## 目标与边界

为完整四档Decaps建立公开profile锁存、分档字节布局和最大几何RAM写接口。该实验只覆盖输入生命周期；
syndrome、residual、error writer和postprocess仍使用编译期参数，未形成四档端到端Decaps。

## 实现

`trike_decaps_profile_config`由2-bit公开profile产生`r/w/t`、word数、padded error尺寸和SK/CT长度。
`trike_decaps_input_loader`仅在`i_start`锁存profile；事务期间profile输入变化不影响接受字节数与地址窗口。
loader依次写support、t0、r2、sigma2、u、v和完整ciphertext接口，H0与sigma按格式固定消费。

| profile | 输入byte | support写 | t0/u/v word写 | r2写 | CT写 | error byte |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| TRIKE160 | 8,386 | 105 | 197 | 1,574 | 3,180 | 4,800 |
| TRIKE256 | 19,751 | 165 | 475 | 3,799 | 7,630 | 11,520 |
| TRIKE384 | 40,952 | 249 | 997 | 7,972 | 15,976 | 24,000 |
| TRIKE512 | 68,168 | 333 | 1,669 | 13,348 | 26,728 | 40,128 |

## 验证与结论

`make test-trike-decaps-input-loader`对每档运行两组不同payload，检查profile锁存、连续写地址、精确写次数
及`input_bytes+1`的start/done周期，全部通过。`make ci-fast`通过；既有TRIKE160 wrapper四路径回归仍为
4,743,972拍并通过byte golden。该前端保留为四档wrapper集成边界；Vivado资源与时序为`待测`，完整
四档golden与固定周期为`待测`。
