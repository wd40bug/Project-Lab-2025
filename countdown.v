`timescale 1ns / 1ps
module countdown #(parameter TIMEOUT = 32'hFFFFFFFF) (
    input clk,
    input reset,
    output reg sig = 0
);
  reg [31:0] accum;

  always @(posedge clk) begin
    if (reset) begin
      sig = 0;
      accum = TIMEOUT;
    end else if (!sig) begin
      if (accum > 0) begin
        accum <= accum - 1;
      end else begin
        sig = 1;
      end
    end
  end

endmodule
