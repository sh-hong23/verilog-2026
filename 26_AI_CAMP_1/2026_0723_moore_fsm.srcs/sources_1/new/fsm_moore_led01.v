`timescale 1ns / 1ps

module fsm_moore_led01 (
    input  clk,
    input  reset,
    input  sw,
    output reg led
);
    parameter S0 = 1'b0, S1 = 1'b1;

    // stage register
    reg current_state, next_state;

    // stage register
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
                if (sw) begin
                    next_state = S1;
                end else begin
                    next_state = S0;
                end
            end
            S1: begin
                if (!sw) begin
                    next_state = S0;
                end else begin
                    next_state = S1;
                end
            end
        default : next_state = current_state;
        endcase
    end

    // output combinational logic
    //assign led = (current_state == S1) ? 1'b1 : 1'b0;
    always @(*) begin
        if(current_state == S0) begin
         led = 1'b0; // S0
        end else begin
         led = 1'b1; // S1
        end
    end

endmodule
