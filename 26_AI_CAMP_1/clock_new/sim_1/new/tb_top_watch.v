`timescale 1ns / 1ps

module tb_top_watch();


    reg clk, reset, btn_L, btn_R, btn_U, btn_D;
    reg [1:0] sw;
    wire led;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

 top_watch dut (
    .clk(clk),
    .reset(reset),
    .btn_L(btn_L),
    .btn_R(btn_R),
    .btn_U(btn_U),
    .btn_D(btn_D),
    .sw(sw),
    .led(led),
    .fnd_com(fnd_com),
    .fnd_data(fnd_data)
);

    parameter TEST_DELAY = 20000;

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        btn_L = 0;
        btn_R = 0;
        btn_U = 0;
        btn_D = 0;
        sw = 0;
        #10;
        reset = 0;
        btn_L = 1;
        #(TEST_DELAY);
        btn_L = 0;
        #(TEST_DELAY);
        btn_U = 1;
        #(TEST_DELAY);
        btn_U = 0;
        #500;
        $stop;
    end
endmodule
