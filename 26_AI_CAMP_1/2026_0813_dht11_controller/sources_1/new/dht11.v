`timescale 1ns / 1ps

module dht(
    input clk,
    input reset,
    input start,
    output [15:0] humidity,
    output [15:0] temperature,
    output done,
    output valid,
    inout dbt11_io
);

localparam [2:0] IDLE = 0, START = 1, WAIT = 2, SYNC = 3, DATA = 4, STOP = 5;

reg [2:0] c_state, n_state;
reg dbt11_io_reg, dbt11_io_next;
reg w_dbt11;
reg [$clog2(19_000)-1:0] tick_count_reg, tick_count_next;
reg SYNCH, SYNCL;

assign dbt11_io = (w_dbt11) ? dbt11_io_reg : 1'bz;


//현재상태
always @(posedge clk, posedge reset) begin
    if(reset) begin
        c_state <= IDLE;
        dbt11_io_reg <= dbt11_io_next;
    end else begin
        c_state <= n_state;
        dbt11_io_reg <= dbt11_io_next;
    end
end

    always @(*) begin
        n_state = c_state;
        dbt11_io_next = dbt11_io_reg;
        case(c_state)
        IDLE : begin
            w_dbt11 = 1'b1;
            if(START) begin
                n_state = START;
                dbt11_io_next = 0;
            end else begin
                n_state = IDLE;
            end
        end
        START : begin
            if(tick_count_reg == 19_000) begin
                n_state = WAIT;
                dbt11_io_next = 1'b1;
                tick_count_next = 0;
            end else begin
                n_state = START;
                tick_count_next = tick_count_reg  + 1;
            end
        end
        WAIT :begin
            if(tick_count_reg == 30) begin
                n_state = SYNC;
                dbt11_io_next = 1'b0;
                tick_count_next = 0;
            end else begin
                n_state = WAIT;
                tick_count_next = tick_count_reg + 1;
            end
        end
        SYNC : begin
            w_dbt11 = 1'b0;
            if(tick_count_reg == 80) begin
                n_state = DATA;
            end
                
            end                
            end
                
        end
        endcase
    end
endmodule