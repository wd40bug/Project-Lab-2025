`timescale 1ns / 1ps
module intersection(
    input clk,
    reset,
    ips,
    input [1:0] count,
    output reg counted = 0
);
  
  reg shift[1:0];
  reg [1:0] count_inner = 0;

  initial begin
    shift[1] = 0;
    shift[0] = 0;
  end

  always @(posedge clk) begin
    if (counted == 0 && reset == 0) begin
      shift[1] = shift[0];
      shift[0] = ~ips; // Active low signal
      if (shift[1] == 1 && shift[0] == 0) begin
        count_inner = count_inner + 1;
        if (count_inner == count) begin
          counted = 1;
        end
      end
    end else if (reset == 1) begin
      counted = 0;
      count_inner = 0;
      shift[0] = 0;
      shift[1] = 0;
    end

  end

endmodule
