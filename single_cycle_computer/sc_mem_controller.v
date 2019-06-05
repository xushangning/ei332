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
