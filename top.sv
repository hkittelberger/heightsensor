module top(
    input logic echo,
    output logic led,
    output logic trig,
    output logic [6:0] seg,
    output logic dig0,
    output logic dig1
);


    logic clk;

    // HSOSC component -> On chip oscillator
     SB_HFOSC #(
        .CLKHF_DIV("0b10")
    ) osc (
        .CLKHFPU(1'b1), // Power up
        .CLKHFEN(1'b1), // Enable
        .CLKHF(clk), // Clock output
        .TRIM0(1'b0), .TRIM1(1'b0), .TRIM2(1'b0), .TRIM3(1'b0), .TRIM4(1'b0),
        .TRIM5(1'b0), .TRIM6(1'b0), .TRIM7(1'b0), .TRIM8(1'b0), .TRIM9(1'b0)
    );

    logic [31:0] echo_cycles;

    sensor sensor_inst (
        .clk(clk),
        .echo(echo),
        .trig(trig),
        .led(led),
        .echo_cycles(echo_cycles)
    );

    display_inches inches_display (
        .clk(clk),
        .echo_width(echo_cycles),
        .seg(seg),
        .dig0(dig0),
        .dig1(dig1)
    );

endmodule