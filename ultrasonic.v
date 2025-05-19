`timescale 1ns / 1ps
`define RESET state = PRIME; wait_reset = 0; trig_reset = 1; detected = 0;


module ultrasonic #(
    parameter DISTANCE = 32'h0000FFFF,
    parameter MAX_ECHO = 32'hFFFFFFFF
) (
    input reset,
    clk,
    echo,
    output reg trig = 0,
    output reg detected = 0
);
  // States
  localparam PRIME = 3'b000;
  localparam TRIGGER = 3'b001;
  localparam LISTEN = 3'b010;
  localparam ECHO = 3'b011;
  localparam STOPPED = 3'b100;

  localparam WAIT_CYCLES = 20'd10000;
  localparam TRIG_CYCLES = 20'd1000;

  reg  wait_reset = 0;
  wire wait_signal;
  countdown #(WAIT_CYCLES) wait_countdown (
      clk,
      wait_reset,
      wait_signal
  );

  reg [3:0] countdown_delay = 4'hF;

  reg trig_reset = 1;
  wire trig_signal;
  countdown #(TRIG_CYCLES) trig_countdown (
      clk,
      trig_reset,
      trig_signal
  );


  reg [31:0] counter = 0;

  reg [ 2:0] state = PRIME;
  initial begin
    `RESET;
  end

  always @(posedge clk) begin

    case (state)
      PRIME: begin
        if (wait_signal == 1) begin
          state = TRIGGER;
          wait_reset = 1;
          trig_reset = 0;
          trig = 1;
        end
      end
      TRIGGER: begin
        if (trig_signal == 1) begin
          state = LISTEN;
          trig_reset = 1;
          trig = 0;
        end
      end
      LISTEN: begin
        if (echo == 1) begin
          state   = ECHO;
          counter = 0;
        end
      end
      ECHO: begin
        if (counter != MAX_ECHO) begin
          counter = counter + 1;
        end
        if (echo == 0) begin
          if (counter <= DISTANCE) begin
            counter = 0;
            state = STOPPED;
            detected = 1;
          end else begin
            `RESET;
          end
        end
      end
      STOPPED: begin
      end
      default: begin
      end
    endcase
    if (reset == 1) begin
      `RESET;
    end
  end

endmodule
