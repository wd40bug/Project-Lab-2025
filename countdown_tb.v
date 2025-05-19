`timescale 1ns / 1ps

module countdown_tb();
  reg clk=0, reset=1;
  wire sig;
  countdown #(32'd100) uut1(clk, reset, sig);
  countdown #(32'd200) uut2(clk, reset, sig);
  initial begin
    forever begin
      #5
      clk = ~clk;
    end
  end

  initial begin
    $dumpfile("dump/countdown.vcd");
    $dumpvars(0,countdown_tb);
    #100
    reset = 0;
    #3000
    reset = 1;
    #100
    reset = 0;
    #3000
    $finish();
  end
endmodule
