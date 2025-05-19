`timescale 1ns / 1ps
module overcurrent_tb ();
  reg  clk;
  reg  snA;
  reg  snB;
  reg reset;
  wire oc;
  wire dbA;
  wire dbB;
  initial begin
    snA = 0;
    snB = 0;
    reset = 0;
    clk = 1;
    forever begin
      #5 clk = ~clk;
    end
  end
  overcurrent #(31'd200) uut (
      clk,
      snA,
      snB,
      reset,
      oc,
      dbA,
      dbB
  );
  initial begin
    $dumpfile("dump/overcurrent.vcd");
    $dumpvars(0, overcurrent_tb);
    #1000 snA = 1;
    #300000 snA = 0;
    reset = 1;
    #5 reset = 0;
    snA = 1;
    #100 snA = 0;
    #300000 reset = 1;
    #5 reset = 0;
    snB = 1;
    #300000 snB = 0;
    reset = 1;
    #5 reset = 0;
    snB = 1;
    #100 snB = 0;
    #300000 reset = 1;
    #5 reset = 0;
    $finish();
    $stop;
  end
endmodule
