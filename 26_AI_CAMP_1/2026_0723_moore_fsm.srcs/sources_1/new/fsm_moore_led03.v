`timescale 1ns / 1ps

module fsm_moore_led03 (
    input clk,
    input reset,
    input [2:0] sw,
    output reg [2:0] led
);

    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100;

    // state register
    reg [2:0] current_state;
    reg [2:0] next_state;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state <= S0;
        end else begin
            current_state <= next_state;
        end
    end


    // next_state combinational logic
    always @(*) begin
        case (current_state)
            S0: begin
                if (sw == 3'b001) begin
                    next_state = S1;
                end else begin
                    if (sw == 3'b100) next_state = S4;
                    else next_state = S0;
                end
            end
            S1: begin
                if (sw == 3'b010) begin
                    next_state = S2;
                end else begin
                    next_state = S1;
                end
            end
            S2: begin
                if (sw == 3'b011) begin
                    next_state = S3;
                end else begin
                    next_state = S2;
                end
            end
            S3: begin
                if (sw == 3'b100) begin
                    next_state = S4;
                end else begin
                    next_state = S3;
                end
            end
            S4: begin
                if (sw == 3'b111) begin
                    next_state = S0;
                end else begin
                    if (sw == 3'b001) next_state = S1;
                    else next_state = S4;
                end
            end

            default: next_state = current_state;

        endcase
    end

    always @(*) begin
        if (current_state == S0) led = 3'b000;
        else if (current_state == S1) led = 3'b001;
        else if (current_state == S2) led = 3'b010;
        else if (current_state == S3) led = 3'b011;
        else if (current_state == S4) led = 3'b100;

        else led = 0;  //3'b111, 3'b101, 3'b110


    end

endmodule
