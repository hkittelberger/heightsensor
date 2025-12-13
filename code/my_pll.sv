// my_pll.sv
// PLL module to generate 25.175 MHz VGA clock from 12 MHz input clock

module my_pll (
    input ref_clk_i,	// 12 MHz clock from Upduino pin
    input rst_n_i,		// active-low reset
    output outcore_o,	// internal routed clock
    output outglobal_o	// global clock (preferred)
);

    wire lock;

    SB_PLL40_CORE #(
    .DIVR(4'd0),
    .DIVF(7'd66),
    .DIVQ(3'd5),
    .FILTER_RANGE(3'b001),
    .FEEDBACK_PATH("SIMPLE")
        ) pll_inst (
            .REFERENCECLK(ref_clk_i),	// take clock from fabric
            .PLLOUTCORE(outcore_o),
            .PLLOUTGLOBAL(outglobal_o),		//25.175 MHz
            .RESETB(rst_n_i),
            .BYPASS(1'b0),
            .LOCK(lock)
        );

endmodule
