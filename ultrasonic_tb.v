`timescale 1ns / 1ps

module ultrasonic_tb ();
  reg clk = 0, reset = 1, echo = 0;
  wire trig, detected;
  ultrasonic #(
      .DISTANCE(32'd25000),
      .MAX_ECHO(32'd50000)
  ) uut (
      reset,
      clk,
      echo,
      trig,
      detected
  );

initial begin
  forever begin
    #1
    clk = ~clk;
  end
end

initial begin
  $dumpfile("dump/ultrasonic.vcd");
  $dumpvars(0, ultrasonic_tb);
  #100
  reset = 0; // Run forest
  #100000
  echo = 1;
  #30000 // Should detect
  echo = 0;
  #10000
  reset = 1;

  #100
  reset = 0;
  #100000
  echo = 1;
  #60000 // Should not detect
  echo = 0;

  #100000
  echo = 1;
  #51000 // Go over max, shouldn't detect
  echo = 0;

  #100000
  echo = 1;
  #40000
  echo = 0;
  #10000
  reset = 1;

  #2000
  $finish();
end

endmodule
