`timescale 1ns / 1ps

module tb_full_adder();

reg  [7:0] a, b;    
reg        cin;

wire [7:0] s;
wire       c;

integer i, j, k;    

full_adder_8bit dut (
    .a   (a),
    .b   (b),
    .cin (cin),
    .s   (s),
    .c   (c)
);

initial begin
    cin = 1'b0;
    a   = 8'b0000_0000;
    b   = 8'b0000_0000;

    #10;

    for (k = 0; k < 2; k = k + 1) begin
        cin = k;

        for (i = 0; i < 256; i = i + 1) begin
            for (j = 0; j < 256; j = j + 1) begin
                a = i;
                b = j;

                #10;
            end
        end
    end

    $finish;
end

endmodule