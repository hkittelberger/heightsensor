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
    logic [5:0] rom_0_rgb, rom_1_rgb, rom_2_rgb, rom_3_rgb, rom_4_rgb;
    logic [5:0] rom_5_rgb, rom_6_rgb, rom_7_rgb, rom_8_rgb, rom_9_rgb;
    logic [5:0] rom_apostrophe_rgb, rom_quote_rgb;
    
    // Instantiate all digit ROMs
    rom_0 rom_0_inst (.col(rom_col_in), .row(rom_row_in), .data(rom_0_rgb));
    rom_1 rom_1_inst (.col(rom_col_in), .row(rom_row_in), .data(rom_1_rgb));
    rom_2 rom_2_inst (.col(rom_col_in), .row(rom_row_in), .data(rom_2_rgb));
    rom_3 rom_3_inst (.col(rom_col_in), .row(rom_row_in), .data(rom_3_rgb));
    rom_4 rom_4_inst (.col(rom_col_in), .row(rom_row_in), .data(rom_4_rgb));
    rom_5 rom_5_inst (.col(rom_col_in), .row(rom_row_in), .data(rom_5_rgb));
    rom_6 rom_6_inst (.col(rom_col_in), .row(rom_row_in), .data(rom_6_rgb));
    rom_7 rom_7_inst (.col(rom_col_in), .row(rom_row_in), .data(rom_7_rgb));
    rom_8 rom_8_inst (.col(rom_col_in), .row(rom_row_in), .data(rom_8_rgb));
    rom_9 rom_9_inst (.col(rom_col_in), .row(rom_row_in), .data(rom_9_rgb));
    
    // Instantiate symbol ROMs
    rom_apostrophe rom_apostrophe_inst (.col(rom_col_in), .row(rom_row_in), .data(rom_apostrophe_rgb));
    rom_quote rom_quote_inst (.col(rom_col_in), .row(rom_row_in), .data(rom_quote_rgb));
    
    // Define display parameters for F'II" format (5 characters)
    localparam int CHAR_WIDTH = 16;     // Each character is 16 pixels wide
    localparam int CHAR_HEIGHT = 32;    // Each character is 32 pixels tall  
    localparam int CHAR_SPACING = 2;    // Small space between characters
    localparam int ROW_HEIGHT = 40;     // Height of each height display row
    localparam int START_X = 50;        // Starting X position
    localparam int START_Y = 50;        // Starting Y position
    
    // Current height being processed (0-9)
    logic [3:0] current_height_index;
    logic [7:0] current_height_value;
    
    // Feet and inches breakdown
    logic [3:0] feet_digit;           // 0-8 feet
    logic [3:0] inches_total;         // 0-11 inches
    logic [3:0] inches_tens_digit;    // 0-1 (for 00-11 inches)
    logic [3:0] inches_ones_digit;    // 0-9
    
    // Convert total inches to feet and inches
    inches_to_feet_inches converter_inst (
        .total_inches(current_height_value),
        .feet(feet_digit),
        .inches(inches_total)
    );
    
    // Position calculations for F'II" format (5 characters)
    logic [9:0] height_row_start, height_row_end;
    logic [9:0] feet_col_start, feet_col_end;           // Position for feet digit
    logic [9:0] apos_col_start, apos_col_end;           // Position for apostrophe 
    logic [9:0] inch_tens_col_start, inch_tens_col_end; // Position for inches tens
    logic [9:0] inch_ones_col_start, inch_ones_col_end; // Position for inches ones  
    logic [9:0] quote_col_start, quote_col_end;         // Position for quote
    
    logic in_height_area, in_feet_area, in_apos_area;
    logic in_inch_tens_area, in_inch_ones_area, in_quote_area;
    
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
        
        // Calculate inches digits (0-11 becomes 00-11)
        inches_tens_digit = inches_total / 4'd10;  // 0 or 1
        inches_ones_digit = inches_total % 4'd10;  // 0-9 (but limited to 0-1 for tens)
    end
    
    // Calculate position boundaries for current height row (F'II" format)
    always_comb begin
        height_row_start = START_Y + (current_height_index * ROW_HEIGHT);
        height_row_end = height_row_start + CHAR_HEIGHT;
        
        // Character positions: F ' I I "
        feet_col_start = START_X;
        feet_col_end = feet_col_start + CHAR_WIDTH;
        
        apos_col_start = feet_col_end + CHAR_SPACING;
        apos_col_end = apos_col_start + CHAR_WIDTH;
        
        inch_tens_col_start = apos_col_end + CHAR_SPACING;
        inch_tens_col_end = inch_tens_col_start + CHAR_WIDTH;
        
        inch_ones_col_start = inch_tens_col_end + CHAR_SPACING;
        inch_ones_col_end = inch_ones_col_start + CHAR_WIDTH;
        
        quote_col_start = inch_ones_col_end + CHAR_SPACING;
        quote_col_end = quote_col_start + CHAR_WIDTH;
        
        // Check if we're in the height display area
        in_height_area = (Row >= height_row_start && Row < height_row_end);
        in_feet_area = (Col >= feet_col_start && Col < feet_col_end);
        in_apos_area = (Col >= apos_col_start && Col < apos_col_end);
        in_inch_tens_area = (Col >= inch_tens_col_start && Col < inch_tens_col_end);
        in_inch_ones_area = (Col >= inch_ones_col_start && Col < inch_ones_col_end);
        in_quote_area = (Col >= quote_col_start && Col < quote_col_end);
    end
    
    // ROM coordinate calculation
    always_comb begin
        if (in_height_area) begin
            if (in_feet_area) begin
                rom_col_in = (Col - feet_col_start) >> 1;
                rom_row_in = (Row - height_row_start) >> 1;
            end else if (in_apos_area) begin
                rom_col_in = (Col - apos_col_start) >> 1;
                rom_row_in = (Row - height_row_start) >> 1;
            end else if (in_inch_tens_area) begin
                rom_col_in = (Col - inch_tens_col_start) >> 1;
                rom_row_in = (Row - height_row_start) >> 1;
            end else if (in_inch_ones_area) begin
                rom_col_in = (Col - inch_ones_col_start) >> 1;
                rom_row_in = (Row - height_row_start) >> 1;
            end else if (in_quote_area) begin
                rom_col_in = (Col - quote_col_start) >> 1;
                rom_row_in = (Row - height_row_start) >> 1;
            end else begin
                rom_col_in = 5'd0;
                rom_row_in = 5'd0;
            end
        end else begin
            rom_col_in = 5'd0;
            rom_row_in = 5'd0;
        end
    end
    
    // Output RGB based on what we're displaying (F'II" format)
    always_comb begin
        if (valid) begin
            // Default to white background
            rgb_out = 6'b111111;
            
            if (in_height_area) begin
                if (in_feet_area) begin
                    // Display feet digit
                    case (feet_digit)
                        4'd0: rgb_out = rom_0_rgb;
                        4'd1: rgb_out = rom_1_rgb;
                        4'd2: rgb_out = rom_2_rgb;
                        4'd3: rgb_out = rom_3_rgb;
                        4'd4: rgb_out = rom_4_rgb;
                        4'd5: rgb_out = rom_5_rgb;
                        4'd6: rgb_out = rom_6_rgb;
                        4'd7: rgb_out = rom_7_rgb;
                        4'd8: rgb_out = rom_8_rgb;
                        default: rgb_out = 6'b111111;
                    endcase
                end else if (in_apos_area) begin
                    // Display apostrophe
                    rgb_out = rom_apostrophe_rgb;
                end else if (in_inch_tens_area) begin
                    // Display inches tens digit
                    case (inches_tens_digit)
                        4'd0: rgb_out = rom_0_rgb;
                        4'd1: rgb_out = rom_1_rgb;
                        default: rgb_out = 6'b111111;
                    endcase
                end else if (in_inch_ones_area) begin
                    // Display inches ones digit
                    case (inches_ones_digit)
                        4'd0: rgb_out = rom_0_rgb;
                        4'd1: rgb_out = rom_1_rgb;
                        4'd2: rgb_out = rom_2_rgb;
                        4'd3: rgb_out = rom_3_rgb;
                        4'd4: rgb_out = rom_4_rgb;
                        4'd5: rgb_out = rom_5_rgb;
                        4'd6: rgb_out = rom_6_rgb;
                        4'd7: rgb_out = rom_7_rgb;
                        4'd8: rgb_out = rom_8_rgb;
                        4'd9: rgb_out = rom_9_rgb;
                        default: rgb_out = 6'b111111;
                    endcase
                end else if (in_quote_area) begin
                    // Display quote mark
                    rgb_out = rom_quote_rgb;
                end
            end
        end else begin
            // Outside valid area - black
            rgb_out = 6'b000000;
        end
    end

endmodule
