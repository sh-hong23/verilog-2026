`timescale 1ns / 1ps

module tb_watch_1();

    reg clk, reset, sel;
    wire [6:0] msec; 
    wire [5:0] sec;
    wire [5:0] min;
    wire [4:0] hour;
    wire [4:0] display_out;
    wire pm;

    parameter TEST_DELAY = 1_000_000 * 10;

watch_datapath DUT (


    .clk(clk),
    .reset(reset),
    .sel(sel),
    .msec(msec),
    .sec(sec),
    .min(min),
    .hour(hour),
    .display_out(display_out),
    .pm(pm)
);


always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        sel = 0;
        #10;
        reset = 0;
        #10;
        sel = 1;
        #(TEST_DELAY);
        sel = 0;
        #(TEST_DELAY);
        sel = 1;

    end


endmodule
