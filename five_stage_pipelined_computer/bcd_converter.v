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
