// height_calculator.sv
// Module to calculate height from distance using a configurable ground
// distance reference.

module height_calculator (
    input  logic [7:0] distance_inches,  // Raw distance from sensor
    output logic [7:0] height_inches     // Calculated height (ground - sens dist)
);

    // ================================================================
    // CONFIGURABLE GROUND DISTANCE
    // Change this value based on sensor mounting height
    // ================================================================
    localparam logic [7:0] GROUND_DISTANCE_INCHES = 8'd92;  // 92 inches = 7 feet 8 inches

    always_comb begin
        if (distance_inches <= GROUND_DISTANCE_INCHES) begin
            // Normal case: calculate height = ground - sensor dist
            height_inches = GROUND_DISTANCE_INCHES - distance_inches;
        end else begin
            // Error case: sensor reading is greater than ground distance
            // This could happen if sensor is malfunctioning or measuring something below ground
            height_inches = 8'd0;  // Show 0 height for invalid readings
        end
    end

endmodule
