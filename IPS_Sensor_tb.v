`timescale 1ns / 1ps
module IPS_Sensor_tb();
  reg [2:0] sensI;
  wire [2:0] sensO;
  IPS_Sensor uut(sensI, sensO);
  initial begin
    $dumpfile("dump/IPS.vcd");
    $dumpvars(0, IPS_Sensor_tb);
    #100;
    sensI = 3'b000;
    #100;
    sensI = 3'b110;
    #100;
    sensI = 3'b010;
    #100
    $finish();
    $stop;
  end
endmodule
