# EXP-0096：四档运行时Decaps流水线集成

- 日期：2026-08-18
- 状态：`retained`
- 配置：`TRIKE_UNIFIED_PARAMS`最大几何，L=32，K=4，C=256

## 目标与边界

把运行时输入存储、syndrome/decoder装载、固定7轮decoder、decoder后检查和完整postprocess接成一个
窄I/O事务。公开profile只在start边界选择；每档活动RAM范围和固定调度由锁存描述符控制。

## 实现

`trike_decaps_runtime_pipeline_core`管理外部decoder接口，按输入/译码、error写出、residual扫描和
postprocess顺序分配RAM与decision读口。单口ciphertext RAM在message阶段预取32-byte c2，在KDF阶段
重放完整活动ciphertext，两段读地址由公开FSM互斥。

`trike_decaps_unified_core`接入具备运行时profile调度的`decoder_top`；
`trike_decaps_runtime_synth_top`提供2-bit profile、8-bit `SK || CT`和8-bit SS物理入口，每次复位接受一项事务。

## 验证与结论

项目TRIKE160 seed-1正常及u/v/c2首bit篡改均逐byte匹配正常或隐式拒绝SS，四条路径固定
4,743,324拍。四档统一K=4 decoder seed-1分别为337,245、1,252,957、3,866,043、8,538,564拍，
均完成7轮、输出重量263/429/659/877、residual 0且精确恢复。

`make ci-fast`、新增顶层Verilator/Slang elaboration和`git diff --check`通过。四档decoder结果与
TRIKE160完整KEM golden属于分层证据；TRIKE256/384/512完整KEM golden及新顶层Vivado均为`待测`。
