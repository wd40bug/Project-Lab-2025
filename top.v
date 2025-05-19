`timescale 1ns / 1ps


module top (
    input CLK100MHZ,
    input snA,
    snB,
    reset,
    btnD,
    btnU,
    btnL,
    btnR,
    ipsL,
    ipsR,
    inter,
    irD,
    box_dist,
    not_arm_up,
    not_arm_down,
    armOC,
    servo_O,
    output OC,
    in1,
    in2,
    in3,
    in4,
    enA,
    enB,
    irE,
    servo,
    ArmIn1,
    ArmIn2,
    ArmEn,
    static,
    reg [1:0] disp_freq,
    [6:0] seg,
    [3:0] an,
    [4:0] LED,
    reg [2:0] OLED
);
  
  localparam LISTEN = 0;
  localparam LIFT = 16;
  localparam FORWARD = 15;
  localparam DRIVE1 = 1;
  localparam TURN1 = 2;
  localparam DRIVE2 = 3;
  localparam PICKUP = 4;
  localparam TURN2 = 5;
  localparam DRIVE3 = 6;
  localparam TURN3 = 7;
  localparam DRIVE4 = 8;
  localparam PLACE = 9;
  localparam TURN4 = 10;
  localparam DRIVE5 = 11;
  localparam TURN5 = 12;
  localparam DRIVE6 = 13;
  localparam FINISH = 14;
  

  
  reg [4:0] state;
  reg [4:0] state_started;
  reg[4:0] last_state;
  assign LED = state;

  // Line tracking
  reg [1:0] ips;
  wire [2:0] ipsW;
  assign ipsW = {ipsL, ipsR, inter};

  // Overcurrent
  reg oc_reset;
  overcurrent #(32'h0F00000) oc (
      CLK100MHZ,
      snA,
      snB,
      oc_reset,
      OC,
      dbA,
      dbB
  );
  
  reg oc_cooldown_reset;
  wire oc_cooldown_signal;
  countdown #(32'd100000000) overcurrent_cooldown (
    CLK100MHZ,
    oc_cooldown_reset,
    oc_cooldown_signal
  );
  `define OC_RESET oc_reset = 1; oc_cooldown_reset = 1; // undone by reassigning to btnR

  // driver
  reg [2:0] driver_instruction;
  driver dr (
      CLK100MHZ,
      OC,
      driver_instruction,
      in1,
      in2,
      in3,
      in4,
      enA,
      enB
  );
  `define DRIVER_RESET driver_instruction = 3'b000;
  
  // Intersection Counting
  reg intersection_reset;
  reg [1:0] intersection_seek;
  wire reached_intersection;
  intersection intersection (
    CLK100MHZ,
    intersection_reset,
    inter,
    intersection_seek,
    reached_intersection
  );
  reg intersected;
  `define INTERSECTION_RESET intersection_reset = 1; intersection_seek = 0; intersected = 0;
  
  // Pickup and Place
  reg [1:0] servo_ctrl;
  reg [1:0] arm_ctrl;
  wire servo_static;
  ClawServo claw_servo(CLK100MHZ, servo_ctrl, servo, servo_static);
  arm_ctrl Arm(CLK100MHZ, arm_ctrl, armOC, ArmEn, ArmIn1, ArmIn2);
  assign arm_ctrl_l = arm_ctrl;
  assign arm_up = ~ not_arm_up;
  assign arm_down = ~ not_arm_down;
  `define CLAW_AND_ARM_RESET servo_ctrl = 2'b11; arm_ctrl = 2'b00;
  
  // Pickup
  reg [2:0] pickup_state;
  localparam PickupRev = 1;
  localparam PickupRight = 5;
  localparam PickupDescend= 2;
  localparam PickupClose = 3;
  localparam PickupLift = 4;
  
  reg pickup_rev_reset;
  wire rev_signal;
  countdown #(15_000_000) PickupRevTimer(CLK100MHZ, pickup_rev_reset, pickup_rev_signal);
  reg pickup_correction_reset;
  wire pickup_correction_signal;
  countdown #(3_000_000) PickupRightCorrection(CLK100MHZ, pickup_correction_reset, pickup_correction_signal);
  `define PICKUP_RESET pickup_state=PickupRight; pickup_rev_reset = 1; pickup_correction_reset = 1;
  
  // Place
  reg [1:0] place_state;
  localparam PlaceRelease = 1;
  localparam PlaceRev = 2;
  
  reg place_rev_reset;
  wire place_rev_signal;
  countdown #(10_000_000) PlaceRevTimer(CLK100MHZ, place_rev_reset, place_rev_signal);
  `define PLACE_RESET place_state = PlaceRelease; place_rev_reset = 1;

  // Seven segment
  reg sevenseg_reset;
  seven_segment_display sevenseg (
      CLK100MHZ,
      sevenseg_reset,
      OC,
      ipsW,
      an,
      seg
  );
  `define SEVENSEG_RESET sevenseg_reset = 1;
  `define SEVENSEG_FINISH_RESET sevenseg_reset = 0;

  // IR emitter
  reg [1:0] freq;
  reg ir_enable;
  ir_emitter ir (
      CLK100MHZ,
      ir_enable,
      freq,
      irE
  );
  `define IRE_RESET freq = 2'b00; ir_enable = 0;

  // IR detector
  reg detector_reset;
  wire [1:0] detected;
  wire valid;
  ir_detector ird (
      CLK100MHZ,
      detector_reset,
      irD,
      detected,
      valid
  );
  reg [1:0] last_detected = 0;
  reg [3:0] last_detected_count = 0;
  reg [1:0] frequency = 0;
  `define DETECTOR_RESET detector_reset = 1; last_detected = 0; last_detected_count = 0; frequency = 0; disp_freq = 0;
  `define DETECTOR_FINISH_RESET detector_reset = 0;
  
  reg just_reset;
  `define RESET state = LISTEN; `OC_RESET `DRIVER_RESET `INTERSECTION_RESET `SEVENSEG_RESET `IRE_RESET `DETECTOR_RESET `CLAW_AND_ARM_RESET `PICKUP_RESET `PLACE_RESET just_reset = 1;
   
  `define FINISH_RESET `SEVENSEG_FINISH_RESET `DETECTOR_FINISH_RESET just_reset = 0;

  initial begin 
    `RESET
  end
    assign static = servo_static;
  reg last_servo_static;
  wire servo_done = servo_static && !last_servo_static;
  always @(posedge CLK100MHZ) begin
    
    state_started = state;
    if (state == DRIVE1 ||
        state == DRIVE2 ||
        state == DRIVE3 ||
        state == DRIVE4 ||
        state == DRIVE5 ||
        state == DRIVE6 ||
        state == TURN1 ||
        state == TURN2 ||
        state == TURN3 ||
        state == TURN4 ||
        state == TURN5 || 
        state == PICKUP && pickup_state == PickupRev)begin 
      oc_cooldown_reset = ~ OC;
      oc_reset = btnR || oc_cooldown_signal;
    end
    // Common driving logic
    if (
        state == DRIVE1 ||
        state == DRIVE2 ||
        state == DRIVE3 ||
        state == DRIVE4 ||
        state == DRIVE5 ||
        state == DRIVE6)
    begin
    ips = ~{ipsL, ipsR};
      if ((state == DRIVE3 || state == DRIVE5) && ips == 2'b00) begin 
        driver_instruction = 3'b100;
      end else begin      
        driver_instruction = ips << 1;
      end
    end
    
    if ( // Turning
      state == TURN1 ||
      state == TURN2 ||
      state == TURN3 || 
      state == TURN4 || 
      state == TURN5
    ) begin 
      driver_instruction = 3'b011;
      if (intersection_reset == 1) begin // first tick of this state
        intersection_seek = 1;
      end
    end
    
    if ( // Intersection_counting
          state == FORWARD ||
          state == DRIVE1 ||
          state == TURN1 ||
          state == TURN2 ||
          state == DRIVE3 ||
          state == TURN3 || 
          state == TURN4 || 
          state == DRIVE5 ||
          state == TURN5
    ) begin 
      if (reached_intersection == 1 && intersection_reset == 0) begin 
        intersected = 1;
        intersection_reset = 1;
      end else begin 
        intersection_reset = 0;
      end
    end    

    case (state)
      LISTEN: begin
        if (last_detected_count == 3 && last_detected != 2'b00) begin
          frequency = last_detected;
          state = LIFT;
          intersection_seek = 1;
          disp_freq = frequency;
        end
        if (valid == 1) begin
          if (last_detected == detected && detected != 2'b00) begin
            last_detected_count = last_detected_count + 1;
          end else begin
            last_detected_count = 0;
          end
          last_detected = detected;
        end
        disp_freq = last_detected;
      end
      LIFT: begin 
        arm_ctrl = 2'b10;
        if (arm_up == 1) begin 
          state = FORWARD;
          arm_ctrl = 2'b00;
        end
      end
      FORWARD: begin 
        driver_instruction = 3'b110;
        if (intersected == 1) begin 
          intersected = 0;
          state = DRIVE1;
          intersection_seek = frequency;
        end
      end
      DRIVE1: begin 
        if (intersected == 1) begin 
          intersected = 0;
          state = TURN1;
        end
      end
      TURN1: begin
        if (intersected == 1) begin 
          intersected = 0;
          state = DRIVE2;
        end
      end
      DRIVE2: begin 
        if (box_dist == 0) begin 
          state = PICKUP;
          pickup_correction_reset = 0;
        end
      end
      PICKUP: begin 
        OLED = pickup_state;
        case (pickup_state)
          PickupRight: begin 
            servo_ctrl = 2'b11;
            driver_instruction = 3'b010;
            if (pickup_correction_signal == 1) begin 
              pickup_state = PickupRev;
              pickup_rev_reset = 0;
              pickup_correction_reset = 1;
            end
          end
          PickupRev: begin 
            arm_ctrl = 2'b11;
            driver_instruction = 3'b111;
            if (pickup_rev_signal == 1) begin 
              driver_instruction = 3'b001;
              pickup_rev_reset = 1;
              pickup_state = PickupDescend;
            end
          end
          PickupDescend: begin 
            driver_instruction = 3'b000;
            arm_ctrl = 2'b01;
            if (arm_down == 1) begin 
              pickup_state = PickupClose;
            end
          end
          PickupClose: begin 
            arm_ctrl = 2'b11;
            servo_ctrl = 2'b10;
            if (servo_static == 1) begin 
              pickup_state = PickupLift;
            end
          end
          PickupLift: begin 
            arm_ctrl = 2'b10;
            if (arm_up == 1) begin 
              arm_ctrl = 2'b00;
              servo_ctrl = 2'b00;
              state = TURN2;
            end
          end
        endcase
      end
      TURN2: begin
        if (intersected == 1) begin 
          intersected = 0;
          state=DRIVE3;
          intersection_seek = 1;
        end
      end
      DRIVE3: begin 
        if (intersected == 1) begin 
          intersected = 0;
          state = TURN3;
        end
      end
      TURN3: begin 
        if (intersected == 1) begin 
          intersected = 0;
          state = DRIVE4;
        end
      end
      DRIVE4: begin 
        if (box_dist == 0) begin 
          state = PLACE;
        end
      end
      PLACE: begin 
        driver_instruction = 3'b001;
        OLED = place_state;
        case (place_state)
          PlaceRelease: begin
            servo_ctrl = 2'b11;
            if (servo_static == 1) begin 
              place_rev_reset = 0;
              place_state = PlaceRev;
            end
          end
          PlaceRev: begin 
            driver_instruction = 3'b111;
            if (place_rev_signal == 1) begin 
              state = TURN4;
              arm_ctrl = 2'b00;
            end
          end
        endcase
      end
      TURN4: begin 
        if (intersected == 1) begin 
          intersected = 0;
          state = DRIVE5;
          intersection_seek = 1;
        end
      end
      DRIVE5: begin 
        if (intersected == 1) begin
          intersected = 0; 
          state = TURN5;
        end
      end
      TURN5: begin 
        if (intersected == 1) begin 
          intersected = 0;
          state = DRIVE6;
        end
      end
      DRIVE6: begin 
        freq=frequency;
        ir_enable = 1;
        if (box_dist == 0) begin 
          if (ips == 2'b00) begin 
            state = FINISH;
          end
        end
      end
      FINISH: begin
        driver_instruction = 3'b001;
      end

      default: begin
      end

    endcase
    if (just_reset == 1) begin 
      `FINISH_RESET
    end
    if (reset == 1) begin 
      `RESET
    end

    last_state = state_started;
    last_servo_static = servo_static;
  end

endmodule
