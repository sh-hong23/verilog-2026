`timescale 1ns / 1ps

module tb_sr04_controller ();

    reg clk, reset, start, echo;
    wire trigger, done;
    wire [8:0] distance;

    SR04_controller dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .echo(echo),
        .trigger(trigger),
        .done(done),
        .distance(distance)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        start = 0;
        echo  = 0;
        #10;
        reset = 0;
        @(negedge clk);
        start = 1;
        #10;
        start = 0;

        #(12_000);

    end
endmodule
