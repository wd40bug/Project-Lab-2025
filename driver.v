`timescale 1ns / 1ps
module driver (
    input clk,
    OC,
    [2:0] instruction,
    output reg in1,
    in2,
    in3,
    in4,
    enA,
    enB
);
  always @(posedge clk) begin 
    if (OC) begin 
      enA = 0;
      enB = 0;
      in1 = 0;
      in2 = 0;
      in3 = 0;
      in4 = 0;
    end else begin
      case (instruction)
        3'b000:  begin enA = 0; enB = 0; in1 = 0; in2 = 0; in3 = 0; in4 = 0; end // Cruise
        3'b001:  begin enA = 1; enB = 1; in1 = 0; in2 = 0; in3 = 0; in4 = 0; end // Stop
        3'b011:  begin enA = 1; enB = 1; in1 = 1; in2 = 0; in3 = 1; in4 = 0; end // Right
        3'b010:  begin enA = 1; enB = 1; in1 = 1; in2 = 0; in3 = 0; in4 = 0; end // Slight Right
        3'b100:  begin enA = 1; enB = 1; in1 = 0; in2 = 0; in3 = 0; in4 = 1; end // Slight Left
        3'b110:  begin enA = 1; enB = 1; in1 = 1; in2 = 0; in3 = 0; in4 = 1; end // Forward
        3'b111:  begin enA = 1; enB = 1; in1 = 0; in2 = 1; in3 = 1; in4 = 0; end // Backwards
        default: begin enA = 0; enB = 0; in1 = 0; in2 = 0; in3 = 0; in4 = 0; end // invalid
      endcase
    end
  end
endmodule
