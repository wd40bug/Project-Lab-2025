`timescale 1ns/1ps
module IPS_Sensor(input [2:0] sensI, output [2:0] sensO);
  assign sensO = ~sensI;
endmodule
