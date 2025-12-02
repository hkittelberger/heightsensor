module display_inches (
    input logic clk,
    input logic [31:0] echo_width,
    output logic [6:0] seg,
    output logic dig0,
    output logic dig1
);

    logic [15:0] inches_raw;
    logic [7:0] inches;

    convert_echo_to_inches convert_inst (
        .clk(clk),
        .echo_width(echo_width),
        .inches_raw(inches_raw),
        .inches(inches)
    );

    logic [3:0] ones_digit;
    logic [3:0] tens_digit;

    always_comb begin
        ones_digit = inches % 10;
        tens_digit = inches / 10;
    end

    logic [6:0] seg_ones;
    logic [6:0] seg_tens;

    seven_seg ones_display (
        .y(ones_digit),
        .seg(seg_ones)
    );

    seven_seg tens_display (
        .y(tens_digit),
        .seg(seg_tens)
    );

    logic [25:0] counter;

    always_ff @(posedge clk) begin
        counter <= counter + 1'b1;
    end

    always_comb begin
        if (counter[16]) begin
            dig0 = 1'b1;
            dig1 = 1'b0;
            seg = seg_ones;
        end else begin
            dig0 = 1'b0;
            dig1 = 1'b1;
            seg = seg_tens;
        end
    end

endmodule




