module top (
    input logic clk_12M,        // pulling this from 12m pin on board (set_io -pullup yes clk_12M 20) in top pcf file
    output logic hsync,
    output logic vsync,
    output logic [5:0] rgb_out 
);
    logic pll_clk;
    logic lockedin;
    logic valid;
    logic [9:0] col;
    logic [9:0] row;
    
    
    my_pll my_pll (.ref_clk_i(clk_12M),.outglobal_o(pll_clk),.rst_n_i(1'b1),);
    my_vga vga (.vga_clock(pll_clk),.vga_col(col),.vga_row(row),.vga_valid(valid),.h_sync(hsync),.v_sync(vsync));
    my_patterngen patterngen (.Row(row), .Col(col), .valid(valid), .rgb_out(rgb_out));



endmodule