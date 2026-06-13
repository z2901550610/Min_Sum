# Decoder Parameter Results

本文档记录各 BIKE 参数等级的仿真、综合、布局布线结果。新增参数结果时，在总表追加一行，并在对应小节补充报告日期、配置、周期、资源和时序。

## Run Configuration

| Field | Value |
| --- | --- |
| RTL top | `decoder_top` |
| Testbench | `tb_bike_decoder_random` |
| Vivado version | 2023.2 |
| FPGA device | `xc7k325tfbg676-2L` |
| Clock constraint | 100 MHz, 10.000 ns |
| Message width | `BIKE_MSG_BITS=5` |
| Tile columns | `BIKE_C_TILE=256` |
| Lane parallelism | `BIKE_PARALLEL_L=8` |
| Decode iterations | `I_MAX=7` |

## Summary

| Level | Defines | Random seed | Decode cycles | Residual weight | Exact | LUT | FF | BRAM tile | DSP | WNS ns | TNS ns | Routed |
| --- | --- | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 128 | `BIKE_128_PARAMS` | 1 | 612096 | 0 | yes | 9983 | 2526 | 48 | 0 | 0.610 | 0.000 | yes |
| 160 | `BIKE_160_PARAMS` |  | 1231988 |  |  | 12270 | 3049 | 96 | 0 | 0.213 | 0.000 | yes |
| 256 | `BIKE_256_PARAMS` |  | 4459863 |  |  | 16778 | 4235 | 232 | 0 | 0.246 | 0.000 | yes |
| 384 | `BIKE_384_PARAMS` |  |  |  |  |  |  |  |  |  |  |  |

## BIKE-128

### Parameters

| Field | Value |
| --- | ---: |
| `R` | 8117 |
| `N0` | 3 |
| `W` | 27 |
| `T` | 201 |
| `C_TILE` | 256 |
| `TILE_COUNT` | 32 |
| `TILES_TOTAL` | 96 |
| `Q_TILE` | 33 |
| `I_MAX` | 7 |

### Simulation

| Command | Result |
| --- | --- |
| `make test` | pass |
| `make test-bike-random BIKE_RANDOM_TRIALS=1` | pass |

Random test result:

| Field | Value |
| --- | ---: |
| Seed | 1 |
| Iterations | 7 |
| Decode cycles | 612096 |
| Target weight | 201 |
| Output weight | 201 |
| Residual weight | 0 |
| Exact match | 1 |

Cycle budget:

```text
I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE) + 2
= 7 * (1015 + (96 + 1) * 27 * 33) + 2
= 612096
```

### Vivado Utilization

Report: `report_utilization`, fully placed design, generated 2026-06-10 01:03:42.

| Resource | Used | Available | Utilization |
| --- | ---: | ---: | ---: |
| Slice LUTs | 9983 | 203800 | 4.90% |
| LUT as Logic | 8655 | 203800 | 4.25% |
| LUT as Distributed RAM | 1328 | 64000 | 2.08% |
| Slice Registers | 2526 | 407600 | 0.62% |
| Slice | 3167 | 50950 | 6.22% |
| F7 Muxes | 878 | 101900 | 0.86% |
| F8 Muxes | 170 | 50950 | 0.33% |
| Block RAM Tile | 48 | 445 | 10.79% |
| RAMB36E1 | 24 | 445 | 5.39% |
| RAMB18E1 | 48 | 890 | 5.39% |
| DSP | 0 | 840 | 0.00% |
| Bonded IOB | 61 | 400 | 15.25% |
| BUFGCTRL | 1 | 32 | 3.13% |

Primitive highlights:

| Primitive | Used |
| --- | ---: |
| FDCE | 1423 |
| FDRE | 1101 |
| LUT6 | 5199 |
| LUT5 | 1573 |
| LUT4 | 1141 |
| LUT3 | 709 |
| LUT2 | 1450 |
| CARRY4 | 518 |
| MUXF7 | 878 |
| MUXF8 | 170 |
| RAMD64E | 992 |
| RAMD32 | 464 |
| RAMS32 | 128 |

### Vivado Timing

Report: `report_timing_summary`, routed design, generated 2026-06-10 01:04:38.

| Metric | Value |
| --- | ---: |
| WNS | 0.610 ns |
| TNS | 0.000 ns |
| Setup failing endpoints | 0 |
| WHS | 0.042 ns |
| THS | 0.000 ns |
| Hold failing endpoints | 0 |
| WPWS | 4.232 ns |
| Clock period | 10.000 ns |

Worst setup path:

| Field | Value |
| --- | --- |
| Source | `u_check_state_ram/g_pair[1].g_bank[0].mem_reg_2/CLKBWRCLK` |
| Destination | `u_tile_accum_ram/g_buf[1].g_bank[2].mem_reg_r1_0_31_6_9/RAMA_D1/I` |
| Data path delay | 8.962 ns |
| Logic delay | 2.741 ns |
| Route delay | 6.221 ns |
| Logic levels | 12 |
| Logic cells | `CARRY4=2 LUT2=1 LUT4=3 LUT6=6` |

Methodology notes:

| Rule | Count | Note |
| --- | ---: | --- |
| `SYNTH-5` | 240 | Distributed RAM mapping selected by timing constraints |
| `TIMING-18` | 44 | Top-level input/output delay constraints are not modeled |

## BIKE-160

### Parameters

| Field | Value |
| --- | ---: |
| `R` | 12739 |
| `N0` | 3 |
| `W` | 35 |
| `T` | 263 |
| `C_TILE` | 256 |
| `TILE_COUNT` | 50 |
| `TILES_TOTAL` | 150 |
| `Q_TILE` | 33 |
| `I_MAX` | 7 |

Cycle budget:

```text
I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE) + 2
= 7 * (1593 + (150 + 1) * 35 * 33) + 2
= 1231988
```

### Synthesis

Report: `synth_design`, generated 2026-06-10 09:53:44.

Defines:

```text
BIKE_160_PARAMS
BIKE_MSG_BITS=5
BIKE_PARALLEL_L=8
BIKE_C_TILE=256
```

Synthesis status:

| Field | Value |
| --- | ---: |
| Errors | 0 |
| Critical warnings | 0 |
| Warnings | 18 |
| Elapsed time | 00:10:13 |
| Peak memory | 4034.637 MB |

Synthesis cell usage:

| Cell | Count |
| --- | ---: |
| LUT1 | 161 |
| LUT2 | 1630 |
| LUT3 | 856 |
| LUT4 | 1343 |
| LUT5 | 1917 |
| LUT6 | 6245 |
| LUT total | 12152 |
| CARRY4 | 671 |
| MUXF7 | 1322 |
| MUXF8 | 230 |
| FDCE | 1529 |
| FDPE | 2 |
| FDRE | 1518 |
| FF total | 3049 |
| RAMB36E1 | 96 |
| RAMD64E | 1568 |
| RAMD32 | 464 |
| RAMS32 | 128 |
| BUFG | 1 |
| IBUF | 58 |
| OBUF | 7 |

Memory mapping highlights:

| Memory | Mapping |
| --- | --- |
| `check_state_ram` | True dual-port block RAM |
| `msg_sign_ram` | 8 banks, each mapped as 163 K x 1 block RAM |
| `c2v_cache_ram` | 16 lane/buffer RAMs, each mapped as 1 K x 11 block RAM |
| `tile_accum_ram` | 16 banks, each mapped as 32 x 11 distributed RAM |
| `decision_ram` | 8 banks, each mapped as 8 K x 1 distributed RAM |
| `syndrome` banks | 8 banks, each mapped as 2 K x 1 distributed RAM |

Notes:

| Message | Note |
| --- | --- |
| `Synth 8-6702` | Incremental synthesis guide was rejected and default synthesis ran |
| `Synth 8-7052` | Several block RAM instances report that optional output registers were not merged |
| `Netlist 29-101` | `check_state_ram` contains many primitives; hierarchy can help future floorplanning |

### Vivado Utilization

Report: `report_utilization`, fully placed design, generated 2026-06-10 09:57:07.

| Resource | Used | Available | Utilization |
| --- | ---: | ---: | ---: |
| Slice LUTs | 12270 | 203800 | 6.02% |
| LUT as Logic | 10366 | 203800 | 5.09% |
| LUT as Distributed RAM | 1904 | 64000 | 2.98% |
| Slice Registers | 3049 | 407600 | 0.75% |
| Slice | 4170 | 50950 | 8.18% |
| F7 Muxes | 1322 | 101900 | 1.30% |
| F8 Muxes | 230 | 50950 | 0.45% |
| Block RAM Tile | 96 | 445 | 21.57% |
| RAMB36E1 | 96 | 445 | 21.57% |
| RAMB18E1 | 0 | 890 | 0.00% |
| DSP | 0 | 840 | 0.00% |
| Bonded IOB | 65 | 400 | 16.25% |
| BUFGCTRL | 1 | 32 | 3.13% |

Primitive highlights:

| Primitive | Used |
| --- | ---: |
| FDCE | 1529 |
| FDRE | 1518 |
| LUT6 | 6245 |
| LUT5 | 1917 |
| LUT4 | 1343 |
| LUT3 | 856 |
| LUT2 | 1630 |
| CARRY4 | 671 |
| MUXF7 | 1322 |
| MUXF8 | 230 |
| RAMD64E | 1568 |
| RAMD32 | 464 |
| RAMS32 | 128 |
| RAMB36E1 | 96 |

### Vivado Timing

Report: `report_timing_summary`, routed design, generated 2026-06-10 09:58:09.

| Metric | Value |
| --- | ---: |
| WNS | 0.213 ns |
| TNS | 0.000 ns |
| Setup failing endpoints | 0 |
| WHS | 0.057 ns |
| THS | 0.000 ns |
| Hold failing endpoints | 0 |
| WPWS | 4.232 ns |
| Clock period | 10.000 ns |

Worst setup path:

| Field | Value |
| --- | --- |
| Source | `u_tile_scheduler/q_seq_q_reg[3]` |
| Destination | `u_tile_scheduler/o_v2c_h_block_idx_reg[1]` |
| Data path delay | 9.643 ns |
| Logic delay | 3.355 ns |
| Route delay | 6.288 ns |
| Logic levels | 26 |
| Logic cells | `CARRY4=14 LUT2=1 LUT3=2 LUT4=1 LUT5=5 LUT6=3` |

Methodology notes:

| Rule | Count | Note |
| --- | ---: | --- |
| `SYNTH-5` | 392 | Distributed RAM mapping selected by timing constraints |
| `TIMING-18` | 47 | Top-level input/output delay constraints are not modeled |

## BIKE-256

### Parameters

| Field | Value |
| --- | ---: |
| `R` | 29501 |
| `N0` | 3 |
| `W` | 55 |
| `T` | 429 |
| `C_TILE` | 256 |
| `TILE_COUNT` | 116 |
| `TILES_TOTAL` | 348 |
| `Q_TILE` | 33 |
| `I_MAX` | 7 |

Cycle budget:

```text
I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE) + 2
= 7 * (3688 + (348 + 1) * 55 * 33) + 2
= 4459863
```

### Synthesis

Report: `synth_design`, generated 2026-06-10.

Defines:

```text
BIKE_256_PARAMS
BIKE_MSG_BITS=5
BIKE_PARALLEL_L=8
BIKE_C_TILE=256
```

Synthesis status:

| Field | Value |
| --- | ---: |
| Errors | 0 |
| Critical warnings | 0 |
| Warnings | 90 |
| Elapsed time | 00:33:42 |
| Peak memory | 7311.707 MB |

Synthesis cell usage:

| Cell | Count |
| --- | ---: |
| LUT1 | 217 |
| LUT2 | 1700 |
| LUT3 | 792 |
| LUT4 | 1745 |
| LUT5 | 2162 |
| LUT6 | 8202 |
| LUT total | 14818 |
| CARRY4 | 763 |
| MUXF7 | 2862 |
| MUXF8 | 478 |
| FDCE | 1686 |
| FDPE | 2 |
| FDRE | 2547 |
| FF total | 4235 |
| RAMB36E1 | 232 |
| RAMD64E | 3664 |
| RAMD32 | 464 |
| RAMS32 | 128 |
| BUFG | 1 |
| IBUF | 61 |
| OBUF | 7 |

RTL component memory summary:

| RAM group | Size | Count |
| --- | --- | ---: |
| Sign storage banks | 608520 x 1 bit | 8 |
| Check-state banks | 3688 x 17 bit | 16 |
| C2V cache banks | 1815 x 11 bit | 16 |

Memory mapping highlights:

| Memory | Mapping |
| --- | --- |
| `check_state_ram` | True dual-port block RAM |
| `msg_sign_ram` | 8 banks, each mapped as 608520 x 1 block RAM storage |
| `c2v_cache_ram` | 16 lane/buffer RAMs, each mapped as 1 K x 11 block RAM |
| `tile_accum_ram` | 16 banks, each mapped as 32 x 11 distributed RAM |
| `decision_ram` | 8 banks, each mapped as 16 K x 1 distributed RAM |
| `syndrome` banks | 8 banks, each mapped as 4 K x 1 distributed RAM |

Notes:

| Message | Note |
| --- | --- |
| `Synth 8-6702` | Incremental synthesis guide was rejected and default synthesis ran |
| `Synth 8-7052` | Several block RAM instances report that optional output registers were not merged |
| `Netlist 29-101` | `check_state_ram` contains many primitives; hierarchy can help future floorplanning |

### Vivado Utilization

Report: `report_utilization`, fully placed design, generated 2026-06-10 10:49:49.

| Resource | Used | Available | Utilization |
| --- | ---: | ---: | ---: |
| Slice LUTs | 16778 | 203800 | 8.23% |
| LUT as Logic | 12778 | 203800 | 6.27% |
| LUT as Distributed RAM | 4000 | 64000 | 6.25% |
| Slice Registers | 4235 | 407600 | 1.04% |
| Slice | 6444 | 50950 | 12.65% |
| F7 Muxes | 2862 | 101900 | 2.81% |
| F8 Muxes | 478 | 50950 | 0.94% |
| Block RAM Tile | 232 | 445 | 52.13% |
| RAMB36E1 | 232 | 445 | 52.13% |
| RAMB18E1 | 0 | 890 | 0.00% |
| DSP | 0 | 840 | 0.00% |
| Bonded IOB | 68 | 400 | 17.00% |
| BUFGCTRL | 1 | 32 | 3.13% |

Primitive highlights:

| Primitive | Used |
| --- | ---: |
| FDCE | 1686 |
| FDRE | 2547 |
| LUT6 | 8202 |
| LUT5 | 2162 |
| LUT4 | 1745 |
| LUT3 | 792 |
| LUT2 | 1700 |
| CARRY4 | 763 |
| MUXF7 | 2862 |
| MUXF8 | 478 |
| RAMD64E | 3664 |
| RAMD32 | 464 |
| RAMS32 | 128 |
| RAMB36E1 | 232 |

### Vivado Timing

Report: `report_timing_summary`, routed design, generated 2026-06-10 10:51:19.

| Metric | Value |
| --- | ---: |
| WNS | 0.246 ns |
| TNS | 0.000 ns |
| Setup failing endpoints | 0 |
| WHS | 0.049 ns |
| THS | 0.000 ns |
| Hold failing endpoints | 0 |
| WPWS | 4.232 ns |
| Clock period | 10.000 ns |

Worst setup path:

| Field | Value |
| --- | --- |
| Source | `u_c2v_cache_ram/g_buf[1].g_lane[6].mem_reg/CLKBWRCLK` |
| Destination | `u_check_state_ram/g_pair[1].g_bank[6].mem_reg_2_1/DIADI[2]` |
| Data path delay | 9.168 ns |
| Logic delay | 3.370 ns |
| Route delay | 5.798 ns |
| Logic levels | 16 |
| Logic cells | `CARRY4=3 LUT2=1 LUT3=2 LUT4=2 LUT5=3 LUT6=4 MUXF7=1` |

Methodology notes:

| Rule | Count | Note |
| --- | ---: | --- |
| `SYNTH-5` | 912 | Distributed RAM mapping selected by timing constraints |
| `TIMING-18` | 49 | Top-level input/output delay constraints are not modeled |

## Result Template

Copy this section when a new parameter level completes.

### BIKE-XXX

| Field | Value |
| --- | --- |
| Defines | `BIKE_XXX_PARAMS BIKE_MSG_BITS=5 BIKE_PARALLEL_L=8 BIKE_C_TILE=256` |
| Random seed |  |
| Decode cycles |  |
| Target/output/residual weight |  |
| Exact match |  |
| Vivado report date |  |
| LUT / FF / BRAM tile / DSP |  |
| WNS / TNS / WHS |  |
| Worst setup path |  |
