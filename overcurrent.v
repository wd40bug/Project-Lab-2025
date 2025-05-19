`timescale 1ns / 1ps
module overcurrent #(
    parameter TIMEOUT = 32'd262143
) (
    input clk,
    snA,
    snB,
    reset,
    output reg oc,
    output dbA,
    dbB
);
  reg testing_oc;
  reg reset_clk;
  wire timer;
  countdown #(TIMEOUT) count(
      clk,
      reset_clk,
      timer
  );
  assign dbA = snA;
  assign dbB = snB;
  initial begin
    testing_oc = 0;
    reset_clk = 1;
    oc = 0;
  end
  always @(posedge clk) begin
    if ((snA == 1 || snB == 1) && testing_oc == 0 && oc == 0) begin
      testing_oc = 1;
      reset_clk  = 0;
    end
    if (timer == 1) begin
      reset_clk  = 1;
      testing_oc = 0;
      if (snA == 1 || snB == 1) begin
        oc = 1;
      end
    end
    if (reset == 1) begin
      reset_clk = 1;
      testing_oc = 0;
      oc = 0;
    end
  end

endmodule
