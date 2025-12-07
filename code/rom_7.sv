module rom_7(
    input logic [4:0] col,
    input logic [4:0] row,
    output logic [5:0] data
);

    always_comb begin
        // Default to white background
        data = 6'b111111;
        
        // Simple 8x16 digit 7 pattern
        // Top horizontal line (row 1-2)
        if ((row >= 1 && row <= 2) && (col >= 1 && col <= 6)) data = 6'b000000;
        
        // Right vertical line (row 1-14, col 6)
        if ((row >= 1 && row <= 14) && col == 6) data = 6'b000000;
    end

endmodule
