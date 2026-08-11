`timescale 1ns / 1ps

module tb_fifo ();

    reg clk, reset;
    reg push, pop;
    reg  [7:0] wdata;
    wire [7:0] rdata;
    wire full, empty;

    parameter WIDTH = 2;
    integer i = 0;
    //for random simulation
    reg [7:0] compare_buffer[0:(2**WIDTH)-1];
    reg [WIDTH-1:0] push_cnt;
    reg [WIDTH-1:0] pop_cnt;
    integer pass_count = 0, fail_count = 0;

    fifo #(
        .WIDTH(WIDTH)
    ) dut (
        .clk  (clk),
        .reset(reset),
        .push (push),
        .pop  (pop),
        .wdata(wdata),
        .rdata(rdata),
        .full (full),
        .empty(empty)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        push  = 0;
        pop   = 0;
        #10;
        reset = 0;

        // push only push = 1, pop = 0;
        @(negedge clk);
        push  = 1;
        wdata = 8'h0a;
        #10;
        wdata = 8'h0b;
        #10;
        wdata = 8'h0c;
        #10;
        wdata = 8'h0d;
        #10;
        wdata = 8'h0e;
        #10;
        push = 0;
        // pop only pop = 1, push = 0;
        @(negedge clk);
        pop = 1;
        #10;
        #10;
        #10;
        #10;
        #10;
        pop = 0;

        #10;
        // push 1, pop = 1;
        push  = 1;
        wdata = 8'h0f;
        #10;
        for (i = 0; i < 8; i = i + 1) begin
            push  = 1;
            pop   = 1;
            wdata = i;
            #10;

        end
        push = 0;
        pop  = 1;
        #10;
        pop = 0;
        #10;
        //random signal

        $display("%t : RADDOM test start", $time);
        push_cnt = 0;
        pop_cnt  = 0;
       

        // empty state
        for (i = 0; i < 256; i = i + 1) begin
            //  @ (posedge clk);
            // #1;
            push  = $random % 2;
            pop   = $random % 2;
            wdata = $random % 256;
            $display("%t : push = %d, pop = %d, wdata = %d", $time, push, pop,
                    wdata);
            @(negedge clk);
            if (!full & push) begin
                compare_buffer[push_cnt] = wdata;
                push_cnt = push_cnt + 1;
                $strobe("%t : compare_buffer = %d, push = %d", $time,
                        compare_buffer[push_cnt], push);
                pass_count = pass_count + 1;

            end
            if (!empty & pop) begin
                if (compare_buffer[pop_cnt] == rdata) begin
                    $display(
                        "%t : PASS!! compare_data = %d, rdata = %d, pop = %d, empty = %d",
                        $time, compare_buffer[pop_cnt], rdata, pop, empty);
                end else begin
                    $display(
                        "%t : FAIL!! compare_data = %d, rdata = %d, pop = %d, empty = %d",
                        $time, compare_buffer[pop_cnt], rdata, pop, empty);
                    fail_count = fail_count + 1;
                end

                pop_cnt = pop_cnt + 1;
            end

            // #10; 

        end

        $display("%t : pass_count = %d, fail_count = %d", $time, pass_count,
                 fail_count);

        #100;
        $stop;
    end
endmodule
///////////////////////////////////////////////////
// module tb_fifo();
//     reg clk, reset;
//     reg push, pop;
//     reg [7:0] wdata;
//     wire [7:0] rdata;
//     wire full, empty;

// fifo dut (
//     .clk(clk),
//     .reset(reset),
//     .push(push),
//     .pop(pop),
//     .wdata(wdata),
//     .rdata(rdata),
//     .full(full),
//     .empty(empty)
// );

// parameter TEST_DELAY = 100;

// always #5 clk = ~clk;

// task FIFO(input fifo_push);
// begin
//     @(negedge clk);

//         push = 1;
//         pop = 0;
//         wdata = fifo_push;
//         #10;
//         push = 0;
//         #10;

// end
// endtask


//     initial begin
//         clk = 0;
//         reset = 1;
//         push = 0;
//         pop = 0;
//         wdata= 0;
//         #10;
//         reset = 0;
//         #10;
//         //simulaiton for FIFO
//         SENDER_FOR_FIFO();
//         SENDER_FOR_FIFO();
//         SENDER_FOR_FIFO();
//         SENDER_FOR_FIFO();
//         SENDER_FOR_FIFO();


//         #100;
//         $stop;
//////////////////////////////////////////////////////////////

// always #5 clk = ~clk;

// initial begin
//     clk = 0;
//     reset = 1;
//     push = 0;
//     pop = 0;
//     wdata = 8'h00;
//     #10; //push 1
//     reset = 0;
//     push = 1;
//     pop = 0;
//     wdata = 8'h01;
//     #10;
//     push = 0;
//     #10; //push 2
//     push = 1;
//     pop = 0;
//     wdata = 8'h02;
//     #10;
//     push = 0;
//     #10; //push 3
//     push = 1;
//     pop = 0;
//     wdata = 8'h03;
//     #10;
//     push = 0;
//     #10; // push 4
//     push = 1;
//     pop = 0;
//     wdata = 8'h04;
//     #10;
//     push = 0;
//     #10; // push 5
//     push = 1;
//     pop = 0;
//     wdata = 8'h05;
//     #10;
//     push = 0;
//     #10; // pop 1
//     push = 0;
//     pop = 1;
//     wdata = 8'h06;
//     #10;
//     pop = 0;
//     #10; // pop 2
//     push = 0;
//     pop = 1;
//     wdata = 8'h07;
//     #10;
//     pop = 0;
//     #10; // pop 3
//     push = 0;
//     pop = 1;
//     wdata = 8'h08;
//     #10;
//     pop = 0;
//     #10; // pop 4
//     push = 0;
//     pop = 1;
//     wdata = 8'h09;
//     #10;
//     pop = 0;
//     #10; // pop 5
//     push = 0;
//     pop = 1;
//     wdata = 8'h0a;
//     #10; // push 1 times
//     pop = 0;
//     #10;
//     push = 1;
//     pop = 0;
//     wdata = 8'h0b;
//     #10;
//     push = 0;
//     #10; //push,pop 1
//     push = 1;
//     pop = 1;
//     wdata = 8'h0c;
//     #10;
//     push = 0;
//     pop = 0;
//     #10; // push,pop 2
//     push = 1;
//     pop = 1;
//     wdata = 8'h0d;
//     #10; 
//     push = 0;
//     pop = 0;
//     #10; // push, pop 3
//     push = 1;
//     pop = 1;
//     wdata = 8'h0e;
//     #10;
//     push = 0;
//     pop = 0;
//     #10; // push, pop 4
//     push = 1;
//     pop = 1;
//     wdata = 8'h0f;
//     #10;
//     push = 0;
//     pop = 0;
//     #10; // push, pop 5
//     push = 1;
//     pop = 1;
//     wdata = 8'h01;
//     #10;
//     push = 0;
//     pop = 0;
//     #10; // push, pop 6
//     push = 1;
//     pop = 1;
//     wdata = 8'h02;
//     #10;
//     push = 0;
//     pop = 0;
//     #10; // push, pop 7
//     push = 1;
//     pop = 1;
//     wdata = 8'h03;
//     #10;
//     push = 0;
//     pop = 0;
//     #10; // push, pop 8
//     push = 1;
//     pop = 1;
//     wdata = 8'h04;
//     #10;
//     push = 0;
//     pop = 0;
//     #10;
//     pop = 1;
//     #10;
//     pop = 0;
//     $stop;


// end

//endmodule
