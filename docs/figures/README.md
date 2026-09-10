# 图文件

现役译码器文档使用的图源与导出图。

| 文件 | 用途 |
| --- | --- |
| `decoder_datapath.d2` | 译码器数据通路 D2 图源 |
| `decoder_datapath.svg/png` | 译码器数据通路导出图 |
| `ksign_results_summary.csv` | K-sign DFR/FLS数据快照 |
| `trike*_logdfr*.png` | K-sign/FLS 外推图 |
| `trike_dense_mul_arch.tex/pdf` | TRIKE 稠密多项式乘法器微架构 |

```sh
d2 --layout dagre --pad 40 docs/figures/decoder_datapath.d2 docs/figures/decoder_datapath.svg
```
