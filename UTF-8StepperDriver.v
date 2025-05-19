module StepperDriver(
    input  wire clk,        // 100 MHz clock from Basys 3
    input  wire enable,     // Enable stepping when high
    input  wire dir,        // Direction: 0 = open (reverse), 1 = close (forward)
    output reg  [3:0] coil  // Coil control outputs (to ULN2803 inputs)
);
    // Parameter for step timing
    parameter STEP_DELAY = 1_000_000; 


    reg [1:0] state = 3'b000;         // State for which coil is active (00-11)
    reg [24:0] counter = 0;          // Counter for timing (adjust width for STEP_DELAY)

    always @(posedge clk) begin
        if (enable) begin
            if (counter >= STEP_DELAY) begin
                counter = 0;
                // Advance state in the specified direction
                if (dir)
                    state = state + 1;       // increment (wraps 3->0)
                else 
                    state = state - 1;       // decrement (wraps 0->3)
            end else begin
                counter = counter + 1;
            end
            case (state)
                0: coil = 4'b0001;
                1: coil = 4'b0010;
                2: coil = 4'b0100;
                3: coil = 4'b1000;
            endcase
        end else begin
            counter = 0;  // reset counter when not enabled
        end
    end
endmodule
