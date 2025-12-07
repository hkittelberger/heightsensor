module rom_quote(
    input logic [4:0] col,
    input logic [4:0] row,
    output logic [5:0] data
);

    always_comb begin
        // Default to white background
        data = 6'b111111;
        
        // Simple quote pattern - two small vertical lines at top
        if ((row >= 2 && row <= 5)) begin
            if ((col >= 1 && col <= 2) || (col >= 4 && col <= 5)) begin
                data = 6'b000000; // Black quote marks
            end
        end
    end

endmodule
