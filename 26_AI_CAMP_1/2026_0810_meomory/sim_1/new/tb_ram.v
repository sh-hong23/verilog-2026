`timescale 1ns / 1ps

module tb_ram ();

    reg clk;
    reg [5:0] addr;
    reg [7:0] wdata;
    reg wr;
    wire [7:0] rdata;

    ram_ip dut (
        .clk(clk),
        .addr(addr),
        .wdata(wdata),
        .wr(wr),
        .rdata(rdata)
    );


    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        addr  = 0;
        wdata = 0;
        wr    = 0;
        #10;
        addr = 10;
        wdata = 8'h0a;
        wr = 1;
        #10;
        addr = 11;
        wdata = 8'h0b;
        wr = 0;
        #10;
        addr = 31;
        wdata = 8'h0c;
        wr = 1;
        #10;
        addr = 32;
        wdata = 8'h0d;
        wr = 1;
        #10;
        addr = 10;
        wr   = 0;
        #10;
        addr = 11;
        wr   = 0;
        #10;
        addr = 31;
        wr   = 0;
        #10;
        addr = 32;
        wr   = 0;
        #10;
        $stop;
    end
endmodule
