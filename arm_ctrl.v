`timescale 1ns/1ps

module arm_ctrl(
  input clk,
  [1:0] instruction, // 00 = off; 01 = down; 10 = up; 11 = stop
  oc,
  output reg En,
  In1,
  In2
);

always @(posedge clk) begin 
  if (oc == 1) begin 
    En = 0; In1 = 0; In2 = 0;
  end else begin 
    case (instruction)
      2'b00: begin En = 0; In1 = 0; In2 = 0; end
      2'b01: begin En = 1; In1 = 0; In2 = 1; end
      2'b10: begin En = 1; In1 = 1; In2 = 0; end
      2'b11: begin En = 1; In1 = 0; In2 = 0; end
    endcase
  end
end

endmodule