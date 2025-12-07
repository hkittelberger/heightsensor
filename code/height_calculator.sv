module height_calculator (
    input  logic [7:0] distance_inches,  // Raw distance from sensor
    output logic [7:0] height_inches     // Calculated height (ground_distance - distance)
);

    // ================================================================
    // CONFIGURABLE GROUND DISTANCE
    // Change this value based on sensor mounting height
    // ================================================================
    localparam logic [7:0] GROUND_DISTANCE_INCHES = 8'd72;  // 72 inches = 6 feet
    
    // Alternative mounting heights (uncomment the one you want):
    // localparam logic [7:0] GROUND_DISTANCE_INCHES = 8'd48;  // 48 inches = 4 feet
    // localparam logic [7:0] GROUND_DISTANCE_INCHES = 8'd60;  // 60 inches = 5 feet
    // localparam logic [7:0] GROUND_DISTANCE_INCHES = 8'd84;  // 84 inches = 7 feet
    // localparam logic [7:0] GROUND_DISTANCE_INCHES = 8'd96;  // 96 inches = 8 feet

    always_comb begin
        if (distance_inches <= GROUND_DISTANCE_INCHES) begin
            // Normal case: calculate height = ground_distance - sensor_distance
            height_inches = GROUND_DISTANCE_INCHES - distance_inches;
        end else begin
            // Error case: sensor reading is greater than ground distance
            // This could happen if sensor is malfunctioning or measuring something below ground
            height_inches = 8'd0;  // Show 0 height for invalid readings
        end
    end

endmodule
