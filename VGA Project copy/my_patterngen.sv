module my_patterngen(
    input logic [9:0] Row,
    input logic [9:0] Col,
    input logic valid,
    output logic [5:0] rgb_out
);

logic [9:0] rom_col, rom_row;
logic [4:0] rom_col_in, rom_row_in;
logic [5:0] rom_0_rgb;

logic [5:0] rom_8_rgb;

rom_0 rom_0 (.col(rom_col_in), .row(rom_row_in), .data(rom_0_rgb));
rom_8 rom_8 (.col(rom_col_in), .row(rom_row_in), .data(rom_8_rgb));

logic rom_0_starter_draw;
assign rom_0_starter_draw = (Col > 50 && Col < 67) && (Row > 300 && Row < 333);

logic rom_8_starter_draw;
assign rom_8_starter_draw = (Col > 70 && Col < 87) && (Row > 300 && Row < 333);

// you will have 4 heights recording the 4 most recent heights: height_1, height_2, height_3, height_4 each is on a certain row 32 pixels tall (Row)
// you will have to define all of the Col spaces for each digit ROM in each height Row space (where is the digit horizontally?)
// you need to take the input data from your sensor and make logic statements that consider which height you are editing, which height to replace
// You will need a vector which has the 4 most recent height readings and orders them from largest to smallest
// height_vector = {height1, height2, height3, height4}
// Another vector recording the most recent height inputs that behaves like a shift register recent_height{newest input data --> least recenrt data}

always_comb begin
    rom_col_in = 5'd0;
    rom_row_in = 5'd0;
    rgb_out    = 6'b111111;
    if (valid) begin
        if (rom_0_starter_draw == 1'b1) begin 
            rom_col_in = (Col - 51) >> 1;
            rom_row_in = (Row - 301) >> 1;
            rgb_out = rom_0_rgb;
        end else if (rom_8_starter_draw == 1'b1) begin 
            rom_col_in = (Col - 71) >> 1;
            rom_row_in = (Row - 301) >> 1;
            rgb_out = rom_8_rgb;
        end
    end else begin 
        rgb_out = 6'b000000;
    end
end 


endmodule