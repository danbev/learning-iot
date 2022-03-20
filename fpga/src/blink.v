`timescale 1 ns / 1 ns
`default_nettype none
// CLK is 100MHz
module blink(input CLK, output LED1, output LED2);
  parameter MAX_COUNT = 100000000;
  reg led1_reg = 1'b0;
  reg [28:0] count = 0;

  // Just to turn off LED2
  assign LED2 = 0;

  always @ (posedge CLK)
    begin
      if (count < MAX_COUNT)
        count <= count + 1; 
      else if (count == MAX_COUNT)
        begin
          led1_reg = ~led1_reg;
	  count <= 0;
         end
    end

  assign LED1 = led1_reg;

endmodule
