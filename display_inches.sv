module display_inches (
    input  logic        clk,
    input  logic [31:0] echo_width,
    output logic [6:0]  seg,
    output logic        dig0,
    output logic        dig1,
    output logic        led_save
);

    // ----------------------------------------------------------------
    // 1) Convert echo width to inches (0–99")
    // ----------------------------------------------------------------
    logic [15:0] inches_raw;
    logic [7:0]  inches_live;   // raw live distance from sensor

    convert_echo_to_inches convert_inst (
        .clk       (clk),
        .echo_width(echo_width),
        .inches_raw(inches_raw),
        .inches    (inches_live)
    );

    // ----------------------------------------------------------------
    // 2) FSM to latch a height after 3s below 48"
    // ----------------------------------------------------------------
    localparam logic [7:0] GROUND_THRESHOLD_INCHES = 8'd48;

    // Assuming ~12 MHz HFOSC (48 MHz / 4)
    localparam int CLK_FREQ_HZ   = 12_000_000;
    localparam int HOLD_TIME_SEC = 3;
    localparam int HOLD_TICKS    = CLK_FREQ_HZ * HOLD_TIME_SEC;  // 36,000,000

    localparam int FLASH_TIME_MS  = 250; // quarter second
    localparam int CLK_FREQ_HZ    = 12_000_000; // same as used for HOLD_TICKS
    localparam int FLASH_TICKS    = (CLK_FREQ_HZ / 1000) * FLASH_TIME_MS;

    logic [31:0] flash_counter = 32'd0;

    typedef enum logic [1:0] {
        S_DEFAULT,   // seeing the ground (or anything >= 48")
        S_TIMING,    // person detected, counting 3 seconds
        S_LATCHED    // height saved, waiting for person to leave
    } state_t;

    state_t      state = S_DEFAULT;
    logic [31:0] hold_counter = 32'd0;
    logic [7:0]  inches_latched = 8'd0;

    // What value we actually send to the 7-seg
    logic [7:0] inches_display;

    // FSM: updates state, counter, and latched value
    always_ff @(posedge clk) begin
        case (state)
            // --------------------------------------------------------
            // Ground / default: show live inches, wait for < 48"
            // --------------------------------------------------------
            S_DEFAULT: begin
                hold_counter   <= 32'd0;
                inches_latched <= inches_latched; // keep old value, but not used in this state

                if (inches_live < GROUND_THRESHOLD_INCHES) begin
                    // Person just entered: start timing
                    state         <= S_TIMING;
                    hold_counter  <= 32'd1;
                    inches_latched <= inches_live;   // start with current value
                end
            end

            // --------------------------------------------------------
            // Timing: still below 48", counting to 3 seconds
            // --------------------------------------------------------
            S_TIMING: begin
                if (inches_live >= GROUND_THRESHOLD_INCHES) begin
                    // Person left before 3 seconds – abort and go back to default
                    state        <= S_DEFAULT;
                    hold_counter <= 32'd0;
                end else begin
                    // Still under the doorway; keep updating "best" value
                    inches_latched <= inches_live;

                    if (hold_counter >= HOLD_TICKS) begin
                        // Done: freeze the current inches_latched
                        state <= S_LATCHED;

                        flash_counter <= FLASH_TICKS;
                    end else begin
                        hold_counter <= hold_counter + 1;
                    end
                end
            end

            // --------------------------------------------------------
            // Latched: keep showing saved value until ground again
            // --------------------------------------------------------
            S_LATCHED: begin
                // Stay latched, ignore live distance for display,
                // but watch for the person leaving (back to ground)
                if (inches_live >= GROUND_THRESHOLD_INCHES) begin
                    state        <= S_DEFAULT;
                    hold_counter <= 32'd0;
                end
            end

            default: begin
                state        <= S_DEFAULT;
                hold_counter <= 32'd0;
            end
        endcase

        if (flash_counter != 0)
            flash_counter <= flash_counter - 1;

    end

    // Decide what goes on the display:
    // - DEFAULT/TIMING: show live inches
    // - LATCHED: show frozen height
    always_comb begin
        case (state)
            S_LATCHED: inches_display = inches_latched;
            default:   inches_display = inches_live;
        endcase
    end

    // ----------------------------------------------------------------
    // 3) Convert inches_display → 2-digit 7-seg (tens / ones)
    // ----------------------------------------------------------------
    logic [3:0] tens;
    logic [3:0] ones;
    logic [6:0] seg_tens;
    logic [6:0] seg_ones;

    // Simple binary → decimal digits (0–99)
    always_comb begin
        tens = inches_display / 8'd10;
        ones = inches_display % 8'd10;
    end

    seven_seg seg_tens_inst (
        .y  (tens),
        .seg(seg_tens)
    );

    seven_seg seg_ones_inst (
        .y  (ones),
        .seg(seg_ones)
    );

    // ----------------------------------------------------------------
    // 4) Time-multiplex the two digits
    //    (reuse your original idea: toggle a bit of a counter)
    // ----------------------------------------------------------------
    logic [15:0] mux_counter = 16'd0;

    always_ff @(posedge clk) begin
        mux_counter <= mux_counter + 16'd1;
    end

    always_comb begin
        if (mux_counter[15]) begin
            // Show ones digit
            dig0 = 1'b1;   // active digit 0
            dig1 = 1'b0;
            seg  = seg_ones;
        end else begin
            // Show tens digit
            dig0 = 1'b0;
            dig1 = 1'b1;   // active digit 1
            seg  = seg_tens;
        end
    end

     assign led_save = (flash_counter != 0);

endmodule
