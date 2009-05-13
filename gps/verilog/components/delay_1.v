module delay_1(
    input                     clk,
    input [(WIDTH-1):0]       in,
    output wire [(WIDTH-1):0] out);

   parameter WIDTH = 1;

   reg [(WIDTH-1):0] in_km1;

   always @(posedge clk) begin
      in_km1 <= in;
   end

   assign out = in_km1;
   
endmodule