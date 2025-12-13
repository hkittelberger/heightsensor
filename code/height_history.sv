// height_history.sv
// Module to store the last 10 height measurements in a FIFO manner.

module height_history (
    input  logic       clk,
    input  logic       reset,
    input  logic       save_height,     // pulse to save a new height
    input  logic [7:0] new_height,      // the height value to save
    // Individual outputs for each history entry (most recent to oldest)
    output logic [7:0] history_0,       // most recent
    output logic [7:0] history_1,
    output logic [7:0] history_2,
    output logic [7:0] history_3,
    output logic [7:0] history_4,
    output logic [7:0] history_5,
    output logic [7:0] history_6,
    output logic [7:0] history_7,
    output logic [7:0] history_8,
    output logic [7:0] history_9        // oldest
);

    // Internal storage for the 10 heights as individual registers
    logic [7:0] height_reg_0, height_reg_1, height_reg_2, height_reg_3, height_reg_4;
    logic [7:0] height_reg_5, height_reg_6, height_reg_7, height_reg_8, height_reg_9;
    
    // Initialize all heights to zero
    initial begin
        height_reg_0 = 8'd0;
        height_reg_1 = 8'd0;
        height_reg_2 = 8'd0;
        height_reg_3 = 8'd0;
        height_reg_4 = 8'd0;
        height_reg_5 = 8'd0;
        height_reg_6 = 8'd0;
        height_reg_7 = 8'd0;
        height_reg_8 = 8'd0;
        height_reg_9 = 8'd0;
    end
    
    // Edge detection for save_height signal
    logic save_height_prev;
    logic save_height_edge;
    
    always_ff @(posedge clk) begin
        save_height_prev <= save_height;
    end
    
    assign save_height_edge = save_height & ~save_height_prev;
    
    // FIFO logic: shift all values down and insert new one at position 0
    always_ff @(posedge clk) begin
        if (reset) begin
            height_reg_0 <= 8'd0;
            height_reg_1 <= 8'd0;
            height_reg_2 <= 8'd0;
            height_reg_3 <= 8'd0;
            height_reg_4 <= 8'd0;
            height_reg_5 <= 8'd0;
            height_reg_6 <= 8'd0;
            height_reg_7 <= 8'd0;
            height_reg_8 <= 8'd0;
            height_reg_9 <= 8'd0;
        end else if (save_height_edge) begin
            // Shift all existing heights down by one position
            height_reg_9 <= height_reg_8;
            height_reg_8 <= height_reg_7;
            height_reg_7 <= height_reg_6;
            height_reg_6 <= height_reg_5;
            height_reg_5 <= height_reg_4;
            height_reg_4 <= height_reg_3;
            height_reg_3 <= height_reg_2;
            height_reg_2 <= height_reg_1;
            height_reg_1 <= height_reg_0;
            // Insert new height at the front
            height_reg_0 <= new_height;
        end
    end
    
    // Output assignment
    assign history_0 = height_reg_0;
    assign history_1 = height_reg_1;
    assign history_2 = height_reg_2;
    assign history_3 = height_reg_3;
    assign history_4 = height_reg_4;
    assign history_5 = height_reg_5;
    assign history_6 = height_reg_6;
    assign history_7 = height_reg_7;
    assign history_8 = height_reg_8;
    assign history_9 = height_reg_9;

endmodule
