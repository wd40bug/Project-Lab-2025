`timescale 1ns / 1ps
module intersection_tb ();
  reg clk = 0, reset = 0, ips = 0;
  wire counted;
  reg [1:0] count;
  intersection uut (
      clk,
      reset,
      ips,
      count,
      counted
  );
  initial begin
    forever begin
      #5 clk = ~clk;
    end
  end

  initial begin
    $dumpfile("dump/intersection.vcd");
    $dumpvars(0, intersection_tb);
    // Count = 1
    #15 count = 1;
    #15 ips = 1;
    #15 ips = 0;
    #15

    // Count = 2
    reset = 1;
    count = 2;
    ips   = 0;
    #10 reset = 0;
    #15 ips = 1;
    #15 ips = 0;
    #15 ips = 1;
    #15 ips = 0;
    #15

    // Count = 3
    reset = 1;
    count = 3;
    ips   = 0;
    #10 reset = 0;
    #15 ips = 1;
    #15 ips = 0;
    #15 ips = 1;
    #15 ips = 0;
    #15 ips = 1;
    #15 ips = 0;
    #15 $finish();
    $stop;

  end
endmodule
