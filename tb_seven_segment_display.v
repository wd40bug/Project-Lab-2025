`timescale 1ns / 1ps

module tb_seven_segment_display;

    // Inputs to the DUT (Device Under Test)
    reg clk;
    reg reset;
    reg overcurrent;
    reg [2:0] sensor;  // [2] = left, [1] = middle, [0] = right

    // Outputs from the DUT
    wire [3:0] an;
    wire [6:0] seg;

    // Instantiate the seven_segment_display module
    // Make sure the module name and port order below match your own code.
    seven_segment_display uut (
        .clk         (clk),
        .reset       (reset),
        .overcurrent (overcurrent),
        .sensor      (sensor),
        .an          (an),
        .seg         (seg)
    );

    // Clock Generation: 100 MHz (Period = 10 ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Toggle every 5 ns => 10 ns total period
    end

    // Stimulus Generation
    initial begin
        // 1) Initialize Inputs
        reset       = 1;        // Start with reset active
        overcurrent = 0;        
        sensor      = 3'b000;   // All sensors inactive

        // 2) Apply Reset
        #20;
        reset = 0;              // De-assert reset

        // Wait a few clock cycles
        #100;

        // Test Case 1: Left sensor ON
        sensor      = 3'b100;   // Left=1, Middle=0, Right=0
        overcurrent = 0;        
        #100;

        // Test Case 2: Middle sensor ON, Overcurrent ON
        sensor      = 3'b010;  
        overcurrent = 1;        
        #100;

        // Test Case 3: Right sensor ON, Overcurrent OFF
        sensor      = 3'b001;   
        overcurrent = 0;        
        #100;

        // Test Case 4: All sensors ON, Overcurrent ON
        sensor      = 3'b111;   
        overcurrent = 1;        
        #100;

        // Test Case 5: Rapid changes
        sensor      = 3'b000;   // All off
        overcurrent = 0;
        #50;
        sensor      = 3'b101;   // Left & Right on
        overcurrent = 1;        
        #50;
        sensor      = 3'b011;   // Middle & Right on
        overcurrent = 0;        
        #50;
        sensor      = 3'b111;   // All on
        overcurrent = 1;
        #50;

        // End Simulation after sufficient time
        #300;
        $stop;
    end

    // Optional: Console Monitor
    initial begin
        $monitor("Time: %0dns | Reset: %b | Overcurrent: %b | Sensor: %b | An: %b | Seg: %b",
                 $time, reset, overcurrent, sensor, an, seg);
    end

endmodule
