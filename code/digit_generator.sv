module digit_generator(
    input logic [4:0] col,        // 0-15 (16 pixels wide)
    input logic [4:0] row,        // 0-15 (16 pixels tall) 
    input logic [3:0] digit,      // 0-9
    output logic pixel            // 1 = black digit, 0 = white background
);

    // Simple 8x16 digit patterns using case statements
    // Each digit is defined as a series of horizontal lines
    always_comb begin
        pixel = 1'b0; // Default to white background
        
        case (digit)
            4'd0: begin // Digit 0
                if ((row >= 1 && row <= 14) && (col == 2 || col == 13)) pixel = 1'b1; // Sides
                if ((row == 1 || row == 14) && (col >= 3 && col <= 12)) pixel = 1'b1; // Top/Bottom
            end
            
            4'd1: begin // Digit 1
                if (col == 8) pixel = 1'b1; // Vertical line
                if (row == 14 && (col >= 6 && col <= 10)) pixel = 1'b1; // Bottom
                if (row == 2 && col == 7) pixel = 1'b1; // Top diagonal
            end
            
            4'd2: begin // Digit 2
                if (row == 1 && (col >= 3 && col <= 12)) pixel = 1'b1; // Top
                if (row == 8 && (col >= 3 && col <= 12)) pixel = 1'b1; // Middle
                if (row == 14 && (col >= 2 && col <= 13)) pixel = 1'b1; // Bottom
                if ((row >= 2 && row <= 7) && col == 13) pixel = 1'b1; // Top right
                if ((row >= 9 && row <= 13) && col == 2) pixel = 1'b1; // Bottom left
            end
            
            4'd3: begin // Digit 3
                if (row == 1 && (col >= 3 && col <= 12)) pixel = 1'b1; // Top
                if (row == 8 && (col >= 3 && col <= 12)) pixel = 1'b1; // Middle
                if (row == 14 && (col >= 3 && col <= 12)) pixel = 1'b1; // Bottom
                if ((row >= 2 && row <= 13) && col == 13) pixel = 1'b1; // Right side
            end
            
            4'd4: begin // Digit 4
                if ((row >= 1 && row <= 8) && col == 2) pixel = 1'b1; // Left side
                if ((row >= 1 && row <= 14) && col == 13) pixel = 1'b1; // Right side
                if (row == 8 && (col >= 2 && col <= 13)) pixel = 1'b1; // Middle
            end
            
            4'd5: begin // Digit 5
                if (row == 1 && (col >= 2 && col <= 13)) pixel = 1'b1; // Top
                if (row == 8 && (col >= 2 && col <= 12)) pixel = 1'b1; // Middle
                if (row == 14 && (col >= 3 && col <= 12)) pixel = 1'b1; // Bottom
                if ((row >= 2 && row <= 7) && col == 2) pixel = 1'b1; // Top left
                if ((row >= 9 && row <= 13) && col == 13) pixel = 1'b1; // Bottom right
            end
            
            4'd6: begin // Digit 6
                if (row == 1 && (col >= 3 && col <= 12)) pixel = 1'b1; // Top
                if (row == 8 && (col >= 3 && col <= 12)) pixel = 1'b1; // Middle
                if (row == 14 && (col >= 3 && col <= 12)) pixel = 1'b1; // Bottom
                if ((row >= 2 && row <= 13) && col == 2) pixel = 1'b1; // Left side
                if ((row >= 9 && row <= 13) && col == 13) pixel = 1'b1; // Bottom right
            end
            
            4'd7: begin // Digit 7
                if (row == 1 && (col >= 2 && col <= 13)) pixel = 1'b1; // Top
                if ((row >= 2 && row <= 14) && col == 13) pixel = 1'b1; // Right side
            end
            
            4'd8: begin // Digit 8
                if ((row == 1 || row == 8 || row == 14) && (col >= 3 && col <= 12)) pixel = 1'b1; // Horizontal lines
                if ((row >= 2 && row <= 13) && (col == 2 || col == 13)) pixel = 1'b1; // Vertical lines
            end
            
            4'd9: begin // Digit 9
                if (row == 1 && (col >= 3 && col <= 12)) pixel = 1'b1; // Top
                if (row == 8 && (col >= 3 && col <= 12)) pixel = 1'b1; // Middle
                if (row == 14 && (col >= 3 && col <= 12)) pixel = 1'b1; // Bottom
                if ((row >= 2 && row <= 7) && (col == 2 || col == 13)) pixel = 1'b1; // Top sides
                if ((row >= 9 && row <= 13) && col == 13) pixel = 1'b1; // Bottom right
            end
            
            default: pixel = 1'b0; // Unknown digit - white
        endcase
    end

endmodule
