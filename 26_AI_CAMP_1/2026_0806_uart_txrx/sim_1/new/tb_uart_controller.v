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

    parameter BAUD_TICK = (100_000_000 / 9600) * 10;

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        btn_R = 0;
        #10;
        reset = 0;
        #10;
        btn_R = 1;
        #10_000; // for BTN debounce

        #(BAUD_TICK * 12);

        #100;
        $stop;


 end
endmodule
