# 五段流水线 CPU 设计实验报告

517030910384 徐尚宁

## 实验目的

1. 理解计算机指令流水线的协调工作原理，初步掌握流水线的设计和实现原理。
2. 深刻理解流水线寄存器在流水线实现中所起的重要作用。
3. 理解和掌握流水段的划分、设计原理及其实现方法原理。
4. 掌握运算器、寄存器堆、存储器、控制器在流水工作方式下，有别于实验一的设计和实现方法。
5. 掌握流水方式下，通过 I/O 端口与外部设备进行信息交互的方法。

## 实验内容

1. 采用 Verilog 在 Quartus II 中实现基本的具有 20 条 MIPS 指令的 5 段流水 CPU 设计。
2. 利用实验提供的标准测试程序代码，完成仿真测试。
3. 采用 I/O 统一编址方式，即将输入输出的 I/O 地址空间，作为数据存取空间的一部分，实现 CPU 与外部设备的输入输出端口设计。实验中可采用高端地址。
4. 利用设计的 I/O 端口，通过 `lw` 指令，输入 DE2 实验板上的按键等输入设备信息。即将外部设备状态，读到 CPU 内部寄存器。
5. 利用设计的 I/O 端口，通过 `sw` 指令，输出对 DE2 实验板上的 LED 灯等输出设备的控制信号（或数据信息）。即将对外部设备的控制数据，从 CPU 内部的寄存器，写入到外部设备的相应控制寄存器（或可直接连接至外部设备的控制输入信号）。
6. 利用自己编写的程序代码，在自己设计的 CPU 上，实现对板载输入开关或按键的状态输入，并将判别或处理结果，利用板载 LED 灯或 7 段 LED 数码管显示出来。
7. 例如，将一路 4bit 二进制输入与另一路 4bit 二进制输入相加，利用两组分别 2 个 LED 数码管以 10 进制形式显示“被加数”和“加数”，另外一组 LED 数码管以 10 进制形式显示“和”等。（具体任务形式不做严格规定，同学可自由创意）。
8. 在实现 MIPS 基本 20 条指令的基础上，掌握新指令的扩展方法。
9. 在实验报告中，汇报自己的设计思想和方法;并以汇编语言的形式，提供以上两种指令集（MIPS 和 Y86）应用功能的程序设计代码，并提供程序主要流程图。

## 设计

### 流水线寄存器

我们首先设计的是划分流水线不同阶段的流水线寄存器。只要明确了输入信号，这些寄存器其实不过是大同小异。PC 中的寄存器和 IF/ID 寄存器带有启用（Enable）端口，使得流水线可以停顿。上述的两个寄存器加上 ID/EX 寄存器还有重置端口。ID/EX 寄存器的重置端口是用于插入气泡的，而 PC 和 IF/ID 寄存器的重置端口是用于寄存器的初始化。

```verilog
module if_id_reg(
   input clk,
   input resetn,
   input enable,
   input [31:0] pc4_in,
   input [31:0] instruction_in,
   output reg [31:0] pc4,
   output reg [31:0] instruction
);
   always @(posedge clk)
      if (~resetn) begin
         pc4 <= 0;
         instruction <= 0;
      end else if (enable) begin
         pc4 <= pc4_in;
         instruction <= instruction_in;
      end
endmodule

module id_ex_reg(
   input clk, input resetn, input wreg_in, input m2reg_in, input wmem_in, input jal_in,
   input [3:0] aluc_in, input aluimm_in, input shift_in, input [31:0] pc4_in,
   input [31:0] alu_a_in, input [31:0] alu_b_in, input [31:0] imm_in,
   input [4:0] write_reg_num_in,
   output reg wreg, output reg m2reg, output reg wmem, output reg jal,
   output reg [3:0] aluc, output reg aluimm, output reg shift,
   output reg [31:0] pc4, output reg [31:0] alu_a, output reg [31:0] alu_b,
   output reg [31:0] imm, output reg [4:0] write_reg_num
);
   always @(posedge clk) begin
      // control signals
      if (~resetn) begin
         wreg <= 0;
         m2reg <= 0;
         wmem <= 0;
         jal <= 0;
         aluc <= 0;
         aluimm <= 0;
         shift <= 0;

         pc4 <= 0;
         alu_a <= 0;
         alu_b <= 0;
         imm <= 0;
         write_reg_num <= 0;
      end else begin
         wreg <= wreg_in;
         m2reg <= m2reg_in;
         wmem <= wmem_in;
         jal <= jal_in;
         aluc <= aluc_in;
         aluimm <= aluimm_in;
         shift <= shift_in;

         pc4 <= pc4_in;
         alu_a <= alu_a_in;
         alu_b <= alu_b_in;
         imm <= imm_in;
         write_reg_num <= write_reg_num_in;
      end
   end
endmodule

module ex_mem_reg(
   input clk, input wreg_in, input m2reg_in, input wmem_in,
   input [31:0] alu_result_in, input [31:0] mem_write_data_in, input [4:0] write_reg_num_in,
   output reg wreg, output reg m2reg, output reg wmem, output reg [31:0] alu_result,
   output reg [31:0] mem_write_data, output reg [4:0] write_reg_num
);
   always @(posedge clk) begin
      wreg <= wreg_in;
      m2reg <= m2reg_in;
      wmem <= wmem_in;
      alu_result <= alu_result_in;
      mem_write_data <= mem_write_data_in;
      write_reg_num <= write_reg_num_in;
   end
endmodule

module mem_wb_reg(
   input clk, input wreg_in, input m2reg_in, input [31:0] alu_result_in,
   input [31:0] mem_data_in, input [4:0] write_reg_num_in,
   output reg wreg, output reg m2reg, output reg [31:0] alu_result,
   output reg [31:0] mem_data, output reg [4:0] write_reg_num
);
   always @(posedge clk) begin
      wreg <= wreg_in;
      m2reg <= m2reg_in;
      alu_result <= alu_result_in;
      mem_data <= mem_data_in;
      write_reg_num <= write_reg_num_in;
   end
endmodule
```

我们发现，在仿真中，如果不先初始化 IF/ID 寄存器中的内容，该寄存器的输出将全部为 `X`，而分支跳转正是发生在 ID 阶段。寄存器输出为 `X` 相当于读出的指令全部为 `X`，导致决定分支的 `pcsource` 信号也将是 `X`，被这一信号控制的下一个 PC 值也会变成 `X`，CPU 内部便会进入一个混乱的状态。

将代码烧到实验板上后即使不初始化也不会出现这种混乱的状态，因为 Quartus 默认会将寄存器初始化为零。

### 流水线五个阶段

我们没有采用实验报告书中的代码结构，将流水线的每一个阶段写成一个模块，而是将所有阶段集中在 `cpu` 这个模块中。`cpu` 模块的代码结构大致如下：

```verilog
module cpu(/* CPU 输入输出 */);
    // IF 阶段代码
    // IF/ID 寄存器
    // ID 阶段代码
    // ID/EX 阶段
    // EX 阶段代码
    // EX/MEM 寄存器
    // MEM 阶段代码
    // MEM/WB 寄存器
    // WB 阶段代码
    // 转发
endmodule
```

其他设计细节基本按照设计图实现。

### 时序电路设计

与单周期 CPU 不同的是，指令、数据内存以及寄存器堆接受到的时钟信号有很大差别。因为流水线寄存器在时钟上升沿将输入端的值锁存并输出，我们以从一个时钟上升沿到下一个上升沿为 CPU 的一个周期。指令、数据内存以及寄存器堆现在接收的时钟信号是 CPU 时钟的反相信号，使得在一个 CPU 周期中上述存储器的时钟上升沿恰好发生在周期一半的地方。为此，定义了信号 `clock_inv`：

```verilog
wire clock_inv = ~clock;
regfile regfile_inst(
   id_inst[25:21], id_inst[20:16], reg_data_in, wb_write_reg_num,
   wb_wreg, clock_inv, resetn, ra, rb);
```

I/O 部分的设计沿用单周期部分，只是将数据的读取和写入均改为发生在时钟上升沿：

```verilog
module mem_controller (
   input [31:0] addr, input [31:0] datain, input key1,
   input [3:0] key2, input [3:0] key3, input we, input clock,
   output [31:0] dataout, output reg [31:0] display
);
   wire [31:0] memout;
   reg [31:0] input_out;      // output of input devices
   wire dmem_we = we & ~addr[31];
   assign dataout = addr[31] ? input_out : memout;

   lpm_ram_dq_dram dram(addr[6:2], clock, datain, dmem_we, memout);

   always @(posedge clock) begin
      // input devices
      case (addr)
         32'h8000_0000: input_out <= {31'b0, key1};
         32'h8000_0004: input_out <= {28'b0, key2};
         32'h8000_0008: input_out <= {28'b0, key3};
         default: input_out <= 32'hx;
      endcase
   end

   // output devices
   always @(posedge clock)
      if ((we & addr[31]) & (addr == 32'h8000_000C))
         display <= datain;
endmodule
```

## 冒险处理

### 写寄存器指令中的数据冒险

指令在 EX 阶段用于计算的寄存器值可能不是最新的。寄存器堆读出的两个寄存器值都要经过 4 选 1 的数据选择器，数据来源分别为：

- 从寄存器堆中读出的值
- ALU 运算结果
- EX/MEM 寄存器中的 ALU 运算结果
- 从数据内存中取出的值

这部分转发代码如下：

```verilog
always @(*) begin
   // forward to ra of ID
   // check whether inst[25:21] == 0 with |inst[25:21]
   if (ex_wreg & ~ex_m2reg & id_inst[25:21] == ex_write_reg_num_updated & (|id_inst[25:21]))
      new_ra <= ex_alu_result_updated;
   else if (mem_wreg & id_inst[25:21] == mem_write_reg_num & (|id_inst[25:21]))
      if (mem_m2reg)
         new_ra <= mem;
      else
         new_ra <= alu;
   else
      new_ra <= ra;
   // forward to rb of ID
   if (ex_wreg & ~ex_m2reg & id_inst[20:16] == ex_write_reg_num_updated & (|id_inst[20:16]))
      new_rb <= ex_alu_result_updated;
   else if (mem_wreg & id_inst[20:16] == mem_write_reg_num & (|id_inst[20:16]))
      if (mem_m2reg)
         new_rb <= mem;
      else
         new_rb <= alu;
   else
      new_rb <= rb;
end
```

很容易忘记检查将要被写的寄存器号是不是零。如果不检查的话，下面的指令

```mips
add $zero, $t0, $t1
add $t2, $zero, $zero
```

将会转发一个非零的值给要用到 `$zero` 的地方。

### `sw` 中的数据冒险

如果 `sw` 上一条指令恰好是 `lw`，且 `sw` 读的寄存器和 `lw` 写的寄存器是同一个寄存器，`sw` 在 MEM 阶段写内存时的数据将不是 `lw` 刚从内存中读出的值，导致数据冒险。解决方法是使要写入内存的数据通过一个二选一的多选器，数据来源为 ID 阶段读取的寄存器值和 MEM 阶段读到的寄存器值。具体实现如下：

```verilog
wire [31:0] mem_write_data = (mem_m2reg & ex_wmem
   & (mem_write_reg_num == ex_write_reg_num)) ? mem : ex_new_rb;
```

其中 `mem` 为 MEM 阶段从内存中读出的数据，`ex_new_rb` 为指令中 `rt` 对应寄存器的值。这一转发发生在 EX/MEM 寄存器前。

### `lw` 中的数据冒险

当 `lw` 后的指令是除了 `sw` 以外的需要刚从内存中取出的值的指令时，由于从内存中取出的值直到 MEM 阶段后期才会出现，下一条指令如果在 EX 阶段（R 型指令和 I 型指令）或者 ID 阶段需要（`beq` 和 `jr`）寄存器值，此时就需要插入停顿。

```verilog
// stall if lw is follwed by an instruction that will uses the register
// value at EX or earlier
// sw is excluded
assign stall = ex_m2reg && ~id_wmem && (id_inst[25:21] == ex_write_reg_num_updated
      || id_inst[20:16] == ex_write_reg_num_updated);
```

这个 `stall` 信号将会接到 PC 寄存器和 IF/ID 寄存器的启用端口和 ID/EX 寄存器的重置端口。

### 控制冒险

所有的分支跳转指令都会导致控制冒险。设计图中给出的方法是添加时间延迟槽，通常实现时间延迟槽需要硬件和软件（编译器）的配合。编译器负责在分支指令后加上一条适当的指令作为时间延迟槽，但我们毕竟是手写指令，为了避免潜在的错误，实现的是如果发生跳转则流水线停顿。

```verilog
wire control_hazard_stall_inv = pcsource == 2'b00,
   if_id_reg_resetn = resetn & control_hazard_stall_inv;
```

如果检测到发生了跳转，则重置 IF/ID 寄存器以清除取出的错误指令。
