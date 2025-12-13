// convert_echo_to_inches.sv
// Module to convert ultrasonic sensor echo width to distance in inches

module convert_echo_to_inches (
    input logic clk,
    input logic [31:0] echo_width,
    output logic [15:0] inches_raw,
    output logic [7:0] inches
);

    always_ff @(posedge clk) begin
        logic [31:0] w;

        w = echo_width * 32'd37;
        inches_raw <= w >> 16;

        if (inches_raw > 16'd99)
            inches <= 8'd99;
        else
            inches <= inches_raw[7:0];
    end

endmodule