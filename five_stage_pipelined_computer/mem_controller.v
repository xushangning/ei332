/**
 * The address refers to an I/O device if the highest bit is 1.
*/
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
