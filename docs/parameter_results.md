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
| 128 | `BIKE_128_PARAMS` | 1 | 612096 | 0 | yes | 37184 | 18815 | 48 | 0 | 0.520 | 0.000 | yes |
| 160 | `BIKE_160_PARAMS` |  | 1231988 |  |  | 54187 | 28568 | 96 | 0 | 0.468 | 0.000 | yes |
| 256 | `BIKE_256_PARAMS` |  | 4459863 |  |  | 110915 | 63307 | 232 | 0 | 0.155 | 0.000 | yes |
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

Report: `report_utilization`, fully placed design, generated 2026-06-08 09:53:11.

| Resource | Used | Available | Utilization |
| --- | ---: | ---: | ---: |
| Slice LUTs | 37184 | 203800 | 18.25% |
| LUT as Logic | 35856 | 203800 | 17.59% |
| LUT as Distributed RAM | 1328 | 64000 | 2.08% |
| Slice Registers | 18815 | 407600 | 4.62% |
| Slice | 10355 | 50950 | 20.32% |
| F7 Muxes | 5168 | 101900 | 5.07% |
| F8 Muxes | 2278 | 50950 | 4.47% |
| Block RAM Tile | 48 | 445 | 10.79% |
| RAMB36E1 | 24 | 445 | 5.39% |
| RAMB18E1 | 48 | 890 | 5.39% |
| DSP | 0 | 840 | 0.00% |
| Bonded IOB | 61 | 400 | 15.25% |
| BUFGCTRL | 1 | 32 | 3.13% |

Primitive highlights:

| Primitive | Used |
| --- | ---: |
| FDCE | 17664 |
| FDRE | 1149 |
| LUT6 | 17429 |
| LUT5 | 9280 |
| LUT4 | 8232 |
| LUT3 | 1614 |
| LUT2 | 1745 |
| CARRY4 | 518 |
| MUXF7 | 5168 |
| MUXF8 | 2278 |
| RAMD64E | 992 |
| RAMD32 | 464 |
| RAMS32 | 128 |

### Vivado Timing

Report: `report_timing_summary`, routed design, generated 2026-06-08 09:54:58.

| Metric | Value |
| --- | ---: |
| WNS | 0.520 ns |
| TNS | 0.000 ns |
| Setup failing endpoints | 0 |
| WHS | 0.058 ns |
| THS | 0.000 ns |
| Hold failing endpoints | 0 |
| WPWS | 4.232 ns |
| Clock period | 10.000 ns |

Worst setup path:

| Field | Value |
| --- | --- |
| Source | `c2v_h_base_row_e_reg[1]` |
| Destination | `c2v_tile_offset_r_reg[7][0]` |
| Data path delay | 9.274 ns |
| Logic delay | 2.493 ns |
| Route delay | 6.781 ns |
| Logic levels | 19 |
| Logic cells | `CARRY4=6 LUT2=1 LUT3=1 LUT5=2 LUT6=9` |

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

Report: `synth_design`, generated 2026-06-08 14:25:00.

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
| LUT1 | 190 |
| LUT2 | 1793 |
| LUT3 | 2005 |
| LUT4 | 15276 |
| LUT5 | 11644 |
| LUT6 | 24146 |
| LUT total | 55054 |
| CARRY4 | 671 |
| MUXF7 | 7300 |
| MUXF8 | 3526 |
| FDCE | 27000 |
| FDPE | 2 |
| FDRE | 1566 |
| FF total | 28568 |
| RAMB36E1 | 96 |
| RAM32M | 64 |
| RAM128X1D | 392 |
| RAM32X1D | 16 |
| RAM16X1D | 24 |
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

Report: `report_utilization`, fully placed design, generated 2026-06-08 21:29:30.

| Resource | Used | Available | Utilization |
| --- | ---: | ---: | ---: |
| Slice LUTs | 54187 | 203800 | 26.59% |
| LUT as Logic | 52283 | 203800 | 25.65% |
| LUT as Distributed RAM | 1904 | 64000 | 2.98% |
| Slice Registers | 28568 | 407600 | 7.01% |
| Slice | 15029 | 50950 | 29.50% |
| F7 Muxes | 8084 | 101900 | 7.93% |
| F8 Muxes | 3526 | 50950 | 6.92% |
| Block RAM Tile | 96 | 445 | 21.57% |
| RAMB36E1 | 96 | 445 | 21.57% |
| RAMB18E1 | 0 | 890 | 0.00% |
| DSP | 0 | 840 | 0.00% |
| Bonded IOB | 65 | 400 | 16.25% |
| BUFGCTRL | 2 | 32 | 6.25% |

Primitive highlights:

| Primitive | Used |
| --- | ---: |
| FDCE | 27000 |
| FDRE | 1566 |
| LUT6 | 24146 |
| LUT5 | 11644 |
| LUT4 | 15276 |
| LUT3 | 2012 |
| LUT2 | 1809 |
| CARRY4 | 671 |
| MUXF7 | 8084 |
| MUXF8 | 3526 |
| RAMD64E | 1568 |
| RAMD32 | 464 |
| RAMS32 | 128 |
| RAMB36E1 | 96 |

### Vivado Timing

Report: `report_timing_summary`, routed design, generated 2026-06-08 21:31:51.

| Metric | Value |
| --- | ---: |
| WNS | 0.468 ns |
| TNS | 0.000 ns |
| Setup failing endpoints | 0 |
| WHS | 0.047 ns |
| THS | 0.000 ns |
| Hold failing endpoints | 0 |
| WPWS | 4.232 ns |
| Clock period | 10.000 ns |

Worst setup path:

| Field | Value |
| --- | --- |
| Source | `u_tile_scheduler/q_seq_q_reg[0]` |
| Destination | `u_tile_scheduler/o_v2c_h_block_idx_reg[1]` |
| Data path delay | 9.382 ns |
| Logic delay | 3.683 ns |
| Route delay | 5.699 ns |
| Logic levels | 28 |
| Logic cells | `CARRY4=17 LUT2=1 LUT3=3 LUT4=1 LUT5=5 LUT6=1` |

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

Report: `synth_design`, generated 2026-06-08 23:00:30.

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
| LUT1 | 231 |
| LUT2 | 1854 |
| LUT3 | 1886 |
| LUT4 | 12105 |
| LUT5 | 53148 |
| LUT6 | 41693 |
| LUT total | 110917 |
| CARRY4 | 760 |
| MUXF7 | 16669 |
| MUXF8 | 8292 |
| FDCE | 60699 |
| FDPE | 2 |
| FDRE | 2595 |
| FF total | 63296 |
| RAMB36E1 | 232 |
| RAM32M | 64 |
| RAM128X1D | 912 |
| RAM64X1D | 8 |
| RAM32X1D | 16 |
| RAM16X1D | 24 |
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

Report: `report_utilization`, fully placed design, generated 2026-06-08 23:06:43.

| Resource | Used | Available | Utilization |
| --- | ---: | ---: | ---: |
| Slice LUTs | 110915 | 203800 | 54.42% |
| LUT as Logic | 106915 | 203800 | 52.46% |
| LUT as Distributed RAM | 4000 | 64000 | 6.25% |
| Slice Registers | 63307 | 407600 | 15.53% |
| Slice | 29790 | 50950 | 58.47% |
| F7 Muxes | 18493 | 101900 | 18.15% |
| F8 Muxes | 8292 | 50950 | 16.27% |
| Block RAM Tile | 232 | 445 | 52.13% |
| RAMB36E1 | 232 | 445 | 52.13% |
| RAMB18E1 | 0 | 890 | 0.00% |
| DSP | 0 | 840 | 0.00% |
| Bonded IOB | 68 | 400 | 17.00% |
| BUFGCTRL | 2 | 32 | 6.25% |

Primitive highlights:

| Primitive | Used |
| --- | ---: |
| FDCE | 60710 |
| FDRE | 2595 |
| LUT6 | 41693 |
| LUT5 | 53148 |
| LUT4 | 12105 |
| LUT3 | 1892 |
| LUT2 | 1870 |
| CARRY4 | 760 |
| MUXF7 | 18493 |
| MUXF8 | 8292 |
| RAMD64E | 3664 |
| RAMD32 | 464 |
| RAMS32 | 128 |
| RAMB36E1 | 232 |

### Vivado Timing

Report: `report_timing_summary`, routed design, generated 2026-06-08 23:12:03.

| Metric | Value |
| --- | ---: |
| WNS | 0.155 ns |
| TNS | 0.000 ns |
| Setup failing endpoints | 0 |
| WHS | 0.031 ns |
| THS | 0.000 ns |
| Hold failing endpoints | 0 |
| WPWS | 4.232 ns |
| Clock period | 10.000 ns |

Worst setup path:

| Field | Value |
| --- | --- |
| Source | `u_check_state_ram/g_pair[1].g_bank[1].mem_reg_2_1` |
| Destination | `u_tile_accum_ram/g_buf[1].g_bank[4].mem_reg_r2_0_31_6_10` |
| Data path delay | 9.395 ns |
| Logic delay | 2.927 ns |
| Route delay | 6.468 ns |
| Logic levels | 13 |
| Logic cells | `CARRY4=2 LUT2=2 LUT3=1 LUT5=2 LUT6=6` |

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
