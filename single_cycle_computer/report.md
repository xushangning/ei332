# 基本单周期 CPU 设计实验报告

517030910384 徐尚宁

## 实验目的

1. 理解计算机 5 大组成部分的协调工作原理，理解存储程序自动执行的原理。
2. 掌握运算器、存储器、控制器的设计和实现原理。重点掌握控制器设计原理和实现方法。
3. 掌握 I/O 端口的设计方法，理解 I/O 地址空间的设计方法。
4. 会通过设计 I/O 端口与外部设备进行信息交互。

## 实验内容

1. 采用 Verilog HDL 在 quartus II 中实现基本的具有 20 条 MIPS 指令的单周期 CPU 设计。
2. 利用实验提供的标准测试程序代码，完成仿真测试。
3. 采用 I/O 统一编址方式，即将输入输出的 I/O 地址空间，作为数据存取空间的一部分，实现 CPU 与外部设备的输入输出端口设计。实验中可采用高端地址。
4. 利用设计的 I/O 端口，通过 `lw` 指令，输入 DE2 实验板上的按键等输入设备信息。即将外部设备状态，读到 CPU 内部寄存器。
5. 利用设计的 I/O 端口，通过 `sw` 指令，输出对 DE2 实验板上的 LED 灯等输出设备的控制信号（或数据信息）。即将对外部设备的控制数据，从 CPU 内部的寄存器，写入到外部设备的相应控制寄存器(或可直接连接至外部设备的控制输入信号)。
6. 利用自己编写的程序代码，在自己设计的 CPU 上，实现对板载输入开关或按键的状态输入，并将判别或处理结果，利用板载 LED 灯或 7 段 LED 数码管显示出来。例如，将一路 4bit 二进制输入与另一路 4bit 二进制输入相加，利用两组分别 2 个 LED 数码管以 10 进制形式显示“被加数”和“加数”，另外一组 LED 数码管以 10 进制形式显示“和”等。（具体任务形式不做严格规定，同学可自由创意）。
7. 在实现 MIPS 基本 20 条指令的基础上，掌握新指令的扩展方法。
8. 在实验报告中，汇报自己的设计思想和方法;并以汇编语言的形式，提供以上指令集全覆盖的测试应用功能的程序设计代码，并提供程序主要流程图。

## 实验设计

本实验报告首先介绍 20 条 MIPS 指令在 ALU 和 CU 中的实现，然后简略地介绍如何用 ModelSim 和提供的测试程序仿真 CPU，最后描述了 I/O 的实现。

### 指令实现

观察到实验提供的代码只缺少对于 ALU 和 CU 的实现后，我们主要根据随书第五版附赠的 [MIPS Reference Data (Green Card)](https://booksite.elsevier.com/9780124077263/mips_reference_data.php) 中提供的指令格式信息实现了对于每一条指令的识别：

```verilog
wire i_add = r_type & func[5] & ~func[4] & ~func[3] &
             ~func[2] & ~func[1] & ~func[0];          //100000
wire i_sub = r_type & func[5] & ~func[4] & ~func[3] &
             ~func[2] &  func[1] & ~func[0];          //100010

wire i_and = r_type & func[5] & ~func[4] & ~func[3] & func[2] & ~func[1] & ~func[0];
wire i_or  = r_type & func[5] & ~func[4] & ~func[3] & func[2] & ~func[1] & func[0];

wire i_xor = r_type & func[5] & ~func[4] & ~func[3] & func[2] & func[1] & ~func[0];
wire i_sll = r_type & ~|func;
wire i_srl = r_type & ~func[5] & ~func[4] & ~func[3] & ~func[2] & func[1] & ~func[0];
wire i_sra = r_type & ~func[5] & ~func[4] & ~func[3] & ~func[2] & func[1] & func[0];
wire i_jr  = r_type & ~func[5] & ~func[4] & func[3] & ~func[2] & ~func[1] & ~func[0];
             
wire i_addi = ~op[5] & ~op[4] &  op[3] & ~op[2] & ~op[1] & ~op[0]; //001000
wire i_andi = ~op[5] & ~op[4] &  op[3] &  op[2] & ~op[1] & ~op[0]; //001100

wire i_ori  = ~op[5] & ~op[4] & op[3] & op[2] & ~op[1] & op[0];
wire i_xori = ~op[5] & ~op[4] & op[3] & op[2] & op[1] & ~op[0];
wire i_lw   = op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
wire i_sw   = op[5] & ~op[4] & op[3] & ~op[2] & op[1] & op[0];
wire i_beq  = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0];
wire i_bne  = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & op[0];
wire i_lui  = ~op[5] & ~op[4] & op[3] & op[2] & op[1] & op[0];
wire i_j    = ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & ~op[0];
wire i_jal  = ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
```

根据每一条指令执行的特点，确定在这条指令所需要的控制信号。

```verilog
assign pcsource[1] = i_jr | i_j | i_jal;
assign pcsource[0] = ( i_beq & z ) | (i_bne & ~z) | i_j | i_jal ;

assign wreg = i_add | i_sub | i_and | i_or   | i_xor  |
              i_sll | i_srl | i_sra | i_addi | i_andi |
              i_ori | i_xori | i_lw | i_lui  | i_jal;

assign aluc[3] = i_sra;
assign aluc[2] = i_sub | i_or | i_ori | i_lui | i_srl | i_sra;
assign aluc[1] = i_xor | i_xori | i_lui | shift;
assign aluc[0] = i_and | i_andi | i_or | i_ori | shift;
assign shift   = i_sll | i_srl | i_sra ;

assign aluimm  = ~(r_type | i_beq | i_bne);
assign sext    = ~(i_andi | i_ori | i_xori);
assign wmem    = i_sw;
assign m2reg   = i_lw;
assign regrt   = ~r_type;
assign jal     = i_jal;
```

### ModelSim 仿真

由于 Quartus 中找不到在 BDF 文件以外的文件中设置管脚的方法，在这一阶段我们将原来的顶层设计实体 `sc_computer` 重命名为 `single_cycle_computer`，新的顶层设计实体为由 `sc_computer.bdf` 文件代表的 `sc_computer`。

在新版 ModelSim 中，仿真时可以查看嵌套在模块内部的模块的电势变化，不再需要特地将想要观察的信号引出。但是实验所给的 `sc_compture_sim.v` 中是根据老版本的 ModelSim 所写，代码风格差，又有大量不需要的输入输出接口，使得我们决定自己写测试桩：

```verilog
`timescale 10ns/10ns

module single_cycle_computer_sim;
   reg clk, half_freq_clk, reset;
   single_cycle_computer computer(.resetn(reset), .clock(half_freq_clk), .mem_clk(clk));
   
   initial begin
      reset = 0;
      clk <= 0;
      half_freq_clk <= 0;
      #1 reset = 1;
   end
   
   always #1 clk <= ~clk;
   always @(posedge clk) half_freq_clk <= ~half_freq_clk;
endmodule
```

只需根据实验指导书的要求，给 CPU 两个时钟信号，其中一个时钟信号的频率是另一个时钟信号的一半即可。在仿真中必须首先给 CPU 一个重置信号，否则 ModelSim 输出的波形将全部是红色，表明电势不确定。在我们的测试桩中，我们给 CPU 一个长度为一个时间单位的重置信号。

我们还给仿真用的标准测试程序 `sc_instmem.mif` 添加了注释，标注了每一行指令执行后寄存器中的内容，以便与 ModelSim 中的波形比较。以下是部分注释：

```
 0 : 3c010000; % (00) main:   lui $1, 0                 # address of data[0] %
% $1 = 0 %
 1 : 34240050; % (04)         ori $4, $1, 80            # address of data[0] %
% $1 = 0, $4 = 80 %
 2 : 20050004; % (08)         addi $5, $0, 4            # counter %
% $1 = 0, $4 = 80, $5 = 4 %
 3 : 0c000018; % (0c) call:   jal sum                   # call function %
% $2 = 0x258, $4 = 0x60, $5 = 0 %
```

在仿真时，我们主要关注指令内存的输出指令、ALU 的输入操作数和输出、数据内存的输入和输出以及 CU 产生的控制信号，看它们的波形是否与预测的符合。

### I/O 设计

考虑到如果 CPU 时钟频率太高不方便观察 CPU 执行过程，我们设计了两个分频器，将实验板上 50 MHz 的时钟转换为频率只有 2 Hz 的时钟，再用二分频器产生频率为 1 Hz 的时钟。两个分频器代码如下：

```verilog
module freq_divider(input clk_50m, output reg out_clk);
   parameter delay = 12_499_999;
   reg [24:0] counter = 0;

   initial out_clk <= 0;

   always @(posedge clk_50m)
      if (counter < delay)
         counter <= counter + 1'b1;
      else begin
         counter <= 0;
         out_clk <= ~out_clk;
      end
endmodule

module divide_by_two(input in_clk, output reg out_clk);
   initial out_clk = 0;

   always @(posedge in_clk) out_clk <= ~out_clk;
endmodule
```

这两个分频器使得我们的 CPU 频率为 1 Hz。

在设计 I/O 时，我们采用了比较简单的思路，将数据内存的高端地址设置为 I/O 地址，直接将外设输入有关的代码内嵌在 `sc_datamem.v` 中。由于该文件不仅包含数据内存相关代码，我们将其改名为 `sc_mem_controlle.v`：

```verilog
/**
 * The address refers to an I/O device if the highest bit is 1.
*/
module sc_mem_controller (
   input [31:0] addr, input [31:0] datain, input key1,
   input [3:0] key2, input [3:0] key3, input we, input clock, input mem_clk,
   output reg [31:0] dataout, output dmem_clk, output reg [31:0] display
);
   wire [31:0] memout;
   reg [31:0] input_out;      // output of input devices
   wire dmem_we = we & ~addr[31];
   wire write_enable = dmem_we & ~clock;

   assign dmem_clk = mem_clk & ~clock;

   lpm_ram_dq_dram dram(addr[6:2], dmem_clk, datain, write_enable, memout);

   always @(*) begin
      // input devices
      case (addr)
         32'h8000_0000: input_out <= {31'b0, key1};
         32'h8000_0004: input_out <= {28'b0, key2};
         32'h8000_0008: input_out <= {28'b0, key3};
         default: input_out <= 32'hx;
      endcase
      dataout <= addr[31] ? input_out : memout;
      
      // output devices
      if ((we & addr[31]) & (addr == 32'h8000_000C))
         display <= datain;
   end
endmodule
```

`key1`、`key2` 和 `key3` 代表实验板上不同的按键输入。内存地址中最高位为 1 时表明该地址指向 I/O 设备，此时根据不同的地址从不同的外设中读取数据。输出寄存器为代码中的 `display`。当 `sw` 指令指向输出设备的地址时，`datain` 就会转码后输出到七段数码管上。下面是转码用到的 BCD 转换器：

```verilog
module bcd_converter(
   input [12:0] bin,
   output reg [3:0] thousands,
   output reg [3:0] hundreds,
   output reg [3:0] tens,
   output reg [3:0] ones
);
   integer i;
   always @(bin) begin
      thousands = 4'b0;
      hundreds = 4'b0;
      tens = 4'b0;
      ones = 4'b0;
      
      for (i = 12; i >= 0; i = i - 1) begin
         if (thousands >= 5)
            thousands = thousands + 4'h3;
         if (hundreds >= 5)
            hundreds = hundreds + 4'h3;
         if (tens >= 5)
            tens = tens + 4'h3;
         if (ones >= 5)
            ones = ones + 4'h3;
         
         thousands = thousands << 1;
         thousands[0] = hundreds[3];
         hundreds = hundreds << 1;
         hundreds[0] = tens[3];
         tens = tens << 1;
         tens[0] = ones[3];
         ones = ones << 1;
         ones[0] = bin[i];
      end
   end
endmodule
```

为了实时展示程序的执行，我们将当前 PC 的值输出到了板上的 LED。测试上述 I/O 功能的指令如下：

```mips
start:     and $8, $0, $0   
           lui $8, 0x8000   
           lw $9, 0($8)     
           lw $10, 4($8)    
           lw $11, 8($8)    
           beq $9, $0, plus 
           sub $10, $10, $11
           j out            
plus:      add $10, $10, $11
out:       sw $10, 12($8)   
           j start          
```

首先，CPU 计算出 I/O 对应的内存地址，读取外设的数据，再根据读取的数据决定是执行加法还是加法，对读取到的输入执行相应的运算，最终将运算结果写到七段数码管中。
