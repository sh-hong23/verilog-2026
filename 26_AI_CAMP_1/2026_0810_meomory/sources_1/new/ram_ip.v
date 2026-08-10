`timescale 1ns / 1ps

module ram_ip(
    input clk,
    input [5:0] addr,
    input [7:0] wdata,
    input wr,
    output reg [7:0] rdata
    );

    reg [7:0] ram [0:63]; // width, height

    always @ (posedge clk) begin
        if(wr) 
            ram[addr] <= wdata;
        else 
            rdata <= ram[addr];
        end

endmodule
