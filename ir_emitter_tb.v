`timescale 1ns / 1ps

module ir_emitter_tb;

    reg CLK100MHZ;
    reg [1:0] freq_sel;
    wire ir_out;

    // Instantiate the IR emitter
    ir_emitter uut (
        .CLK100MHZ(CLK100MHZ),
        .freq_sel(freq_sel),
        .ir_out(ir_out)
    );

    // Clock generation (100MHz)
    initial begin
        CLK100MHZ = 0;
        forever #5 CLK100MHZ = ~CLK100MHZ;  // 10ns period for 100MHz
    end

    initial begin
        // Monitor output
        $monitor("Time=%0t | freq_sel=%b | ir_out=%b", $time, freq_sel, ir_out);

        // Initialize freq_sel
        freq_sel = 2'b00; // 1kHz
        #500000;

        freq_sel = 2'b01; // 2kHz
        #250000;

        freq_sel = 2'b10; // 3kHz
        #166667;

        freq_sel = 2'b11; // Invalid, should default to 1kHz
        #500000;

        $finish;
    end

endmodule
