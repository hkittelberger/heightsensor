module set_reading (
    input  logic        clk,
    input  logic [31:0] echo_width,
    output logic [6:0]  seg,
    output logic        dig0,
    output logic        dig1,
    output logic        led_save,
    // History outputs
    output logic [7:0]  hist_0_out,
    output logic [7:0]  hist_1_out,
    output logic [7:0]  hist_2_out,
    output logic [7:0]  hist_3_out,
    output logic [7:0]  hist_4_out,
    output logic [7:0]  hist_5_out,
    output logic [7:0]  hist_6_out,
    output logic [7:0]  hist_7_out,
    output logic [7:0]  hist_8_out,
    output logic [7:0]  hist_9_out
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
    
    // Height history signals
    logic        save_height;
    logic [7:0]  hist_0, hist_1, hist_2, hist_3, hist_4;
    logic [7:0]  hist_5, hist_6, hist_7, hist_8, hist_9;

    // FSM: updates state, counter, and latched value
    always_ff @(posedge clk) begin
        save_height <= 1'b0; // Default: don't save height
        
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
                        // Done: freeze the current inches_latched and save to history
                        state <= S_LATCHED;
                        flash_counter <= FLASH_TICKS;
                        save_height <= 1'b1; // Trigger height save
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
    // 3) Instantiate height_history module to store last 10 heights
    // ----------------------------------------------------------------
    height_history history_inst (
        .clk        (clk),
        .reset      (1'b0),           // No reset for now
        .save_height(save_height),
        .new_height (inches_latched),
        .history_0  (hist_0),
        .history_1  (hist_1),
        .history_2  (hist_2),
        .history_3  (hist_3),
        .history_4  (hist_4),
        .history_5  (hist_5),
        .history_6  (hist_6),
        .history_7  (hist_7),
        .history_8  (hist_8),
        .history_9  (hist_9)
    );

    // ----------------------------------------------------------------
    // 4) Instantiate display_inches module for 7-segment display
    // ----------------------------------------------------------------
    display_inches display_inst (
        .clk           (clk),
        .inches_display(inches_display),
        .seg           (seg),
        .dig0          (dig0),
        .dig1          (dig1)
    );

    assign led_save = (flash_counter != 0);
    
    // Connect internal history signals to outputs
    assign hist_0_out = hist_0;
    assign hist_1_out = hist_1;
    assign hist_2_out = hist_2;
    assign hist_3_out = hist_3;
    assign hist_4_out = hist_4;
    assign hist_5_out = hist_5;
    assign hist_6_out = hist_6;
    assign hist_7_out = hist_7;
    assign hist_8_out = hist_8;
    assign hist_9_out = hist_9;

endmodule
