module inches_to_feet_inches (
    input  logic [7:0] total_inches,    // Total height in inches (0-99)
    output logic [3:0] feet,            // Feet portion (0-8 for heights up to 99")
    output logic [3:0] inches           // Inches portion (0-11)
);

    always_comb begin
        feet = total_inches / 8'd12;    // Integer division gives feet
        inches = total_inches % 8'd12;  // Modulo gives remaining inches
        
        // Limit to reasonable ranges
        if (feet > 4'd8) feet = 4'd8;       // Max 8 feet display
        if (inches > 4'd11) inches = 4'd11; // Max 11 inches
    end

endmodule
