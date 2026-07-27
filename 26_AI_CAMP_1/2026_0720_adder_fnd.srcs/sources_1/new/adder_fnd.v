`timescale 1ns / 1ps

// top module

    module adder_fnd(
    input clk,  // from external
    input reset,
    input  [7:0] a,
    input  [7:0] b,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output cout
);

    wire [7:0] s;

    fnd_controller U_FND_CNTL (
        .clk(clk),
        .reset(reset),
        .fnd_in(s),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    full_adder_8bit U_ADDER(
        .a(a),
        .b(b),
        .s(s),
        .cout(cout)
    );


endmodule

module full_adder_8bit(
    input [7:0] a,
    input [7:0] b,
    output [7:0] s,
    output cout
);
    wire c1;

    full_adder_4bit FA1(
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(1'b0),
        .cout(c1),
        .s(s[3:0])
    );

    full_adder_4bit FA2(
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(c1),
        .cout(cout),
        .s(s[7:4])
    );


endmodule


module full_adder_4bit(
    input [3:0] a,
    input [3:0] b,
    input cin,
    output[3:0] s,
    output cout
);
    wire c1, c2, c3;

    full_adder FA1(
        .a(a[0]),
        .b(b[0]),
        .cin(cin),
        .cout(c1),
        .s(s[0])
    );

    full_adder FA2(
        .a(a[1]),
        .b(b[1]),
        .cin(c1),
        .cout(c2),
        .s(s[1])
    );

    full_adder FA3(
        .a(a[2]),
        .b(b[2]),
        .cin(c2),
        .cout(c3),
        .s(s[2])
    );

    full_adder FA4(
        .a(a[3]),
        .b(b[3]),
        .cin(c3),
        .cout(cout),
        .s(s[3])
    );

endmodule

module full_adder(
    input a,
    input b,
    input cin,
    output s,
    output cout
);

    wire s1, c1, c2;
    assign cout = c1 | c2;


    half_adder HA1(
        .a(a),
        .b(b),
        .s(s1),
        .cout(c1)
);

    half_adder HA2(
        .a(s1),
        .b(cin),
        .s(s),
        .cout(c2)
);

endmodule

module half_adder(
    input a,
    input b,
    output s,
    output cout
);

    //assign cout = a & b;
    //assign    s = a ^ b;

    xor(s,a,b); // (output, input, input, input...)
    and(cout,a,b); // and gate (output, input 0, input 1, ...)

endmodule
