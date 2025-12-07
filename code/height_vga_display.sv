module height_vga_display(
    input logic [9:0] Row,
    input logic [9:0] Col,
    input logic valid,
    input logic [7:0] hist_0,  // Most recent
    input logic [7:0] hist_1,
    input logic [7:0] hist_2,
    input logic [7:0] hist_3,
    input logic [7:0] hist_4,
    input logic [7:0] hist_5,
    input logic [7:0] hist_6,
    input logic [7:0] hist_7,
    input logic [7:0] hist_8,
    input logic [7:0] hist_9,  // Oldest
    output logic [5:0] rgb_out
);

    // ROM connections
    logic [4:0] rom_col_in, rom_row_in;
    logic [5:0] rom_0_rgb, rom_8_rgb;
    
    // Instantiate digit ROMs
    rom_0 rom_0_inst (.col(rom_col_in), .row(rom_row_in), .data(rom_0_rgb));
    rom_8 rom_8_inst (.col(rom_col_in), .row(rom_row_in), .data(rom_8_rgb));
    
    // Define display parameters
    localparam int DIGIT_WIDTH = 16;   // Each digit is 16 pixels wide
    localparam int DIGIT_HEIGHT = 32;  // Each digit is 32 pixels tall
    localparam int DIGIT_SPACING = 20; // Space between digits
    localparam int ROW_HEIGHT = 40;    // Height of each height display row
    localparam int START_X = 50;       // Starting X position
    localparam int START_Y = 50;       // Starting Y position
    
    // Current height being processed (0-9)
    logic [3:0] current_height_index;
    logic [7:0] current_height_value;
    
    // Current digit being processed (tens or ones)
    logic is_tens_digit;
    logic [3:0] tens_digit, ones_digit;
    
    // Position calculations
    logic [9:0] height_row_start, height_row_end;
    logic [9:0] tens_col_start, tens_col_end;
    logic [9:0] ones_col_start, ones_col_end;
    logic in_height_area, in_tens_area, in_ones_area;
    
    // Determine which height we're displaying based on row
    always_comb begin
        if (Row >= START_Y && Row < START_Y + (10 * ROW_HEIGHT)) begin
            current_height_index = (Row - START_Y) / ROW_HEIGHT;
        end else begin
            current_height_index = 4'd0;
        end
        
        // Select the height value based on index
        case (current_height_index)
            4'd0: current_height_value = hist_0;
            4'd1: current_height_value = hist_1;
            4'd2: current_height_value = hist_2;
            4'd3: current_height_value = hist_3;
            4'd4: current_height_value = hist_4;
            4'd5: current_height_value = hist_5;
            4'd6: current_height_value = hist_6;
            4'd7: current_height_value = hist_7;
            4'd8: current_height_value = hist_8;
            4'd9: current_height_value = hist_9;
            default: current_height_value = 8'd0;
        endcase
        
        // Calculate tens and ones digits
        tens_digit = current_height_value / 8'd10;
        ones_digit = current_height_value % 8'd10;
    end
    
    // Calculate position boundaries for current height row
    always_comb begin
        height_row_start = START_Y + (current_height_index * ROW_HEIGHT);
        height_row_end = height_row_start + DIGIT_HEIGHT;
        
        tens_col_start = START_X;
        tens_col_end = tens_col_start + DIGIT_WIDTH;
        
        ones_col_start = tens_col_end + DIGIT_SPACING;
        ones_col_end = ones_col_start + DIGIT_WIDTH;
        
        // Check if we're in the height display area
        in_height_area = (Row >= height_row_start && Row < height_row_end);
        in_tens_area = (Col >= tens_col_start && Col < tens_col_end);
        in_ones_area = (Col >= ones_col_start && Col < ones_col_end);
    end
    
    // ROM coordinate calculation
    always_comb begin
        if (in_height_area && in_tens_area) begin
            rom_col_in = (Col - tens_col_start) >> 1;  // Scale down by 2
            rom_row_in = (Row - height_row_start) >> 1; // Scale down by 2
        end else if (in_height_area && in_ones_area) begin
            rom_col_in = (Col - ones_col_start) >> 1;  // Scale down by 2
            rom_row_in = (Row - height_row_start) >> 1; // Scale down by 2
        end else begin
            rom_col_in = 5'd0;
            rom_row_in = 5'd0;
        end
    end
    
    // Output RGB based on what we're displaying
    always_comb begin
        if (valid) begin
            // Default to white background
            rgb_out = 6'b111111;
            
            if (in_height_area) begin
                if (in_tens_area) begin
                    // Display tens digit
                    case (tens_digit)
                        4'd0: rgb_out = rom_0_rgb;
                        4'd8: rgb_out = rom_8_rgb;
                        // For now, only 0 and 8 are available
                        // TODO: Add ROM modules for digits 1-7, 9
                        default: rgb_out = 6'b000000; // Black for unsupported digits
                    endcase
                end else if (in_ones_area) begin
                    // Display ones digit
                    case (ones_digit)
                        4'd0: rgb_out = rom_0_rgb;
                        4'd8: rgb_out = rom_8_rgb;
                        // For now, only 0 and 8 are available
                        // TODO: Add ROM modules for digits 1-7, 9
                        default: rgb_out = 6'b000000; // Black for unsupported digits
                    endcase
                end
            end
        end else begin
            // Outside valid area - black
            rgb_out = 6'b000000;
        end
    end

endmodule
