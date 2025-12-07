module my_vga(
    input logic vga_clock,
    output logic [9:0] vga_col,
    output logic [9:0] vga_row,
    output logic vga_valid,
    output logic h_sync,
    output logic v_sync
    );

localparam int H_VISIBLE_AREA = 640;
localparam int H_FRONT_PORCH = 16;
localparam int H_BACK_PORCH = 48;
localparam int H_SYNC_PULSE = 96;
localparam int H_TOTAL = 800;

localparam int V_VISIBLE_AREA = 480;
localparam int V_FRONT_PORCH = 10;
localparam int V_BACK_PORCH = 33;
localparam int V_SYNC_PULSE = 2;
localparam int V_TOTAL = 525;

int column_count = 0;
int row_count = 0;

 assign vga_col = column_count;
 assign vga_row = row_count;

always_ff @( posedge vga_clock ) begin
        
    if (column_count == H_TOTAL - 1) begin
        column_count <= 0;
        row_count <= row_count + 1;
    end else begin
        column_count <= column_count + 1;
    end  
        if (row_count == V_TOTAL -1) begin
            row_count <= 0;
    end
end

always_comb begin 
    
    if (H_VISIBLE_AREA + H_FRONT_PORCH <= column_count && column_count < H_TOTAL - H_BACK_PORCH) begin
        h_sync = 0;
    end else begin
        h_sync = 1;
    end
    
    if (V_VISIBLE_AREA + V_FRONT_PORCH <= row_count && row_count < V_TOTAL - V_BACK_PORCH ) begin
        v_sync = 0;
    end else begin
        v_sync = 1;
    end

    if (column_count < H_VISIBLE_AREA && row_count < V_VISIBLE_AREA) begin
        vga_valid = 1;
    end else begin
        vga_valid = 0;
    end
    
end

endmodule