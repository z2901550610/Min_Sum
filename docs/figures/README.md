# 图文件

本目录存放译码器文档使用的图源文件和导出图。

| 文件 | 用途 |
| --- | --- |
| `decoder_datapath.d2` | 译码器数据通路 D2 图源 |
| `decoder_datapath.svg/png` | 译码器数据通路导出图 |
| `scheduler_window_pipeline.svg/png` | 调度窗口流水导出图 |
| `c2v_state_read_pipeline.svg/png` | C2V 状态读取流水导出图 |
| `v2c_update_pipeline.svg/png` | V2C 更新流水导出图 |
| `tile_buffer_pingpong.svg/png` | Tile buffer ping-pong 导出图 |
| `decoder_hardware_architecture_fig2*.drawio` | 硬件架构 Draw.io 图源 |
| `decoder_hardware_architecture_fig2.xml` | 硬件架构 XML 导出 |
| `decoder_hardware_architecture_tikz.tex/pdf` | 硬件架构 TikZ 图源和导出 PDF |

D2 数据通路图渲染命令：

```sh
d2 --layout dagre --pad 40 docs/figures/decoder_datapath.d2 docs/figures/decoder_datapath.svg
```
