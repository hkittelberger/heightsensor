// height_sorter.sv
// Module to sort 10 height readings (inches) from shortest to tallest

module height_sorter (
    input  logic [7:0] hist_0,  // Most recent (input)
    input  logic [7:0] hist_1,
    input  logic [7:0] hist_2,
    input  logic [7:0] hist_3,
    input  logic [7:0] hist_4,
    input  logic [7:0] hist_5,
    input  logic [7:0] hist_6,
    input  logic [7:0] hist_7,
    input  logic [7:0] hist_8,
    input  logic [7:0] hist_9,  // Oldest (input)
    // Sorted outputs (shortest to tallest)
    output logic [7:0] sorted_0, // Shortest
    output logic [7:0] sorted_1,
    output logic [7:0] sorted_2,
    output logic [7:0] sorted_3,
    output logic [7:0] sorted_4,
    output logic [7:0] sorted_5,
    output logic [7:0] sorted_6,
    output logic [7:0] sorted_7,
    output logic [7:0] sorted_8,
    output logic [7:0] sorted_9  // Tallest
);

    // Internal arrays for sorting network stages
    logic [7:0] stage0[0:9];
    logic [7:0] stage1[0:9];
    logic [7:0] stage2[0:9];
    logic [7:0] stage3[0:9];
    logic [7:0] stage4[0:9];
    logic [7:0] stage5[0:9];
    logic [7:0] stage6[0:9];
    logic [7:0] stage7[0:9];
    logic [7:0] stage8[0:9];
    logic [7:0] stage9[0:9];

    // Helper function to compare and swap two values
    function automatic void compare_swap(
        input logic [7:0] a, b,
        output logic [7:0] min_val, max_val
    );
        if (a <= b) begin
            min_val = a;
            max_val = b;
        end else begin
            min_val = b;
            max_val = a;
        end
    endfunction

    // Initialize stage0 with input values
    always_comb begin
        stage0[0] = hist_0;
        stage0[1] = hist_1;
        stage0[2] = hist_2;
        stage0[3] = hist_3;
        stage0[4] = hist_4;
        stage0[5] = hist_5;
        stage0[6] = hist_6;
        stage0[7] = hist_7;
        stage0[8] = hist_8;
        stage0[9] = hist_9;
    end

    // Sorting network implementation (Odd-Even Sort)
    // Stage 1: Compare pairs (0,1), (2,3), (4,5), (6,7), (8,9)
    always_comb begin
        compare_swap(stage0[0], stage0[1], stage1[0], stage1[1]);
        compare_swap(stage0[2], stage0[3], stage1[2], stage1[3]);
        compare_swap(stage0[4], stage0[5], stage1[4], stage1[5]);
        compare_swap(stage0[6], stage0[7], stage1[6], stage1[7]);
        compare_swap(stage0[8], stage0[9], stage1[8], stage1[9]);
    end

    // Stage 2: Compare pairs (1,2), (3,4), (5,6), (7,8)
    always_comb begin
        stage2[0] = stage1[0];
        compare_swap(stage1[1], stage1[2], stage2[1], stage2[2]);
        compare_swap(stage1[3], stage1[4], stage2[3], stage2[4]);
        compare_swap(stage1[5], stage1[6], stage2[5], stage2[6]);
        compare_swap(stage1[7], stage1[8], stage2[7], stage2[8]);
        stage2[9] = stage1[9];
    end

    // Stage 3: Compare pairs (0,1), (2,3), (4,5), (6,7), (8,9)
    always_comb begin
        compare_swap(stage2[0], stage2[1], stage3[0], stage3[1]);
        compare_swap(stage2[2], stage2[3], stage3[2], stage3[3]);
        compare_swap(stage2[4], stage2[5], stage3[4], stage3[5]);
        compare_swap(stage2[6], stage2[7], stage3[6], stage3[7]);
        compare_swap(stage2[8], stage2[9], stage3[8], stage3[9]);
    end

    // Stage 4: Compare pairs (1,2), (3,4), (5,6), (7,8)
    always_comb begin
        stage4[0] = stage3[0];
        compare_swap(stage3[1], stage3[2], stage4[1], stage4[2]);
        compare_swap(stage3[3], stage3[4], stage4[3], stage4[4]);
        compare_swap(stage3[5], stage3[6], stage4[5], stage4[6]);
        compare_swap(stage3[7], stage3[8], stage4[7], stage4[8]);
        stage4[9] = stage3[9];
    end

    // Stage 5: Compare pairs (0,1), (2,3), (4,5), (6,7), (8,9)
    always_comb begin
        compare_swap(stage4[0], stage4[1], stage5[0], stage5[1]);
        compare_swap(stage4[2], stage4[3], stage5[2], stage5[3]);
        compare_swap(stage4[4], stage4[5], stage5[4], stage5[5]);
        compare_swap(stage4[6], stage4[7], stage5[6], stage5[7]);
        compare_swap(stage4[8], stage4[9], stage5[8], stage5[9]);
    end

    // Stage 6: Compare pairs (1,2), (3,4), (5,6), (7,8)
    always_comb begin
        stage6[0] = stage5[0];
        compare_swap(stage5[1], stage5[2], stage6[1], stage6[2]);
        compare_swap(stage5[3], stage5[4], stage6[3], stage6[4]);
        compare_swap(stage5[5], stage5[6], stage6[5], stage6[6]);
        compare_swap(stage5[7], stage5[8], stage6[7], stage6[8]);
        stage6[9] = stage5[9];
    end

    // Stage 7: Compare pairs (0,1), (2,3), (4,5), (6,7), (8,9)
    always_comb begin
        compare_swap(stage6[0], stage6[1], stage7[0], stage7[1]);
        compare_swap(stage6[2], stage6[3], stage7[2], stage7[3]);
        compare_swap(stage6[4], stage6[5], stage7[4], stage7[5]);
        compare_swap(stage6[6], stage6[7], stage7[6], stage7[7]);
        compare_swap(stage6[8], stage6[9], stage7[8], stage7[9]);
    end

    // Stage 8: Compare pairs (1,2), (3,4), (5,6), (7,8)
    always_comb begin
        stage8[0] = stage7[0];
        compare_swap(stage7[1], stage7[2], stage8[1], stage8[2]);
        compare_swap(stage7[3], stage7[4], stage8[3], stage8[4]);
        compare_swap(stage7[5], stage7[6], stage8[5], stage8[6]);
        compare_swap(stage7[7], stage7[8], stage8[7], stage8[8]);
        stage8[9] = stage7[9];
    end

    // Stage 9: Compare pairs (0,1), (2,3), (4,5), (6,7), (8,9)
    always_comb begin
        compare_swap(stage8[0], stage8[1], stage9[0], stage9[1]);
        compare_swap(stage8[2], stage8[3], stage9[2], stage9[3]);
        compare_swap(stage8[4], stage8[5], stage9[4], stage9[5]);
        compare_swap(stage8[6], stage8[7], stage9[6], stage9[7]);
        compare_swap(stage8[8], stage8[9], stage9[8], stage9[9]);
    end

    // Final output assignment
    assign sorted_0 = stage9[0]; // Shortest
    assign sorted_1 = stage9[1];
    assign sorted_2 = stage9[2];
    assign sorted_3 = stage9[3];
    assign sorted_4 = stage9[4];
    assign sorted_5 = stage9[5];
    assign sorted_6 = stage9[6];
    assign sorted_7 = stage9[7];
    assign sorted_8 = stage9[8];
    assign sorted_9 = stage9[9]; // Tallest

endmodule
