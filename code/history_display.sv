// history_display.sv
// Module to display height history on a 2-digit 7-segment display.
// Pressing a button cycles through the last 10 saved heights.
// TESTING MODULE ONLY.

module history_display (
    input  logic       clk,
    input  logic       btn,           // Button input to toggle thru history
    input  logic [7:0] hist_0,
    input  logic [7:0] hist_1,
    input  logic [7:0] hist_2,
    input  logic [7:0] hist_3,
    input  logic [7:0] hist_4,
    input  logic [7:0] hist_5,
    input  logic [7:0] hist_6,
    input  logic [7:0] hist_7,
    input  logic [7:0] hist_8,
    input  logic [7:0] hist_9,
    output logic [6:0] seg,
    output logic       dig0,
    output logic       dig1
);

    // Button debouncing
    logic [19:0] debounce_counter = 20'd0;
    logic btn_stable = 1'b1;
    logic btn_prev = 1'b1;
    logic btn_edge;
    
    // Debounce button (assuming ~12MHz clock)
    always_ff @(posedge clk) begin
        if (btn != btn_stable) begin
            debounce_counter <= debounce_counter + 1;
            if (debounce_counter == 20'hFFFFF) begin  // ~87ms debounce
                btn_stable <= btn;
                debounce_counter <= 20'd0;
            end
        end else begin
            debounce_counter <= 20'd0;
        end
        
        btn_prev <= btn_stable;
    end
    
    // Detect button press (falling edge since button is active low)
    assign btn_edge = btn_prev & ~btn_stable;
    
    // Index counter (0-9, wraps around)
    logic [3:0] history_index = 4'd0;
    
    always_ff @(posedge clk) begin
        if (btn_edge) begin
            if (history_index == 4'd9) begin
                history_index <= 4'd0;
            end else begin
                history_index <= history_index + 1;
            end
        end
    end
    
    // Multiplex the history values based on index
    logic [7:0] selected_history;
    
    always_comb begin
        case (history_index)
            4'd0: selected_history = hist_0;
            4'd1: selected_history = hist_1;
            4'd2: selected_history = hist_2;
            4'd3: selected_history = hist_3;
            4'd4: selected_history = hist_4;
            4'd5: selected_history = hist_5;
            4'd6: selected_history = hist_6;
            4'd7: selected_history = hist_7;
            4'd8: selected_history = hist_8;
            4'd9: selected_history = hist_9;
            default: selected_history = hist_0;
        endcase
    end
    
    // Instantiate display module for the selected history value
    display_inches history_display_inst (
        .clk           (clk),
        .inches_display(selected_history),
        .seg           (seg),
        .dig0          (dig0),
        .dig1          (dig1)
    );

endmodule
