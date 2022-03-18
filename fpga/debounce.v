module Debounce(input CLK, input i_BUT1, output o_BUT1);

  parameter MAX_COUNT = 250000;
  reg state = 1'b0;
  reg [17:0] count = 0;

  always @ (posedge CLK)
    begin
      if (i_BUT1 !== state && count < MAX_COUNT)
        count <= count + 1; 
      else if (count == MAX_COUNT)
        begin
          count <= 0;
          state <= i_BUT1;
        end
      else
        count <= 0;
    end

  //assign o_BUT1 = state;

endmodule
