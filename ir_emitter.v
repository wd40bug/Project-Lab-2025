module ir_emitter (
    input CLK100MHZ,      // 100MHz clock from Basys3
    input enable,
    input [1:0] freq_sel, // Frequency selection (00=1kHz, 01=2kHz, 10=3kHz)
    output reg ir_out     // Output to IR LED
);

    reg [15:0] counter;   // 16-bit counter for frequency division
    reg [15:0] max_count; // Maximum count for selected frequency

    // Frequency selection logic
    always @(*) begin
        case (freq_sel)
            2'b01: max_count = 50000;  // 1kHz: 100MHz / (2 * 1kHz) = 50000
            2'b10: max_count = 25000;  // 2kHz: 100MHz / (2 * 2kHz) = 25000
            2'b11: max_count = 16667;  // 3kHz: 100MHz / (2 * 3kHz) ≈ 16667
            default: max_count = 0; // Default to 1kHz
        endcase
    end

    // Counter logic with reset
    always @(posedge CLK100MHZ) begin
      if (enable == 1 && max_count != 0) begin
          if (counter >= max_count) begin
            ir_out <= ~ir_out;  // Toggle IR output
            counter <= 0;       // Reset counter
          end else begin
            counter <= counter + 1; // Increment counter
          end
        end
    end

    // Initial block to reset values
    initial begin
        counter = 0;
        ir_out = 0;
    end

endmodule
