module top(
    input logic echo,
    input logic btn,           // Button to cycle through history
    // output logic led,
    output logic trig,
    output logic [6:0] seg,    // First display (current reading)
    output logic dig0,
    output logic dig1,
    output logic [6:0] seg2,   // Second display (history)
    output logic dig2,
    output logic dig3,
    output logic led_save,
    // VGA outputs
    output logic RED1,
    output logic RED0,
    output logic GRN1,
    output logic GRN0,
    output logic BLU1,
    output logic BLU0,
    output logic HSYNC,
    output logic VSYNC,
    input logic clk_12M
);


    logic clk;
    logic vga_clk;

    // HSOSC component -> On chip oscillator (12 MHz)
     SB_HFOSC #(
        .CLKHF_DIV("0b10")
    ) osc (
        .CLKHFPU(1'b1), // Power up
        .CLKHFEN(1'b1), // Enable
        .CLKHF(clk), // Clock output
        .TRIM0(1'b0), .TRIM1(1'b0), .TRIM2(1'b0), .TRIM3(1'b0), .TRIM4(1'b0),
        .TRIM5(1'b0), .TRIM6(1'b0), .TRIM7(1'b0), .TRIM8(1'b0), .TRIM9(1'b0)
    );

    // PLL to generate 25.175 MHz VGA clock from 12 MHz input
    my_pll pll_inst (
        // .ref_clk_i(clk_12M),        // 12 MHz input
        .ref_clk_i(clk),
        .rst_n_i(1'b1),         // No reset for now
        .outcore_o(),           // Unused
        .outglobal_o(vga_clk)   // 25.175 MHz VGA clock
    );

    logic [31:0] echo_cycles;
    
    // History signals
    logic [7:0] hist_0, hist_1, hist_2, hist_3, hist_4;
    logic [7:0] hist_5, hist_6, hist_7, hist_8, hist_9;

    sensor sensor_inst (
        .clk(clk),
        .echo(echo),
        .trig(trig),
        // .led(led),
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

    // ================================================================
    // VGA Display Section
    // ================================================================
    
    // VGA timing and coordinate signals
    logic [9:0] vga_col, vga_row;
    logic vga_valid;
    logic h_sync, v_sync;
    
    // VGA color signals (2 bits each for RGB)
    logic [1:0] red_signal, green_signal, blue_signal;
    
    // VGA timing generator
    my_vga vga_inst (
        .vga_clock(vga_clk),
        .vga_col(vga_col),
        .vga_row(vga_row),
        .vga_valid(vga_valid),
        .h_sync(h_sync),
        .v_sync(v_sync)
    );
    
    // Pattern generator (test pattern for now)
    my_pattern_gen pattern_inst (
        .genclock(vga_clk),
        .genrow(vga_row),
        .gencol(vga_col),
        .genvalid(vga_valid),
        .genred(red_signal),
        .gengreen(green_signal),
        .genblue(blue_signal)
    );
    
    // Connect VGA signals to output pins
    assign RED1 = red_signal[1];
    assign RED0 = red_signal[0];
    assign GRN1 = green_signal[1];
    assign GRN0 = green_signal[0];
    assign BLU1 = blue_signal[1];
    assign BLU0 = blue_signal[0];
    assign HSYNC = h_sync;
    assign VSYNC = v_sync;

endmodule