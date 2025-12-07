module rom_4(
    input logic [4:0] col,
    input logic [4:0] row,
    output logic [5:0] data
);

    always_comb begin
        // Default to white background
        data = 6'b111111;
        
        // Simple 8x16 digit 4 pattern
        // Left vertical line (row 1-8, col 1)
        if ((row >= 1 && row <= 8) && col == 1) data = 6'b000000;
        
        // Right vertical line (row 1-14, col 6)
        if ((row >= 1 && row <= 14) && col == 6) data = 6'b000000;
        
        // Middle horizontal line (row 7-8)
        if ((row >= 7 && row <= 8) && (col >= 1 && col <= 6)) data = 6'b000000;
    end

endmodule
