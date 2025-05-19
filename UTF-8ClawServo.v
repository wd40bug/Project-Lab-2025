`timescale 1ns/1ps
module ClawServo #(
  parameter integer PERIOD_COUNT = 21'd2_000_000,
  parameter integer STEP_SIZE = 1,
  parameter integer STEP_BITS = 4
)(
  input  wire       clk,     // 100 MHz
  input  wire[1:0]  ctrl,    // 00=off; 01=open; 10=close; 11=neutral
  output wire       pwm_out,  // to servo
  output wire        static
);
  // 1 ms = 100 000 ticks, 2 ms = 200 000 ticks (at 100 MHz)
  localparam integer NEUTRAL_TICKS = 21'd150_000;
  localparam integer CLOSE_TICKS = 21'd200_000;
  reg [20:0] goal;
  reg [STEP_BITS:0] counter = 0;

  reg [20:0] pw_ctrl = NEUTRAL_TICKS;
  wire [20:0] pw;
  
  assign static = goal == pw_ctrl;
  assign pw = goal != 0 ?  pw_ctrl : 0;
  always @(posedge clk) begin 
    case (ctrl)
      2'b00: goal=0;
      2'b01: goal= CLOSE_TICKS;
      2'b10: goal= CLOSE_TICKS;
      2'b11: goal= NEUTRAL_TICKS;
    endcase
    if (goal != 0 && goal != pw_ctrl) begin 
      if (counter == 0) begin 
        if (pw_ctrl > goal) begin 
          pw_ctrl =pw_ctrl - STEP_SIZE;
        end else begin 
          pw_ctrl = pw_ctrl + STEP_SIZE;
        end
      end
      counter = counter + 1;
    end
  end

  ServoPWM #(
    .PERIOD_COUNT(PERIOD_COUNT)
  ) pwmgen (
    .clk              (clk),
    .pulse_width_count(pw),
    .pwm_out          (pwm_out)
  );
endmodule
