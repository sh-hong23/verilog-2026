`timescale 1ns / 1ps

module register_8 (
    input clk,
    input reset,
    input we,  // write enable
    input [7:0] d,
    output reg [7:0] q
);

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else begin
            if (we) q <= d;
        end
    end
endmodule
