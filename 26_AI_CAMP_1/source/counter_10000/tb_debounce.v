`timescale 1ns / 1ps

module tb_debounce();

    reg clk;
    reg reset;
    reg i_btn;
    wire o_btn;

btn_debounce dut ( 
    .clk(clk),
    .reset(reset),
    .i_btn(i_btn),
    .o_btn(o_btn)
    );

    parameter  TEST_DELAY = 1000;

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 0;
        i_btn = 0;

        #10;
        reset = 1;

        #10;
        reset = 0;
/////////////////////////////////////////// case 1
        i_btn = 1;
        #(TEST_DELAY);

        i_btn = 0;
        #(TEST_DELAY);

        i_btn = 1;
        #(TEST_DELAY);

//////////////////////////////////////////// case 2

        i_btn = 1;
        #(TEST_DELAY * 8);

////////////////////////////////////////////

        i_btn = 0;
        # (5000 * 3);
        $finish;

    end

endmodule
