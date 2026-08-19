# EXP-0093：Decaps运行时decoder后检查

- 日期：2026-08-17
- 状态：`retained`
- 配置：最大error/support/syndrome RAM，运行时公开`r/w`

## 目标与边界

把decoder单decision读口依次连接到padded error writer和独立residual checker。该实验覆盖活动几何、
error RAM布局、共享读口次序和固定周期，不包含运行时postprocess或四档完整decoder连接。

## 实现

error writer在start锁存`r`，只清零`3*ceil(r/512)*64` byte并扫描`3r`项判决。residual checker锁存
`r/w`，每row固定读取`3w`项；support RAM保持最大`W`块跨度，块间预取跳到下一物理块基址，decision
列地址使用活动`r`拼接。`trike_decaps_decoder_postcheck_core`锁存一次几何并顺序分配decision端口。

## 验证与结论

`r/w=7/1、13/3、521/5`的组合后检查分别固定275、497、18,625拍；第三档跨越512-bit padding边界。
每档两套decision/support payload逐byte匹配error RAM，一套residual为0，另一套单bit扰动重量为1，
成对周期一致。项目TRIKE160运行时residual reference保持2,668,869拍。`make ci-fast`通过。

运行时decoder后检查边界保留；运行时postprocess长度、统一decoder连接、四档golden和Vivado为`待测`。
