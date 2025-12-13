// sensor.sv
// Module for ultrasonic sensor interface

module sensor(
    input logic clk,
    input logic echo,
    output logic trig,
    output logic led,
    output logic [31:0] echo_cycles
);

    localparam int TRIG_PULSE = 120;
    localparam int MEASURE_CYCLE = 750000;

    logic [31:0] counter = 32'd0;
    logic [31:0] echo_width = 32'd0;

    logic measuring = 1'b0;
    logic sent_pulse = 1'b0;

    always_ff @(posedge clk) begin
        
        counter <= counter + 1;

        // send trigger pulse
        if (!sent_pulse && counter < TRIG_PULSE) begin
            trig <= 1'b1;
        end else begin
            trig <= 1'b0;
            sent_pulse <= 1'b1;
        end

        // after trigger, measure echo
        if (sent_pulse) begin

            // start counting when echo high
            if (echo) begin
                measuring <= 1'b1;
                echo_width <= echo_width + 1;
            // echo finished, measuring complete
            end else if (measuring) begin
                measuring <= 0;
            end
        end

        if (counter >= MEASURE_CYCLE) begin
            counter <= 0;
            sent_pulse <= 0;

            echo_cycles <= echo_width;
            
            echo_width <= 0;
        end

    end

endmodule
