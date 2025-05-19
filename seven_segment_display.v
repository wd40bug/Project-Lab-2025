`timescale 1ns / 1ps

module seven_segment_display (
    input  wire       clk,          // 100 MHz clock from Basys3
    input  wire       reset,        // Reset signal
    input  wire       overcurrent,  // Overcurrent status (1 bit)
    input  wire [2:0] sensor,       // 3 sensors: [2]=left, [1]=middle, [0]=right
    output reg  [3:0] an,           // Anode control (active LOW)
    output reg  [6:0] seg           // Segment control (active LOW on Basys3)
);

  // Digit selection states
  parameter DIGIT0 = 2'b00;  // leftmost digit
  parameter DIGIT1 = 2'b01;
  parameter DIGIT2 = 2'b10;
  parameter DIGIT3 = 2'b11;  // rightmost digit

  reg [ 1:0] current_digit;
  reg [19:0] refresh_counter;  // Adjust for refresh rate
  reg [ 3:0] display_value;

  //logic for digit multiplexing
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      refresh_counter <= 0;
      current_digit   <= DIGIT0;
      an              <= 4'b0111;  // Activate leftmost digit first
    end else begin
      refresh_counter <= refresh_counter + 1;
      if (refresh_counter == 20_000_000) begin
        refresh_counter <= 0;
        current_digit   <= current_digit + 1;
        case (current_digit)
          DIGIT0:  an <= 4'b1011;  // Next digit
          DIGIT1:  an <= 4'b1101;
          DIGIT2:  an <= 4'b1110;
          DIGIT3:  an <= 4'b0111;  // Back to leftmost
          default: an <= 4'b1111;
        endcase
      end
    end
  end

  // Assign a 4-bit value for each digit
  always @(*) begin
    case (current_digit)
      DIGIT0: begin
        // Overcurrent: F if fault, else 0
        display_value = (overcurrent) ? 4'hF : 4'h0;
      end
      DIGIT1: begin
        // Left sensor -> display '1' or '0'
        display_value = (sensor[2]) ? 4'h1 : 4'h0;
      end
      DIGIT2: begin
        // Middle sensor -> display '1' or '0'
        display_value = (sensor[1]) ? 4'h1 : 4'h0;
      end
      DIGIT3: begin
        // Right sensor -> display '1' or '0'
        display_value = (sensor[0]) ? 4'h1 : 4'h0;
      end
      default: display_value = 4'h0;
    endcase
  end

  // Seven-segment encoding (active LOW segments on Basys3)
  always @(*) begin
    case (display_value)
      4'd0: seg = 7'b1000000;  // 0
      4'd1: seg = 7'b1111001;  // 1
      4'd2: seg = 7'b0100100;  // 2
      4'd3: seg = 7'b0110000;  // 3
      4'd4: seg = 7'b0011001;  // 4
      4'd5: seg = 7'b0010010;  // 5
      4'd6: seg = 7'b0000010;  // 6
      4'd7: seg = 7'b1111000;  // 7
      4'd8: seg = 7'b0000000;  // 8
      4'd9: seg = 7'b0010000;  // 9
      4'd10: seg = 7'b0001000;  // A
      4'd11: seg = 7'b0000011;  // b
      4'd12: seg = 7'b1000110;  // C
      4'd13: seg = 7'b0100001;  // d
      4'd14: seg = 7'b0000110;  // E
      4'd15: seg = 7'b0001110;  // F
      default: seg = 7'b1111111;  // all off
    endcase
  end

endmodule
