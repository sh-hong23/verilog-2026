`timescale 1ns / 1ps
// logic을 사용하여 wire, reg로 호환되어 사용가능하다.
module adder (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic       mode,
    output logic [7:0] s,
    output logic       c
);

    assign {c, s} = (mode) ? a - b : a + b;
endmodule
