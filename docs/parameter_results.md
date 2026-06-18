# Decoder Parameter Results

本文档记录 BIKE 官方参数等级的仿真、综合、布局布线结果。参数结果在总表追加，并在对应小节补充报告日期、配置、周期、资源和时序。

## Run Configuration

| Field | Value |
| --- | --- |
| RTL top | `decoder_top` |
| Testbench | `tb_bike_decoder_random` |
| Command | `make test-bike-unified-random BIKE_RANDOM_TRIALS=1` |
| Random seed | 1 |
| Message width | `BIKE_MSG_BITS=5` |
| Tile columns | `BIKE_UNIFIED_RANDOM_C_TILE=576` |
| Lane parallelism | `BIKE_PARALLEL_L=32` |
| Decode iterations | `I_MAX=7` |

## Summary

| Level | Defines | Random seed | Decode cycles | Target weight | Output weight | Residual weight | Exact |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| 128 | `BIKE_128_PARAMS` | 1 | 472371 | 134 | 134 | 0 | yes |
| 192 | `BIKE_192_PARAMS` | 1 | 1322668 | 199 | 199 | 0 | yes |
| 256 | `BIKE_256_PARAMS` | 1 | 2929126 | 264 | 264 | 0 | yes |

## BIKE-128

### Parameters

| Field | Value |
| --- | ---: |
| `R` | 12323 |
| `N0` | 2 |
| `W` | 71 |
| Official row weight | 142 |
| `T` | 134 |
| `C_TILE` | 576 |
| `ROW_SEG_SIZE` | 386 |
| `TILE_COUNT` | 22 |
| `TILES_TOTAL` | 44 |
| `Q_TILE` | 21 |
| `I_MAX` | 7 |

### Simulation

Random test result:

| Field | Value |
| --- | ---: |
| Seed | 1 |
| Iterations | 7 |
| Decode cycles | 472371 |
| Target weight | 134 |
| Output weight | 134 |
| Residual weight | 0 |
| Exact match | 1 |

Cycle budget:

```text
I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE) + 4
= 7 * (386 + (44 + 1) * 71 * 21) + 4
= 472371
```

## BIKE-192

### Parameters

| Field | Value |
| --- | ---: |
| `R` | 24659 |
| `N0` | 2 |
| `W` | 103 |
| Official row weight | 206 |
| `T` | 199 |
| `C_TILE` | 576 |
| `ROW_SEG_SIZE` | 771 |
| `TILE_COUNT` | 43 |
| `TILES_TOTAL` | 86 |
| `Q_TILE` | 21 |
| `I_MAX` | 7 |

### Simulation

Random test result:

| Field | Value |
| --- | ---: |
| Seed | 1 |
| Iterations | 7 |
| Decode cycles | 1322668 |
| Target weight | 199 |
| Output weight | 199 |
| Residual weight | 0 |
| Exact match | 1 |

Cycle budget:

```text
I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE) + 4
= 7 * (771 + (86 + 1) * 103 * 21) + 4
= 1322668
```

## BIKE-256

### Parameters

| Field | Value |
| --- | ---: |
| `R` | 40973 |
| `N0` | 2 |
| `W` | 137 |
| Official row weight | 274 |
| `T` | 264 |
| `C_TILE` | 576 |
| `ROW_SEG_SIZE` | 1281 |
| `TILE_COUNT` | 72 |
| `TILES_TOTAL` | 144 |
| `Q_TILE` | 21 |
| `I_MAX` | 7 |

### Simulation

Random test result:

| Field | Value |
| --- | ---: |
| Seed | 1 |
| Iterations | 7 |
| Decode cycles | 2929126 |
| Target weight | 264 |
| Output weight | 264 |
| Residual weight | 0 |
| Exact match | 1 |

Cycle budget:

```text
I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE) + 4
= 7 * (1281 + (144 + 1) * 137 * 21) + 4
= 2929126
```

## Result Template

### BIKE-XXX

| Field | Value |
| --- | --- |
| Date |  |
| Defines | `BIKE_XXX_PARAMS BIKE_MSG_BITS=5 BIKE_PARALLEL_L=32 BIKE_C_TILE=576` |
| Seed |  |
| Decode cycles |  |
| LUT |  |
| FF |  |
| BRAM tile |  |
| DSP |  |
| WNS |  |
| TNS |  |
