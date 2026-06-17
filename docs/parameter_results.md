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
| 128 | `BIKE_128_PARAMS` | 1 | 612097 | 0 | yes | 11042 | 3090 | 56 | 0 | 0.499 | 0.000 | yes |
| 160 | `BIKE_160_PARAMS` |  | 1231989 |  |  | 12861 | 3546 | 88 | 0 | 0.398 | 0.000 | yes |
| 256 | `BIKE_256_PARAMS` | 1 | 4441769 | 0 | yes | 17354 | 4689 | 244 | 0 | 0.288 | 0.000 | yes |
| 384 | `BIKE_384_PARAMS` |  | 13970904 |  |  | 24686 | 7498 | 570 | 0 | 0.448 | 0.000 | yes |

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
| `Q_TILE` | 34 |
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
| Decode cycles | 612097 |
| Target weight | 201 |
| Output weight | 201 |
| Residual weight | 0 |
| Exact match | 1 |

Cycle budget:

```text
I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE) + 4
= 7 * (1015 + (96 + 1) * 27 * 34) + 4
= 630431
```

### Vivado Utilization

Report: `report_utilization`, fully placed design, generated 2026-06-13 23:11:36.

| Resource | Used | Available | Utilization |
| --- | ---: | ---: | ---: |
| Slice LUTs | 11042 | 298600 | 3.70% |
| LUT as Logic | 9522 | 298600 | 3.19% |
| LUT as Distributed RAM | 1520 | 108600 | 1.40% |
| Slice Registers | 3090 | 597200 | 0.52% |
| Slice | 3255 | 74650 | 4.36% |
| F7 Muxes | 927 | 149300 | 0.62% |
| F8 Muxes | 194 | 74650 | 0.26% |
| Block RAM Tile | 56 | 955 | 5.86% |
| RAMB36E1 | 40 | 955 | 4.19% |
| RAMB18E1 | 32 | 1910 | 1.68% |
| DSP | 0 | 1920 | 0.00% |
| Bonded IOB | 61 | 400 | 15.25% |
| BUFGCTRL | 1 | 32 | 3.13% |

Primitive highlights:

| Primitive | Used |
| --- | ---: |
| FDCE | 2035 |
| FDRE | 1053 |
| LUT6 | 6039 |
| LUT5 | 2004 |
| LUT4 | 1122 |
| LUT3 | 547 |
| LUT2 | 992 |
| CARRY4 | 329 |
| MUXF7 | 927 |
| MUXF8 | 194 |
| RAMD64E | 1440 |
| RAMD32 | 80 |
| RAMB18E1 | 32 |
| RAMB36E1 | 40 |

### Vivado Timing

Report: `report_timing_summary`, routed design, generated 2026-06-13 23:13:22.

| Metric | Value |
| --- | ---: |
| WNS | 0.499 ns |
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
| Source | `u_ram_t/g_buf[1].g_lane[1].mem_reg/CLKBWRCLK` |
| Destination | `u_ram_m/g_pair[1].g_bank[1].mem_reg_2/DIADI[3]` |
| Data path delay | 8.984 ns |
| Logic delay | 3.639 ns |
| Route delay | 5.345 ns |
| Logic levels | 15 |
| Logic cells | `CARRY4=3 LUT2=1 LUT3=2 LUT4=2 LUT5=3 LUT6=3 MUXF7=1` |

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
| `Q_TILE` | 34 |
| `I_MAX` | 7 |

Cycle budget:

```text
I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE) + 4
= 7 * (1593 + (150 + 1) * 35 * 34) + 4
= 1268985
```

### Vivado Utilization

Report: `report_utilization`, fully placed design, generated 2026-06-13 23:27:14.

| Resource | Used | Available | Utilization |
| --- | ---: | ---: | ---: |
| Slice LUTs | 12861 | 298600 | 4.31% |
| LUT as Logic | 10701 | 298600 | 3.58% |
| LUT as Distributed RAM | 2160 | 108600 | 1.99% |
| Slice Registers | 3546 | 597200 | 0.59% |
| Slice | 4137 | 74650 | 5.54% |
| F7 Muxes | 1386 | 149300 | 0.93% |
| F8 Muxes | 248 | 74650 | 0.33% |
| Block RAM Tile | 88 | 955 | 9.21% |
| RAMB36E1 | 88 | 955 | 9.21% |
| RAMB18E1 | 0 | 1910 | 0.00% |
| DSP | 0 | 1920 | 0.00% |
| Bonded IOB | 65 | 400 | 16.25% |
| BUFGCTRL | 1 | 32 | 3.13% |

Primitive highlights:

| Primitive | Used |
| --- | ---: |
| LUT6 | 6922 |
| RAMD64E | 2080 |
| LUT5 | 2074 |
| FDCE | 2074 |
| FDRE | 1470 |
| MUXF7 | 1386 |
| LUT4 | 1335 |
| LUT2 | 1162 |
| LUT3 | 460 |
| CARRY4 | 442 |
| MUXF8 | 248 |
| RAMB36E1 | 88 |
| RAMD32 | 80 |

### Vivado Timing

Report: `report_timing_summary`, routed design, generated 2026-06-13 23:29:04.

| Metric | Value |
| --- | ---: |
| WNS | 0.398 ns |
| TNS | 0.000 ns |
| Setup failing endpoints | 0 |
| WHS | 0.059 ns |
| THS | 0.000 ns |
| Hold failing endpoints | 0 |
| WPWS | 4.232 ns |
| Clock period | 10.000 ns |

Worst setup path:

| Field | Value |
| --- | --- |
| Source | `v2c_tile_idx_e_reg[2]/C` |
| Destination | `v2c_col_idx_r_reg[6][11]/D` |
| Data path delay | 9.458 ns |
| Logic delay | 3.425 ns |
| Route delay | 6.033 ns |
| Logic levels | 21 |
| Logic cells | `CARRY4=10 LUT2=3 LUT3=1 LUT4=1 LUT5=2 LUT6=4` |

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
| `Q_TILE` | 38 |
| `I_MAX` | 7 |

### Simulation

Random test result:

| Field | Value |
| --- | ---: |
| Seed | 1 |
| Iterations | 7 |
| Decode cycles | 4441769 |
| Target weight | 429 |
| Output weight | 429 |
| Residual weight | 0 |
| Exact match | 1 |

Cycle budget:

```text
I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE) + 4
= 7 * (3688 + (309 + 1) * 55 * 38) + 4
= 4561120
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

Report: `report_utilization`, fully placed design, generated 2026-06-13 23:43:12.

| Resource | Used | Available | Utilization |
| --- | ---: | ---: | ---: |
| Slice LUTs | 17354 | 298600 | 5.81% |
| LUT as Logic | 13098 | 298600 | 4.39% |
| LUT as Distributed RAM | 4256 | 108600 | 3.92% |
| Slice Registers | 4689 | 597200 | 0.79% |
| Slice | 5825 | 74650 | 7.80% |
| F7 Muxes | 2853 | 149300 | 1.91% |
| F8 Muxes | 478 | 74650 | 0.64% |
| Block RAM Tile | 244 | 955 | 25.55% |
| RAMB36E1 | 232 | 955 | 24.29% |
| RAMB18E1 | 24 | 1910 | 1.26% |
| DSP | 0 | 1920 | 0.00% |
| Bonded IOB | 68 | 400 | 17.00% |
| BUFGCTRL | 1 | 32 | 3.13% |

Primitive highlights:

| Primitive | Used |
| --- | ---: |
| LUT6 | 8736 |
| RAMD64E | 4176 |
| MUXF7 | 2853 |
| FDRE | 2475 |
| FDCE | 2212 |
| LUT5 | 2154 |
| LUT4 | 1361 |
| LUT2 | 1497 |
| LUT3 | 589 |
| CARRY4 | 611 |
| MUXF8 | 478 |
| RAMB36E1 | 232 |
| LUT1 | 221 |
| RAMD32 | 80 |
| IBUF | 61 |
| RAMB18E1 | 24 |
| OBUF | 7 |
| FDPE | 2 |
| BUFG | 1 |

### Vivado Timing

Report: `report_timing_summary`, routed design, generated 2026-06-13 23:45:01.

| Metric | Value |
| --- | ---: |
| WNS | 0.288 ns |
| TNS | 0.000 ns |
| Setup failing endpoints | 0 |
| WHS | 0.059 ns |
| THS | 0.000 ns |
| Hold failing endpoints | 0 |
| WPWS | 4.232 ns |
| Clock period | 10.000 ns |

Worst setup path:

| Field | Value |
| --- | --- |
| Source | `v2c_tile_idx_e_reg[2]/C` |
| Destination | `v2c_row_addr_r_reg[3][11]/D` |
| Data path delay | 9.316 ns |
| Logic delay | 3.855 ns |
| Route delay | 5.461 ns |
| Logic levels | 22 |
| Logic cells | `CARRY4=13 LUT1=1 LUT3=1 LUT4=2 LUT5=1 LUT6=4` |

Methodology notes:

| Rule | Count | Note |
| --- | ---: | --- |
| `SYNTH-5` | 912 | Distributed RAM mapping selected by timing constraints |
| `TIMING-18` | 49 | Top-level input/output delay constraints are not modeled |

## BIKE-384

### Parameters

| Field | Value |
| --- | ---: |
| `R` | 61283 |
| `N0` | 3 |
| `W` | 83 |
| `T` | 659 |
| `C_TILE` | 456 |
| `TILE_COUNT` | 135 |
| `TILES_TOTAL` | 405 |
| `Q_TILE` | 60 |
| `I_MAX` | 7 |

Cycle budget:

```text
I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE) + 4
= 7 * (7661 + (405 + 1) * 83 * 60) + 4
= 14206791
```

### Vivado Utilization

Report: `report_utilization`, fully placed design, generated 2026-06-14 23:46:55.

| Resource | Used | Available | Utilization |
| --- | ---: | ---: | ---: |
| CLB LUTs | 24686 | 663360 | 3.72% |
| LUT as Logic | 16750 | 663360 | 2.53% |
| LUT as Distributed RAM | 7936 | 293760 | 2.70% |
| CLB Registers | 7498 | 1326720 | 0.57% |
| CLB | 5058 | 82920 | 6.10% |
| F7 Muxes | 5499 | 331680 | 1.66% |
| F8 Muxes | 2657 | 165840 | 1.60% |
| Block RAM Tile | 570 | 2160 | 26.39% |
| RAMB36E2 | 570 | 2160 | 26.39% |
| RAMB18 | 0 | 4320 | 0.00% |
| DSP | 0 | 5520 | 0.00% |
| Bonded IOB | 72 | 832 | 8.65% |
| BUFGCE | 2 | 576 | 0.35% |

Primitive highlights:

| Primitive | Used |
| --- | ---: |
| LUT6 | 11897 |
| RAMD64E | 7888 |
| MUXF7 | 5499 |
| FDRE | 4000 |
| FDCE | 3368 |
| LUT5 | 3035 |
| MUXF8 | 2657 |
| LUT2 | 1856 |
| LUT4 | 1534 |
| RAMB36E2 | 570 |
| LUT3 | 528 |
| CARRY8 | 167 |
| FDPE | 130 |
| IBUF | 65 |
| RAMD32 | 48 |
| LUT1 | 44 |
| OBUF | 7 |
| BUFGCE | 2 |

### Vivado Timing

Report: `report_timing_summary`, routed design, generated 2026-06-14 23:54:04.

| Metric | Value |
| --- | ---: |
| WNS | 0.448 ns |
| TNS | 0.000 ns |
| Setup failing endpoints | 0 |
| WHS | 0.030 ns |
| THS | 0.000 ns |
| Hold failing endpoints | 0 |
| WPWS | 3.850 ns |
| Clock period | 9.660 ns |

Worst setup path:

| Field | Value |
| --- | --- |
| Source | `v2c_write_h_edge_id_p_reg[2]/C` |
| Destination | `u_ram_s/g_bank[1].mem_reg_bram_25/ADDRARDADDR[12]` |
| Data path delay | 8.999 ns |
| Logic delay | 0.515 ns |
| Route delay | 8.484 ns |
| Logic levels | 2 |
| Logic cells | `CARRY8=1 LUT2=1` |

Methodology notes:

| Rule | Count | Note |
| --- | ---: | --- |
| `SYNTH-5` | 912 | Distributed RAM mapping selected by timing constraints |
| `TIMING-18` | 52 | Top-level input/output delay constraints are not modeled |

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
