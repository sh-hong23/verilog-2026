`timescale 1ns / 1ps

module tb_baud_tick();

    reg clk, reset;
    wire o_baud_tick;

baud_tick U_BAUD_TICK (
    .clk(clk),
    .reset(reset),
    .o_baud_tick(o_baud_tick)
);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        
        #10;
        reset = 0;

        #(1_000_000 * 2);
        $stop;
    end

endmodule
