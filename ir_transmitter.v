`timescale 1ns / 1ps
module ir_transmitter(
    input clk,            // System clock (100MHz)
    input reset,          // Synchronous reset, active high
    input enable,         // Transmitter enable signal
    input [1:0] freq_select, // Frequency select: 00 = 1kHz, 01 = 2kHz, 10 = 3kHz
    output reg ir_out     // IR output signal (square wave)
);
    // Parameter definitions for half-period counts (in clock cycles)
    // At 100MHz, 1kHz period = 100,000 cycles → half period = 50,000 cycles.
    parameter HALF_PERIOD_1K = 50000;  
    parameter HALF_PERIOD_2K = 25000;  // 2kHz period = 50,000 cycles → half period = 25,000 cycles.
    parameter HALF_PERIOD_3K = 16667;  // 3kHz period ~33,334 cycles → half period ≈ 16,667 cycles.

    reg [31:0] counter;       // Counter for timing the half period
    reg [31:0] target_count;  // Holds the selected half period value

    // Combinational block to choose the target half period based on freq_select
    always @(*) begin
        case (freq_select)
            2'b00: target_count = HALF_PERIOD_1K;
            2'b01: target_count = HALF_PERIOD_2K;
            2'b10: target_count = HALF_PERIOD_3K;
            default: target_count = HALF_PERIOD_1K;
        endcase
    end

    // Sequential block to generate the IR square wave when enabled
    always @(posedge clk) begin
        if (reset) begin
            counter <= 0;
            ir_out  <= 0;
        end else begin
            if (enable) begin
                if (counter >= target_count - 1) begin
                    counter <= 0;
                    ir_out  <= ~ir_out;  // Toggle output to form a square wave
                end else begin
                    counter <= counter + 1;
                end
            end else begin
                // If disabled, keep the counter reset and IR off
                counter <= 0;
                ir_out  <= 0;
            end
        end
    end
endmodule
