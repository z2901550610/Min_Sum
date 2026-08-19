# EXP-0094：Decaps运行时pseudohash长度底座

- 日期：2026-08-17
- 状态：`retained`
- 配置：最大消息几何，start锁存公开活动byte数

## 目标与边界

为四档Decaps的`L(e')`和`K(selected||ciphertext)`建立运行时长度底座。该实验覆盖SM3/HMAC/
pseudohash padding、消息重放地址和KDF ciphertext地址，不包含H4的`r/t`采样、error store或完整比较。

## 实现

`sm3_hash_stream`锁存活动输入byte数，并据此确定末byte、padding块和64-bit消息长度域。
`hmac_sm3_64byte_key_stream`保持64-byte key和固定outer消息，inner消息长度使用活动payload；
`trike_pseudohash512_stream`的HMAC、H1两遍共同使用同一活动长度。固定模式仍使用编译期上界。
消息恢复与KDF分别锁存error/ciphertext byte数，公开地址只在对应活动边界回卷。

## 验证与结论

独立OpenSSL SM3 golden覆盖1、55、56、64、65、127 byte，跨越SM3单/双padding block边界，六项512-bit
pseudohash digest全部匹配；连续输入周期分别为1,066、1,410、1,412、1,428、1,430、1,790拍。
项目TRIKE160消息恢复与KDF在运行时模式下逐byte匹配参考结果，分别为28,431和19,323拍；固定复合
postprocess保持257,417拍，完整窄I/O Decaps保持4,743,972拍。`make ci-fast`与完整Decaps reference通过。

运行时长度底座保留；H4采样/store/比较运行时几何、四档完整postprocess和Vivado为`待测`。
