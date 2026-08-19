# EXP-0095：Decaps运行时H4与完整postprocess

- 日期：2026-08-17
- 状态：`retained`
- 配置：最大H4/support/error RAM，start锁存公开`r/t/byte`几何

## 目标与边界

完成Decaps postprocess的运行时活动几何，使`L -> H4 -> compare -> select -> K`共享最大存储和单SM3服务。
该实验覆盖H4 seed、固定重量采样、dense error布局、完整比较、r2/ciphertext地址和隐式拒绝；不包含统一
decoder/pipeline连接或四档完整KEM golden。

## 实现

`SM3_df`与DRNG Instantiate锁存活动seed byte数；固定重量采样器锁存`3r/t`并保持每个position扫描活动
`t`项。error store只清零活动`3*padded_r_bytes`，按活动`r`和block stride映射支持位置。
流式比较锁存活动error byte数，首个mismatch、decoder结果和payload均不改变消费数。
postprocess在单一start边界锁存全部公开几何，顺序分配error、r2、ciphertext RAM与共享SM3服务。

## 验证与结论

独立Python SM3-DRNG golden下，H4的`r/t=7/1、13/3、521/5`逐项support与dense error byte匹配，成对
payload固定1,348、2,314、3,650拍。活动比较1/3/8 byte分别固定1/3/8拍。
完整小几何postprocess三档正常与`c2`篡改均逐byte匹配正常/隐式拒绝SS，成对固定4,806、5,776、
9,124拍；第三档跨512-bit padding边界。项目TRIKE160运行时verify/postprocess保持209,659/
257,417拍，完整窄I/O Decaps保持4,743,972拍。`make ci-fast`和固定KeyGen/H4/Decaps reference通过；
SM3层次检查保持每个复合顶层一个`sm3_compress`。

运行时postprocess边界保留；统一pipeline连接、四档完整golden和Vivado为`待测`。
