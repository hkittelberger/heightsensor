module rom_2(
    input logic [4:0] col,
    input logic [4:0] row,
    output logic [5:0] data
);

    always_comb begin
        // Default to white background
        data = 6'b111111;
        
        // Simple 8x16 digit 2 pattern
        // Top horizontal line (row 1-2)
        if ((row >= 1 && row <= 2) && (col >= 1 && col <= 6)) data = 6'b000000;
        
        // Top right vertical (row 1-7, col 6)
        if ((row >= 1 && row <= 7) && col == 6) data = 6'b000000;
        
        // Middle horizontal line (row 7-8)
        if ((row >= 7 && row <= 8) && (col >= 1 && col <= 6)) data = 6'b000000;
        
        // Bottom left vertical (row 8-14, col 1)
        if ((row >= 8 && row <= 14) && col == 1) data = 6'b000000;
        
        // Bottom horizontal line (row 13-14)
        if ((row >= 13 && row <= 14) && (col >= 1 && col <= 6)) data = 6'b000000;
    end

endmodule
