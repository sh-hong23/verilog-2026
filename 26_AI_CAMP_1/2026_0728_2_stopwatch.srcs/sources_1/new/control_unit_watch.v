`timescale 1ns / 1ps

module control_unit_watch (
    input clk,
    input reset,
    input i_mode,
    output reg o_mode
    );

    always @(posedge clk, posedge reset) begin
        if(reset) 
            o_mode <= 1'b0;
        else 
            o_mode <= ~(o_mode); 
    end

endmodule
