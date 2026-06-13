# Decoder Parameter Results

本文档记录各 BIKE 参数等级的仿真、综合、布局布线结果。新增参数结果时，在总表追加一行，并在对应小节补充报告日期、配置、周期、资源和时序。

## Run Configuration

| Field | Value |
| --- | --- |
| RTL top | `decoder_top` |
| Testbench | `tb_bike_decoder_random` |
| Vivado version | 2023.2 |
| FPGA device | `xc7k480tiffv1156-2L` for current BIKE-256 run |
| Clock constraint | 100 MHz, 10.000 ns |
| Message width | `BIKE_MSG_BITS=5` |
| Tile columns | `BIKE_C_TILE=288` for current BIKE-256 run |
| Lane parallelism | `BIKE_PARALLEL_L=8` |
| Decode iterations | `I_MAX=7` |

## Summary

| Level | Defines | Random seed | Decode cycles | Residual weight | Exact | LUT | FF | BRAM tile | DSP | WNS ns | TNS ns | Routed |
| --- | --- | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 128 | `BIKE_128_PARAMS` | 1 | 612096 | 0 | yes | 10712 | 2968 | 56 | 0 | 0.544 | 0.000 | yes |
| 160 | `BIKE_160_PARAMS` |  | 1231988 |  |  | 12270 | 3049 | 96 | 0 | 0.213 | 0.000 | yes |
| 256 | `BIKE_256_PARAMS` | 1 | 4441768 | 0 | yes | 17472 | 4666 | 368 | 0 | 0.510 | 0.000 | yes |
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

Report: `report_utilization`, fully placed design, generated 2026-06-13 21:36:01.

| Resource | Used | Available | Utilization |
| --- | ---: | ---: | ---: |
| Slice LUTs | 10712 | 298600 | 3.59% |
| LUT as Logic | 9192 | 298600 | 3.08% |
| LUT as Distributed RAM | 1520 | 108600 | 1.40% |
| Slice Registers | 2968 | 597200 | 0.50% |
| Slice | 3238 | 74650 | 4.34% |
| F7 Muxes | 911 | 149300 | 0.61% |
| F8 Muxes | 170 | 74650 | 0.23% |
| Block RAM Tile | 56 | 955 | 5.86% |
| RAMB36E1 | 32 | 955 | 3.35% |
| RAMB18E1 | 48 | 1910 | 2.51% |
| DSP | 0 | 1920 | 0.00% |
| Bonded IOB | 61 | 400 | 15.25% |
| BUFGCTRL | 1 | 32 | 3.13% |

Primitive highlights:

| Primitive | Used |
| --- | ---: |
| FDCE | 1913 |
| FDRE | 1053 |
| LUT6 | 5996 |
| LUT5 | 1809 |
| LUT4 | 1000 |
| LUT3 | 584 |
| LUT2 | 1104 |
| CARRY4 | 340 |
| MUXF7 | 911 |
| MUXF8 | 170 |
| RAMD64E | 1440 |
| RAMD32 | 80 |
| RAMB18E1 | 48 |
| RAMB36E1 | 32 |

### Vivado Timing

Report: `report_timing_summary`, routed design, generated 2026-06-13 21:37:11.

| Metric | Value |
| --- | ---: |
| WNS | 0.544 ns |
| TNS | 0.000 ns |
| Setup failing endpoints | 0 |
| WHS | 0.051 ns |
| THS | 0.000 ns |
| Hold failing endpoints | 0 |
| WPWS | 4.232 ns |
| Clock period | 10.000 ns |

Worst setup path:

| Field | Value |
| --- | --- |
| Source | `u_msg_sign_ram/g_bank[5].mem_reg_3/CLKBWRCLK` |
| Destination | `u_tile_accum_ram/g_buf[1].g_bank[2].mem_reg_r2_0_63_9_9/DP/I` |
| Data path delay | 8.658 ns |
| Logic delay | 3.044 ns |
| Route delay | 5.614 ns |
| Logic levels | 11 |
| Logic cells | `CARRY4=2 LUT2=1 LUT4=1 LUT5=2 LUT6=4 MUXF7=1` |

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
| `ram_m` | True dual-port block RAM |
| `ram_s` | 8 banks, each mapped as 163 K x 1 block RAM |
| `ram_t` | 16 lane/buffer RAMs, each mapped as 1 K x 11 block RAM |
| `ram_t_accum` | 16 banks, each mapped as 32 x 11 distributed RAM |
| `ram_c1` | 8 banks, each mapped as 8 K x 1 distributed RAM |
| `syndrome` banks | 8 banks, each mapped as 2 K x 1 distributed RAM |

Notes:

| Message | Note |
| --- | --- |
| `Synth 8-6702` | Incremental synthesis guide was rejected and default synthesis ran |
| `Synth 8-7052` | Several block RAM instances report that optional output registers were not merged |
| `Netlist 29-101` | `ram_m` contains many primitives; hierarchy can help future floorplanning |

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
| `C_TILE` | 288 |
| `TILE_COUNT` | 103 |
| `TILES_TOTAL` | 309 |
| `Q_TILE` | 37 |
| `I_MAX` | 7 |

### Simulation

Random test result:

| Field | Value |
| --- | ---: |
| Seed | 1 |
| Iterations | 7 |
| Decode cycles | 4441768 |
| Target weight | 429 |
| Output weight | 429 |
| Residual weight | 0 |
| Exact match | 1 |

Cycle budget:

```text
I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE) + 2
= 7 * (3688 + (309 + 1) * 55 * 37) + 2
= 4441768
```

### Synthesis

Report: `synth_design`, generated 2026-06-13.

Defines:

```text
BIKE_256_PARAMS
BIKE_MSG_BITS=5
BIKE_PARALLEL_L=8
BIKE_C_TILE=288
```

FPGA device:

| Field | Value |
| --- | --- |
| Part | `xc7k480tiffv1156-2L` |

RTL component memory summary:

| RAM group | Size | Count |
| --- | --- | ---: |
| Sign storage banks | 16 K x 36 bit | 8 |
| Check-state banks | 3688 x 17 bit | 16 |
| C2V cache banks | 2035 x 11 bit | 16 |

Memory mapping highlights:

| Memory | Mapping |
| --- | --- |
| `ram_m` | True dual-port block RAM |
| `ram_s` | 8 banks, each mapped as 16 K x 36 block RAM storage |
| `ram_t` | 16 lane/buffer RAMs, each mapped as 1 K x 11 block RAM |
| `ram_t_accum` | 16 banks, each mapped as 64 x 11 distributed RAM |
| `ram_c1` | 8 banks, each mapped as 16 K x 1 distributed RAM |
| `syndrome` banks | 8 banks, each mapped as 4 K x 1 distributed RAM |

Notes:

| Message | Note |
| --- | --- |
| `Synth 8-7052` | Several block RAM instances report that optional output registers were not merged |

### Vivado Utilization

Report: `report_utilization`, fully placed design, generated 2026-06-13 21:14:10.

| Resource | Used | Available | Utilization |
| --- | ---: | ---: | ---: |
| Slice LUTs | 17472 | 298600 | 5.85% |
| LUT as Logic | 13216 | 298600 | 4.43% |
| LUT as Distributed RAM | 4256 | 108600 | 3.92% |
| Slice Registers | 4666 | 597200 | 0.78% |
| Slice | 6021 | 74650 | 8.07% |
| F7 Muxes | 2877 | 149300 | 1.93% |
| F8 Muxes | 478 | 74650 | 0.64% |
| Block RAM Tile | 368 | 955 | 38.53% |
| RAMB36E1 | 368 | 955 | 38.53% |
| RAMB18E1 | 0 | 1910 | 0.00% |
| DSP | 0 | 1920 | 0.00% |
| Bonded IOB | 68 | 400 | 17.00% |
| BUFGCTRL | 1 | 32 | 3.13% |

Primitive highlights:

| Primitive | Used |
| --- | ---: |
| LUT6 | 9088 |
| RAMD64E | 4176 |
| MUXF7 | 2877 |
| FDRE | 2475 |
| FDCE | 2189 |
| LUT5 | 2063 |
| LUT4 | 1508 |
| LUT2 | 1487 |
| LUT3 | 824 |
| CARRY4 | 573 |
| MUXF8 | 478 |
| RAMB36E1 | 368 |
| LUT1 | 147 |
| RAMD32 | 80 |
| IBUF | 61 |
| OBUF | 7 |
| FDPE | 2 |
| BUFG | 1 |

### Vivado Timing

Report: `report_timing_summary`, routed design, generated 2026-06-13 21:17:34.

| Metric | Value |
| --- | ---: |
| WNS | 0.510 ns |
| TNS | 0.000 ns |
| Setup failing endpoints | 0 |
| WHS | 0.044 ns |
| THS | 0.000 ns |
| Hold failing endpoints | 0 |
| WPWS | 4.232 ns |
| Clock period | 10.000 ns |

Worst setup path:

| Field | Value |
| --- | --- |
| Source | `u_ram_s/g_bank[1].mem_reg_0_9/CLKBWRCLK` |
| Destination | `u_ram_t_accum/g_buf[0].g_bank[2].mem_reg_r2_0_63_9_10/RAMA/I` |
| Data path delay | 8.731 ns |
| Logic delay | 2.832 ns |
| Route delay | 5.899 ns |
| Logic levels | 12 |
| Logic cells | `CARRY4=3 LUT2=1 LUT4=1 LUT5=2 LUT6=4 MUXF7=1` |

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
| Defines | `BIKE_XXX_PARAMS BIKE_MSG_BITS=5 BIKE_PARALLEL_L=8 BIKE_C_TILE=288` |
| Random seed |  |
| Decode cycles |  |
| Target/output/residual weight |  |
| Exact match |  |
| Vivado report date |  |
| LUT / FF / BRAM tile / DSP |  |
| WNS / TNS / WHS |  |
| Worst setup path |  |
