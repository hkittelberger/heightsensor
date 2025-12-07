module rom_apostrophe(
    input logic [4:0] col,
    input logic [4:0] row,
    output logic [5:0] data
);

    always_comb begin
        // Default to white background
        data = 6'b111111;
        
        // Simple apostrophe pattern - small vertical line at top
        // Position it in upper portion of character area
        if ((row >= 2 && row <= 5) && (col >= 2 && col <= 3)) begin
            data = 6'b000000; // Black apostrophe
        end
    end

endmodule
