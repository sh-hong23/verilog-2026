`timescale 1ns / 1ps

module tb_fsm_moore_led03();

    reg clk;
    reg reset;
    reg [2:0] sw;
    wire [2:0] led;

   fsm_moore_led03 dut (
    .clk(clk),
    .reset(reset),
    .sw(sw),
    .led(led)
);

    always #10 clk = ~clk;

    initial begin
    clk = 0;
    reset = 1;

    #20;
    reset = 0;
    // 0
    sw = 3'b000;
    
    #20;
    // 1
    sw = 3'b001;

    #20;
    // 2
    sw = 3'b010;

    #20;
    // 3
    sw = 3'b011;

    #20;
    // 4
    sw = 3'b100;

    #20;
    // 0
    sw = 3'b111;

    #20;
    // 4
    sw = 3'b100;

    #20;
    // 1
    sw = 3'b001;

    #20;
    // 2
    sw = 3'b010;

    #20;
    // 3
    sw = 3'b011;

    #20
    // 4
    sw = 3'b100;
    $stop;

    end
endmodule
