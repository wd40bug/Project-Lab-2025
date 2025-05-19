`timescale 1ns/1ps
module ServoPWM #(
  parameter integer PERIOD_COUNT = 21'd2_000_000  // default: 2 000 000 ticks (20 ms @100 MHz) (not minus one because counter starts at 1)
)(
  input  wire        clk,               // 100 MHz system clock
  input  wire [20:0] pulse_width_count, // high-time in clock ticks
  output reg         pwm_out = 1'b0     // PWM output
);
  reg [20:0] counter = 1;

  always @(posedge clk) begin
    if (counter >= PERIOD_COUNT)
      counter <= 1;
    else
      counter <= counter + 1;

    pwm_out <= (counter < pulse_width_count);
  end
endmodule
