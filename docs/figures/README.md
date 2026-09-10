# 图文件

本目录存放现役译码器文档使用的图源文件和导出图。其余历史图文件位于 [../archive/figures/](../archive/figures/)，不再使用。

| 文件 | 用途 |
| --- | --- |
| `decoder_datapath.d2` | 译码器数据通路 D2 图源 |
| `decoder_datapath.svg/png` | 译码器数据通路导出图 |
| `ksign_results_summary.csv` | K-sign DFR/FLS数据快照 |
| `trike*_logdfr*.png`、`trike*_4bit_compare.png` | K-sign参数与DFR对比图 |
| `trike_dense_mul_arch.tex/pdf` | TRIKE 稠密多项式乘法器微架构 TikZ 图源与导出 |

D2 数据通路图渲染命令：

```sh
d2 --layout dagre --pad 40 docs/figures/decoder_datapath.d2 docs/figures/decoder_datapath.svg
```
