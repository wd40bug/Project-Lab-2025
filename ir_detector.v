`timescale 1ns / 1ps
module ir_detector(
    input        clk,        // System clock (assumed 100MHz in hardware)
    input        reset,      // Active-high synchronous reset
    input        ir_in,      // IR sensor input (digital signal)
    output reg [1:0] package_id, // Output code: 00 = 1kHz, 01 = 2kHz, 10 = 3kHz, 11 = unknown
    output reg   valid       // One-clock-cycle pulse when a new measurement is made
);

    // For hardware (100MHz clock), expected periods (in clock cycles) might be around:
    // 1kHz: ~100,000 cycles, 2kHz: ~50,000 cycles, 3kHz: ~33,333 cycles.
    // For simulation, we scale these counts down by a factor of 100:
    parameter THRESH_1_LOW  = 99000,  // 1kHz scaled: ~1000 cycles with �10% tolerance
              THRESH_1_HIGH = 101000,
              THRESH_2_LOW  = 45000,  // 2kHz scaled: ~500 cycles �10%
              THRESH_2_HIGH = 55000,
              THRESH_3_LOW  = 30000,  // 3kHz scaled: ~333 cycles with tolerance
              THRESH_3_HIGH = 36000;

    reg ir_in_d;            // Delayed version of ir_in for rising edge detection
    reg [31:0] counter;     // Counts clock cycles between rising edges
    reg [31:0] measured_period; // Stores the measured period

    // Main always block: on each clock cycle, count and detect rising edges.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter         <= 0;
            measured_period <= 0;
            valid           <= 0;
            package_id      <= 2'b00;
            ir_in_d         <= 0;
        end else begin
            ir_in_d <= ir_in;       // Register the previous IR input state
            counter <= counter + 1; // Increment counter every clock cycle

            // Detect rising edge: previous sample low, current sample high
            if (!ir_in_d && ir_in) begin
                measured_period <= counter; // Capture the period since the last rising edge
                counter         <= 0;       // Reset counter for next period measurement
                valid           <= 1;       // Pulse valid high for one clock cycle

                // Classify the measured period into a frequency category:
                if (measured_period >= THRESH_1_LOW && measured_period <= THRESH_1_HIGH)
                    package_id <= 2'b01;  // 1kHz signal
                else if (measured_period >= THRESH_2_LOW && measured_period <= THRESH_2_HIGH)
                    package_id <= 2'b10;  // 2kHz signal
                else if (measured_period >= THRESH_3_LOW && measured_period <= THRESH_3_HIGH)
                    package_id <= 2'b11;  // 3kHz signal
                else
                    package_id <= 2'b00;  // Unknown frequency
            end else begin
                valid <= 0;  // Clear valid if no new measurement
            end
        end
    end
endmodule
