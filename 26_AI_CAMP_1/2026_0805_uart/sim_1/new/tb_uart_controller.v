`timescale 1ns / 1ps

module tb_uart_controller();

reg clk, reset, btn_R;
wire tx;

uart_controller dut (
     .clk(clk),
     .reset(reset),
     .btn_R(btn_R),
     .tx(tx)
);

    parameter TEST_DELAY = 1_000_000;

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        btn_R = 0;
        #10;
        reset = 0;
        btn_R = 1;
        #(TEST_DELAY);
        btn_R = 0;
        #(TEST_DELAY);
        btn_R = 1;
        #(TEST_DELAY);
        btn_R = 0;
        #(TEST_DELAY);
        $finish;


 end
endmodule
