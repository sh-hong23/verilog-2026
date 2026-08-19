`timescale 1ns / 1ps

module register_sv (
    input logic clk,
    input logic reset,
    input logic enable,
    input logic [31:0] d,
    output logic [31:0] q


);

    //logic [31:0] register_file;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else begin
            if (enable) q <= d;
        end

    end
endmodule
