// display_inches.sv
// Module to drive a 2-digit 7-segment display showing height in inches.
// TESTING MODULE ONLY: shows height in inches (0-99) directly.

module display_inches (
    input  logic       clk,
    input  logic [7:0] inches_display,
    output logic [6:0] seg,
    output logic       dig0,
    output logic       dig1
);

    // ----------------------------------------------------------------
    // Convert inches_display → 2-digit 7-seg (tens / ones)
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
    // Time-multiplex the two digits
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

endmodule
