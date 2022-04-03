module Debounce(input CLK, input i_BUT1, output o_BUT1);

  parameter MAX_COUNT = 250000;
  reg state = 1'b0;
  // This is creating a register with room for 18 bits. This is needed to be
  // able to store up to the value of MAX_COUNT.
  reg [17:0] count = 0;

  always @ (posedge CLK)
    begin
      // Checking current state of BUT1 and if it is different
      // (there is a toggle) and our counter has not reached or MAX_COUNT
      // (which is our time used to try to avoid the glitches).
      if (i_BUT1 !== state && count < MAX_COUNT)
        count <= count + 1; 
      // MAX_COUNT has been reached and the current value has been different
      // from previous state for that period of time so we consider it stable.
      else if (count == MAX_COUNT)
        begin
          count <= 0;
          state <= i_BUT1;
        end
      // The below else is when the current state and the previous state are not
      // different (indicating a glitch) so we restart the counter so that we
      // can wait for the stable signal state.
      else
        count <= 0;
    end

  assign o_BUT1 = state;

endmodule
