`timescale 1ns / 1ps

module stopwatch_datapath #(

    parameter MSEC_WIDTH = 7, SEC_WIDTH = 6, MIN_WIDTH = 6, HOUR_WIDTH = 5)

   (input clk,
    input reset,
    input run_stop,
    input clear,
    input mode,
    output [MSEC_WIDTH-1:0] msec,
    output [SEC_WIDTH-1:0] sec,
    output [MIN_WIDTH-1:0] min,
    output [HOUR_WIDTH-1:0] hour
    );


   // parameter MSEC_WIDTH = 7, SEC_WIDTH = 6, MIN_WIDTH = 6, HOUR_WIDTH = 5;
    wire w_tick_100hz, w_tick_sec, w_tick_min, w_tick_hour;


time_counter #(
    .BIT_WIDTH(HOUR_WIDTH),
    .TIMES(24)
)   U_HOUR_COUNTER (
       .clk(clk),
       .reset(reset),
       .i_tick(w_tick_hour),
       .mode(mode),
       .run_stop(run_stop),
       .clear(clear),
       .time_count(hour),
       .o_tick()
);



time_counter #(
    .BIT_WIDTH(MIN_WIDTH),
    .TIMES(60)
)   U_MIN_COUNTER (
       .clk(clk),
       .reset(reset),
       .i_tick(w_tick_min),
       .mode(mode),
       .run_stop(run_stop),
       .clear(clear),
       .time_count(min),
       .o_tick(w_tick_hour)
);




time_counter #(
    .BIT_WIDTH(SEC_WIDTH),
    .TIMES(60)
)   U_SEC_COUNTER (
       .clk(clk),
       .reset(reset),
       .i_tick(w_tick_sec),
       .mode(mode),
       .run_stop(run_stop),
       .clear(clear),
       .time_count(sec),
       .o_tick(w_tick_min)
);




time_counter #(
    .BIT_WIDTH(MSEC_WIDTH),
    .TIMES(100)
)   U_MSEC_COUNTER (
       .clk(clk),
       .reset(reset),
       .i_tick(w_tick_100hz),
       .mode(mode),
       .run_stop(run_stop),
       .clear(clear),
       .time_count(msec),
       .o_tick(w_tick_sec)
);


 tick_gen_100hz U_TICK_GEN_100HZ (
    .clk(clk),
    .reset(reset),
    .o_tick(w_tick_100hz)
);

endmodule


module tick_gen_100hz (
    input clk,
    input reset,
    output reg o_tick
);
    parameter F_COUNT = 1_000_000;

    reg [$clog2(F_COUNT) - 1 : 0] counter_reg;

    always @ (posedge clk, posedge reset) begin
        if(reset) begin
            counter_reg <= 0;
            o_tick <= 1'b0;
        end 
        else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == (F_COUNT-1)) begin
                    counter_reg <= 0;
                    o_tick <= 1'b1;
            end else begin
                o_tick <= 1'b0;
            end
        end
    end

endmodule

module time_counter #(parameter BIT_WIDTH = 7, TIMES = 100)
(   input clk,
    input reset,
    input i_tick,
    input mode,
    input run_stop,
    input clear,
    output [BIT_WIDTH-1:0] time_count,
    output reg o_tick
);

    reg [$clog2(TIMES)-1:0] counter_reg;

    assign time_count = counter_reg;

always @(posedge clk, posedge reset) begin
    if(reset) begin
        counter_reg <= 0;
        o_tick <= 1'b0;
    end else begin
        if (i_tick) begin
            counter_reg <= counter_reg + 1;
            if(counter_reg == (TIMES - 1)) begin
                counter_reg <= 0;
                o_tick <= 1'b1;
                end
            end else begin
            o_tick <= 1'b0;
            end
        end
    end
endmodule

