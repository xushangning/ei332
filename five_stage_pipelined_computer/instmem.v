module instmem (addr, inst, clock);
   input [31:0] addr;
   input clock;
   output [31:0] inst;
   
   lpm_rom_irom irom (addr[7:2], clock, inst); 
endmodule
