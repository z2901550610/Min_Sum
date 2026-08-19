# EXP-0098：双行并行residual扫描

- 日期：2026-08-19
- 状态：`retained`
- 基线：EXP-0097
- 配置：四档运行时Decaps，L=32，K=4，C=256

## 目标与假设

residual逐行重算占完整Decaps的40%至56%。相邻两行复用同一support读数，并从译码完成后空闲的
K-sign banked RAM读取两个decision，可在不复制decision存储的条件下降低固定周期。

## 硬件改动边界

checker固定成对处理row，单口syndrome RAM用两拍取得初值；每个support周期发出两个decision地址。
`decoder_top`按两个地址的bank差将第二请求路由到空闲bank，完整符号decision RAM也支持不同bank双读。
error writer仍独占lane 0。访问数量、row配对和最后单行mask只由公开`r/w`决定；同bank请求由断言拒绝。

## 验证与结果

固定预算从`r*(2+6w)+1`变为`ceil(r/2)*(3+6w)+1`。TRIKE160 residual reference为
1,340,836拍，residual 0与单bit扰动重量1通过；小几何成对不同数据的error byte、residual及周期通过。

| Profile | 完整周期 | 相对EXP-0097 |
| --- | ---: | ---: |
| TRIKE160 | 3,415,291 | -28.00% |
| TRIKE256 | 14,941,165 | -25.18% |
| TRIKE384 | 55,654,606 | -22.23% |
| TRIKE512 | 142,148,438 | -20.03% |

固定TRIKE160 pipeline/wrapper为3,406,213/3,415,939拍，正常与三类篡改SS byte golden通过。
四档有效/c2拒绝路径逐byte结果和固定周期通过。Vivado资源、RAM映射、setup/hold与Fmax为`待测`。

## 结论

`retained`。双行扫描保留，物理比较需使用与EXP-0084相同器件、Vivado、XDC和route阶段。
