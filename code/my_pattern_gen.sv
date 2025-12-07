module my_pattern_gen(
    input logic genclock,
    input logic [9:0] genrow,
    input logic [9:0] gencol,
    input logic genvalid,
    output logic [1:0] genred, 
    output logic [1:0] gengreen,
    output logic [1:0] genblue
    );

always_ff @ (posedge genclock) begin
    if(genvalid == 1)begin
        
        if (gencol < 320 && genrow < 240) begin             // RED top left
            genred = 2'b11;
            gengreen = 2'b00;
            genblue = 2'b00;
        end else if (gencol >= 320 && genrow < 240) begin   // Blue top right
            genred = 2'b00;
            gengreen = 2'b00;
            genblue = 2'b11;
        end else if (gencol < 320 && genrow >= 240) begin   // Green bottom left
            genred = 2'b00;
            gengreen = 2'b11;
            genblue = 2'b00;
        end else if (gencol >= 320 && genrow >= 240) begin   // Black bottom right
            genred = 2'b00;
            gengreen = 2'b00;
            genblue = 2'b00;
        end
        
    end else begin
        // When not in valid area, output black
        genred = 2'b00;
        gengreen = 2'b00;
        genblue = 2'b00;
    end
    
end

endmodule
