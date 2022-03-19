`timescale 1 ns / 1 ns
`default_nettype none
module led(input CLK, input BUT1, output LED1);
  reg button1_reg = 1'b0;
  reg led1_reg = 1'b0;
  // Always block with a sensitivity list containing a single item, the CLK
  // this block will be triggered for each raising edge (posedge =positive edge)
  always @(posedge CLK) begin
    // This following line creates a register to store the value of the button.
    // <= is the non-blocking assignment operator.
    button1_reg <= BUT1;
    // Now if the previous value of BUT1 was 1, but the current value is 0,
    // then we have a falling edge of the input switch (going from logic high
    // to low).
    if (BUT1 == 1'b0 && button1_reg == 1'b1)
      begin
       // Assign the inverse of the previous value which can be used to
       // toogle LED1 later.
       led1_reg <= ~led1_reg; 
      end
  end

  assign LED1 = led1_reg;
endmodule
