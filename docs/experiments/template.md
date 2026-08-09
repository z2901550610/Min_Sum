# EXP-xxxx：实验名称

- 状态：`proposed | functional-pass | vivado-pending | retained | rejected | incomparable | superseded`
- 基线/对照：`EXP-xxxx` / `RUN-...`
- 配置键：`top | profile | L | K | memory geometry`

## 目标与假设

用一至两句话说明要改变的物理数据路径、RAM几何、固定周期或关键路径。

## 改动边界

- 数据路径/RAM生命周期：
- 公开控制与固定周期影响：
- 不在本实验范围的内容：

## 验证

| 层 | 配置 | 结果 |
| --- | --- | --- |
| RTL/byte golden | | `PASS | FAIL | pending` |
| 固定周期 | | `PASS | FAIL | pending` |
| K=3/K=4与参数覆盖 | | `PASS | FAIL | pending` |
| Vivado | `RUN-...` | `PASS | FAIL | pending` |

## 结论

`retained | rejected | pending | incomparable | superseded`，并写明最小必要理由。
