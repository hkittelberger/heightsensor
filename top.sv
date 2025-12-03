module top(
    input logic echo,
    input logic btn,           // Button to cycle through history
    output logic led,
    output logic trig,
    output logic [6:0] seg,    // First display (current reading)
    output logic dig0,
    output logic dig1,
    output logic [6:0] seg2,   // Second display (history)
    output logic dig2,
    output logic dig3,
    output logic led_save
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
    
    // History signals
    logic [7:0] hist_0, hist_1, hist_2, hist_3, hist_4;
    logic [7:0] hist_5, hist_6, hist_7, hist_8, hist_9;

    sensor sensor_inst (
        .clk(clk),
        .echo(echo),
        .trig(trig),
        .led(led),
        .echo_cycles(echo_cycles)
    );

    set_reading inches_display (
        .clk(clk),
        .echo_width(echo_cycles),
        .seg(seg),
        .dig0(dig0),
        .dig1(dig1),
        .led_save(led_save),
        .hist_0_out(hist_0),
        .hist_1_out(hist_1),
        .hist_2_out(hist_2),
        .hist_3_out(hist_3),
        .hist_4_out(hist_4),
        .hist_5_out(hist_5),
        .hist_6_out(hist_6),
        .hist_7_out(hist_7),
        .hist_8_out(hist_8),
        .hist_9_out(hist_9)
    );
    
    history_display hist_display (
        .clk(clk),
        .btn(btn),
        .hist_0(hist_0),
        .hist_1(hist_1),
        .hist_2(hist_2),
        .hist_3(hist_3),
        .hist_4(hist_4),
        .hist_5(hist_5),
        .hist_6(hist_6),
        .hist_7(hist_7),
        .hist_8(hist_8),
        .hist_9(hist_9),
        .seg(seg2),
        .dig0(dig2),
        .dig1(dig3)
    );

endmodule