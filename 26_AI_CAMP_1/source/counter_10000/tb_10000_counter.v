`timescale 1ns / 1ps

module tb_10000_counter();

    reg clk;
    reg reset;
    reg btn_L, btn_R, btn_U;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    parameter TEST_DELAY = 25_000_000;

    top_counter_10000 dut (
        .clk(clk),
        .reset(reset),
        .btn_L(btn_L),
        .btn_R(btn_R),
        .btn_U(btn_U),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

// tick_gen dut (
//     .clk(clk),
//     .reset(reset),
//     .tick(tick)
// );

//data_path_10000 dut (
//
//    .clk(clk),
//    .reset(reset),
//    .counter(counter)
//);
    // clock generation 100MHz
    always #5  clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        {btn_R, btn_L, btn_U} = 3'b000;
        #10;
        reset = 0;
        #10;

        // 1
        {btn_R, btn_L, btn_U} = 3'b000;
        #(TEST_DELAY);
        
        // 2
        {btn_R, btn_L, btn_U} = 3'b010;
        #10;
        {btn_R, btn_L, btn_U} = 3'b000;
        #(TEST_DELAY);

        #1000;
        $stop;
    
    end

endmodule