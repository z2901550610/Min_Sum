# Vivado SystemVerilog RTL 规范

本规范用于本仓库 SystemVerilog RTL、testbench、Vivado 约束和综合脚本的生成、修改、审查。设计目标是保持 BIKE/MDPC min-sum decoder 的固定延迟行为，并让 Vivado 综合、实现、时序分析和资源推断得到清晰、一致的 RTL 输入。

## 项目优先级

1. 固定延迟解码是硬约束。给定公开参数级别后，主解码路径的周期数、调度深度、bank 数、存储访问次数和迭代预算必须固定。
2. 架构修改优先降低固定解码时间。评估时同时考虑固定周期数、可达到的时钟频率和时序裕量，其次考虑存储占用，再考虑局部风格优化。
3. RTL 必须面向综合和时序收敛。testbench 语法、随机化、延时控制和仿真系统任务只能放在 `tb/` 或 `ifndef SYNTHESIS` 保护块中。
4. 本规范优先于既有局部写法。现有 RTL、脚本或文档与本规范不一致时，按风险和验证成本逐步修正。

## 目录和文件

- 可综合 RTL 放在 `rtl/`，testbench 放在 `tb/`，Vivado 约束放在 `constraints/`，脚本放在 `scripts/`。
- 公共参数、类型、打包布局和几何尺寸放在 [bike_pkg.sv](/Users/z2901550610/Documents/Min_Sum/rtl/bike_pkg.sv:1)。
- 主要模块文件名与模块名保持一致。
- 随机仿真 fixture 目录为 `tb/generated/`，本地生成产物由 `.gitignore` 管理。修改生成流程时同时更新生成脚本和验证入口。
- 新增设计文档只描述目标架构和当前行为，不写迁移叙述。

## 命名和格式

- 遵守 [naming_conventions.md](/Users/z2901550610/Documents/Min_Sum/docs/naming_conventions.md:1)。
- 模块输入使用 `i_` 前缀，输出使用 `o_` 前缀，子模块实例使用 `u_` 前缀。
- 时钟使用 `i_clk`。顶层外部复位端口使用 `i_rst_n`，含义是异步置位、同步释放的低有效复位源。
- lane、tile、row、col、diagonal、pair、buffer 相关名称使用项目术语：`lane_idx`、`tile_idx`、`base_row_idx`、`check_row_idx`、`row_idx`、`col_idx`、`diag_idx_local`、`diag_idx_global`、`comp_clear_addr`、`fill_buf`、`active_buf`。
- unpacked 数组维度紧贴信号名，例如：

```systemverilog
logic [ROW_IDX_W-1:0] c2v_check_row_idx[0:L-1];
logic signed [ACC_W-1:0] c2v_raw_next[0:L-1];
```

- 维护 RTL/TB 文件后运行 `make format-rtl`。格式检查使用 `make check-format-rtl`。

## SystemVerilog 子集

推荐在 RTL 中使用：

```systemverilog
logic
localparam
parameter
typedef enum logic [...]
typedef struct packed
always_ff
always_comb
generate
function automatic
package
unique case
```

RTL 中禁用：

```systemverilog
class
randomize
mailbox
queue
dynamic array
fork/join
#delay
仿真 initial 硬件行为
```

`initial` 只用于 testbench，或用于 `ifndef SYNTHESIS` 保护下的参数检查和仿真断言。

## 模块接口

- 端口使用显式方向、`logic` 类型和项目宽度参数。
- 实例化使用显式端口连接，禁用 `.*`。
- 顶层、IP 边界、ILA 观测边界和跨工具共享接口使用普通端口。`interface` 只用于验证或局部内部结构，并需要确认 Vivado 综合和调试流程支持。
- 参数级别通过 `bike_pkg` 和 Makefile/Vivado define 选择，禁止在 RTL 中硬编码某个安全级别的尺寸。

示例：

```systemverilog
decoder_top dut (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(i_start),
    .o_done(o_done)
);
```

## 时序逻辑

- 所有寄存器逻辑使用 `always_ff`。
- `always_ff` 中只使用非阻塞赋值 `<=`。
- 一个寄存器只在一个 `always_ff` 中赋值。
- 主时钟域使用 `posedge i_clk`。
- 普通 RTL 禁用手写 gated clock，使用 clock enable。

复位进入主时钟域前先经过同步释放链。同步链寄存器使用 `ASYNC_REG` 属性，便于 Vivado 识别同步链并让实现阶段把寄存器靠近放置：

```systemverilog
(* ASYNC_REG = "TRUE" *) logic rst_meta_n;
(* ASYNC_REG = "TRUE" *) logic rst_sync_n;

always_ff @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    rst_meta_n <= 1'b0;
    rst_sync_n <= 1'b0;
  end else begin
    rst_meta_n <= 1'b1;
    rst_sync_n <= rst_meta_n;
  end
end
```

主时钟域控制寄存器使用同步释放后的低有效 reset：

```systemverilog
always_ff @(posedge i_clk or negedge rst_n_sync) begin
  if (!rst_n_sync) begin
    valid_q <= 1'b0;
  end else if (valid_en) begin
    valid_q <= valid_d;
  end
end
```

大型数据 RAM、累加 RAM、cache RAM、syndrome RAM 和 message RAM 的数据阵列按 Vivado RAM 推断模板组织。只有控制位、valid、loaded bit、状态和计数器需要复位时才复位。RAM 数据阵列写复位循环会影响 RAM 推断和资源映射。

## 组合逻辑

- 组合逻辑使用 `always_comb`。
- `always_comb` 中只使用阻塞赋值 `=`。
- block 开头给输出和临时变量默认值。
- 所有分支完整赋值。
- 禁用 latch、组合环、多驱动。
- 循环上界必须由公开参数决定，禁止由 syndrome、私钥、错误模式或收敛状态决定。

示例：

```systemverilog
always_comb begin
  c2v_accum_next = '0;
  if (c2v_valid) begin
    c2v_accum_next = c2v_accum_base + c2v_raw_next;
  end
end
```

## 状态机和调度

- FSM 使用清晰的状态编码。现有 decoder state 使用 `bike_pkg` 中的 `DEC_*` 常量。
- next-state 组合逻辑需要默认保持或默认安全值，并包含非法状态处理。
- 调度深度、循环次数、窗口数量和 dummy/guard 周期由公开参数决定。
- 主解码路径禁用早停，禁用基于 syndrome、错误估计、H 第一列内容或收敛结果改变迭代次数。
- `o_done` 只能在固定预算完成后置位。
- 每个公开参数级别可以有独立固定预算、tile 几何和并行度。

## 常时间 RTL 规则

- 主解码循环的读写次数、地址生成次数、lane 活动窗口和 C2V/V2C 调度对私有输入保持固定。
- 允许用 valid mask 或 dummy window 处理边界 tile；主循环周期数保持固定。
- 允许在加载 H 或 syndrome 的外部配置阶段报告输入错误；解码主路径不得根据错误模式或收敛行为缩短。
- bank 冲突处理不能引入数据相关重试。需要重排时，重排规则由公开参数和固定调度决定。
- 文档、测试和断言应检查固定周期预算，例如 `expected_main_cycles` 一类自检。

## RAM、ROM 和资源推断

- 小型多 bank、低宽度、频繁并行访问的存储可以使用 `(* ram_style = "distributed" *)`，属性放在 memory array 声明处。
- 需要 BRAM/URAM 时使用 Vivado UG901 推荐的同步读写模板，并明确 read-first、write-first 或 no-change 行为。
- Vivado 会根据 RTL 模板和启发式规则选择 RAM 类型；`ram_style` 用于明确综合意图。常用值包括 `distributed`、`block`、`ultra`、`registers`。
- 复杂 FIFO、异步 FIFO、跨域 FIFO、URAM 和标准 CDC 结构优先使用 AMD XPM。
- 禁止为了清零 RAM 内容而给整个 RAM array 写复位循环。使用 valid、loaded bit、固定写入窗口或外部加载协议表示内容有效性。
- 写地址、读地址和 lane-to-bank mux 的组合路径需要关注时序；大扇入选择器需要 pipeline 或几何调整。

## DSP 和算术

- 乘法、乘加和宽加法树按 Vivado 易推断结构书写。
- 宽组合求和、min-tree、mux-tree 和比较树需要评估 pipeline。
- 有符号运算必须显式声明 `signed` 并进行宽度转换。
- `$clog2` 参数必须覆盖 0/1 边界，使用项目中的条件宽度写法：

```systemverilog
localparam int ROW_IDX_W = (R > 1) ? $clog2(R) : 1;
```

## CDC 和复位跨域

- 本仓库默认单时钟域。新增 clock 时必须同步更新 RTL、XDC、验证和 CDC 报告流程。
- 单 bit 慢变化 level 信号跨域使用两级或多级同步，并给同步寄存器加 `(* ASYNC_REG = "TRUE" *)`。
- 多 bit 总线跨域使用 handshake、async FIFO 或 gray code 方案。禁用逐 bit 两级同步普通数据总线。
- 异步 reset 的释放必须在目标域安全处理。标准 reset CDC 可以使用本仓库 `reset_sync`，复杂 reset CDC 优先使用 XPM。
- `set_false_path` 和 `set_clock_groups` 只表达 STA 例外，不能替代 CDC 电路。

## valid/ready 和协议

- 使用 valid/ready 时，传输条件为 `valid && ready`。
- valid 由发送方产生，ready 由接收方产生。
- valid 到 ready 之间不得形成跨多级模块的组合环。
- `valid=1 && ready=0` 时，payload 必须保持稳定。
- ready 路径过长时加入 register slice 或 skid buffer。
- 当前 decoder 主调度更偏固定扫描协议。新增 valid/ready 接口时要证明 backpressure 不改变主解码预算。

## XDC 和 Vivado 脚本

- 基本约束位于 [decoder_top.xdc](/Users/z2901550610/Documents/Min_Sum/constraints/decoder_top.xdc:1)。
- 约束顺序遵守 UG903：primary/generated clocks、clock groups、I/O delay、timing exceptions、physical constraints。
- clock 必须先创建，再被后续约束引用。
- false path、multicycle path、min/max delay 需要写清楚对象和功能理由。
- 新增 clock、generated clock、异步输入、外设 I/O、debug ILA 或 CDC 结构时同步更新 XDC。
- Vivado batch 流程使用 [vivado_synth.tcl](/Users/z2901550610/Documents/Min_Sum/scripts/vivado_synth.tcl:1)，报告至少包含 utilization、timing summary 和 messages。新增 CDC 结构时加入 `report_cdc`。
- 综合报告流程包含 methodology、CDC、timing summary、messages 和 utilization。methodology 报告用于发现约束、时钟、复位、综合属性和实现流程问题；CDC 报告用于发现跨域结构、复位同步和未识别同步链。

## 仿真和验证

- 优先使用 Makefile 入口：
  - `make test-unit`
  - `make test-integration`
  - `make test-bike-random BIKE_RANDOM_TRIALS=1`
  - `make test`
- testbench 必须 self-checking，并包含 timeout。
- 算法行为使用 Python/C golden model 或生成 fixture 对拍。
- 随机 BIKE case 通过 `scripts/run_bike_random.py` 生成和运行。
- 修改固定调度、cycle budget、banking、tile 几何、message 编码或 syndrome/decision 存储时，至少运行集成测试和一个随机生成 case。

## Lint、格式和综合检查

常规检查：

```bash
make format-rtl
make check-format-rtl
make lint-rtl
make test
```

Vivado 检查：

```bash
make vivado-synth
```

审查 Vivado 报告时关注：

- latch、多驱动、组合环、inferred/gated clock。
- unconstrained paths、setup/hold violation、过长组合路径。
- RAM/DSP/SRL 是否按预期推断。
- `report_cdc` 中的 unsafe、unrecognized 或需 waiver 项。
- 资源利用率与公开参数级别、`BIKE_PARALLEL_L`、`BIKE_COLS_PER_TILE` 的关系。

## 综合属性

- `ram_style` 用于明确 RAM 映射目标，属性贴在 array 或局部层级上。
- `ASYNC_REG` 用于同步链寄存器。
- `mark_debug` 只用于调试观测。
- `keep` 和 `dont_touch` 只用于明确需要保留结构的局部对象，并写明设计理由。
- 属性不能掩盖 RTL 架构、CDC 或时序问题。

## 代码审查清单

审查 RTL 时按以下顺序看：

1. 固定延迟和常时间属性是否成立。
2. 可综合 SystemVerilog 子集是否满足。
3. `always_ff`/`always_comb` 赋值类型是否正确。
4. reset 是否只覆盖需要复位的控制状态。
5. RAM、DSP、FIFO 推断模板是否清晰。
6. 参数边界和位宽转换是否完整。
7. CDC、异步 reset、XDC 例外是否有配套结构和约束。
8. testbench 是否覆盖功能、边界、timeout 和固定周期。
9. Makefile 检查和 Vivado 报告是否足够。

## 规范落地清单

- 顶层外部 reset 进入 `reset_sync`，内部控制逻辑和子模块使用同步释放后的 reset。
- RAM 数据阵列不写全阵列 reset；控制有效性由 loaded bit、valid、固定写入窗口或写入协议表达。
- `ram_style`、`ASYNC_REG`、`mark_debug`、`keep`、`dont_touch` 只在设计意图明确时使用。
- XDC 先声明 clock，再声明 clock groups、I/O delay、timing exception 和 physical constraint。
- Vivado batch 报告保存 methodology、CDC、timing summary、messages 和 utilization。
- RTL 改动完成后按风险运行 Makefile 测试、lint、格式检查和 Vivado synthesis。
