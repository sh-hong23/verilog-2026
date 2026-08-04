`timescale 1ns / 1ps

module tb_stopwatch();

    reg clk, reset, btn_L, btn_R, btn_U, btn_D;
    reg  [3:0] sw;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire [1:0] led;


    top_stopwatch dut (
        .clk(clk),
        .reset(reset),
        .btn_L(btn_L),
        .btn_R(btn_R),
        .btn_U(btn_U),
        .btn_D(btn_D),
        .sw(sw),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .led(led)
    );


    parameter TEST_DELAY = 10000;

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
        btn_L = 1;
        #(TEST_DELAY);
        btn_L = 0;
        #(TEST_DELAY);
        btn_R = 1;
        #(TEST_DELAY);
        btn_R = 0;
        $stop;
        end


endmodule
