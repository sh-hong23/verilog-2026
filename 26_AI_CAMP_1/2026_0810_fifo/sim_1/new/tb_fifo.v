`timescale 1ns / 1ps

module tb_fifo();
    reg clk, reset;
    reg push, pop;
    reg [7:0] wdata;
    wire [7:0] rdata;
    wire full, empty;

fifo dut (
    .clk(clk),
    .reset(reset),
    .push(push),
    .pop(pop),
    .wdata(wdata),
    .rdata(rdata),
    .full(full),
    .empty(empty)
);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        push = 0;
        pop = 0;
        wdata = 8'h00;
        #10; //push 1
        reset = 0;
        push = 1;
        pop = 0;
        wdata = 8'h01;
        #10;
        push = 0;
        #10; //push 2
        push = 1;
        pop = 0;
        wdata = 8'h02;
        #10;
        push = 0;
        #10; //push 3
        push = 1;
        pop = 0;
        wdata = 8'h03;
        #10;
        push = 0;
        #10; // push 4
        push = 1;
        pop = 0;
        wdata = 8'h04;
        #10;
        push = 0;
        #10; // push 5
        push = 1;
        pop = 0;
        wdata = 8'h05;
        #10;
        push = 0;
        #10; // pop 1
        push = 0;
        pop = 1;
        wdata = 8'h06;
        #10;
        pop = 0;
        #10; // pop 2
        push = 0;
        pop = 1;
        wdata = 8'h07;
        #10;
        pop = 0;
        #10; // pop 3
        push = 0;
        pop = 1;
        wdata = 8'h08;
        #10;
        pop = 0;
        #10; // pop 4
        push = 0;
        pop = 1;
        wdata = 8'h09;
        #10;
        pop = 0;
        #10; // pop 5
        push = 0;
        pop = 1;
        wdata = 8'h0a;
        #10; // push 1 times
        pop = 0;
        #10;
        push = 1;
        pop = 0;
        wdata = 8'h0b;
        #10;
        push = 0;
        #10; //push,pop 1
        push = 1;
        pop = 1;
        wdata = 8'h0c;
        #10;
        push = 0;
        pop = 0;
        #10; // push,pop 2
        push = 1;
        pop = 1;
        wdata = 8'h0d;
        #10; 
        push = 0;
        pop = 0;
        #10; // push, pop 3
        push = 1;
        pop = 1;
        wdata = 8'h0e;
        #10;
        push = 0;
        pop = 0;
        #10; // push, pop 4
        push = 1;
        pop = 1;
        wdata = 8'h0f;
        #10;
        push = 0;
        pop = 0;
        #10; // push, pop 5
        push = 1;
        pop = 1;
        wdata = 8'h01;
        #10;
        push = 0;
        pop = 0;
        #10; // push, pop 6
        push = 1;
        pop = 1;
        wdata = 8'h02;
        #10;
        push = 0;
        pop = 0;
        #10; // push, pop 7
        push = 1;
        pop = 1;
        wdata = 8'h03;
        #10;
        push = 0;
        pop = 0;
        #10; // push, pop 8
        push = 1;
        pop = 1;
        wdata = 8'h04;
        #10;
        push = 0;
        pop = 0;
        #10;
        pop = 1;
        #10;
        pop = 0;
        $stop;


    end

endmodule
