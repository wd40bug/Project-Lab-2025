`timescale 1ns/1ps

module driver_tb();
  reg [2:0] instruction;
  wire in1, in2, in3, in4, enA, enB;
  driver uut(instruction, in1, in2, in3, in4, enA, enB);
  initial begin
    $dumpfile("dump/driver.vcd");
    $dumpvars(0, driver_tb);
    instruction = 3'b000;
    #100
    instruction = 3'b001;
    #100
    instruction = 3'b010;
    #100
    instruction = 3'b011;
    #100
    instruction = 3'b100;
    #100
    $finish();
  end
endmodule
