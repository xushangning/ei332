module sc_datamem (input [31:0] addr, input [31:0] datain, input key1,
   input [3:0] key2, input [3:0] key3, input we, input clock, input mem_clk,
   output reg [31:0] dataout, output dmem_clk
);
   wire [31:0] memout;
   wire write_enable; 
   assign         write_enable = we & ~clock;
   
   assign         dmem_clk = mem_clk & ( ~ clock) ;

   lpm_ram_dq_dram  dram(addr[6:2],dmem_clk,datain,write_enable, memout);
   
   always @(addr, key1, key2, key3, memout) begin
      if (addr[31])
         case (addr)
            32'h8000_0000: dataout <= {31'b0, key1};
            32'h8000_0004: dataout <= {28'b0, key2};
            32'h8000_0008: dataout <= {28'b0, key3};
            default: dataout <= 0;
         endcase
      else
         dataout <= memout;
   end
endmodule
