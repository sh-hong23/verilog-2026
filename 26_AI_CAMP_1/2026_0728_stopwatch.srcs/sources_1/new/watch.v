`timescale 1ns / 1ps

module watch ();
endmodule

module watch_datapath #(

    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5  // 100,60,60,24

) (
    input clk,
    input reset,
    input sel,
    output [MSEC_WIDTH-1:0] msec,
    output [SEC_WIDTH-1:0] sec,
    output [MIN_WIDTH-1:0] min,
    output [HOUR_WIDTH-1:0] hour,
    output [4:0] display_out,
    output pm

);

    wire w_tick_100hz, w_tick_sec, w_tick_min, w_tick_hour;
    wire w_shift_up, w_shift_down, w_time_up, w_time_down;
    wire [4:0] w_hour_12;
    wire [4:0] w_hour_24;
    wire [4:0] w_display_out;
    

    assign w_shift_up = 1'b0;
    assign w_shift_down = 1'b0;
    assign w_time_up = 1'b0;
    assign w_time_down = 1'b0;
    assign w_hour_24 = hour;
    assign display_out = w_display_out;
    assign pm = w_hour_24 >= 5'd12;




    mux_2x1_1224 U_MUX_2X1 (
    .sel(sel),
    .hour_24(hour),
    .hour_12(w_hour_12),
    .display_hour(w_display_out)
);

    hour_change U_HOUR_CHANGE (
    .hour_24(w_hour_24),
    .hour_12(w_hour_12)
);




    time_counter_watch #(
        .BIT_WIDTH(HOUR_WIDTH),
        .TIMES(24)
    ) U_HOUR_COUNTER (
        .clk(clk),
        .reset(reset),
        .i_tick(w_tick_hour),
        .time_count(hour),
        .shift_up(w_shift_up),
        .shift_dowm(w_shift_down),
        .time_up(w_time_up),
        .time_down(w_time_down),
        .o_tick()
    );

    time_counter_watch #(
        .BIT_WIDTH(MIN_WIDTH),
        .TIMES(60)
    ) U_MIN_COUNTER (
        .clk(clk),
        .reset(reset),
        .i_tick(w_tick_min),
        .time_count(min),
        .o_tick(w_tick_hour),
        .shift_up(w_shift_up),
        .shift_dowm(w_shift_down),
        .time_up(w_time_up),
        .time_down(w_time_down)
    );


    time_counter_watch #(
        .BIT_WIDTH(SEC_WIDTH),
        .TIMES(60)
    ) U_SEC_COUNTER (
        .clk(clk),
        .reset(reset),
        .i_tick(w_tick_sec),
        .time_count(sec),
        .o_tick(w_tick_min),
        .shift_up(w_shift_up),
        .shift_dowm(w_shift_down),
        .time_up(w_time_up),
        .time_down(w_time_down)
    );


    time_counter_watch #(
        .BIT_WIDTH(MSEC_WIDTH),
        .TIMES(100)
    ) U_MSEC_COUNTER (
        .clk(clk),
        .reset(reset),
        .i_tick(w_tick_100hz),
        .time_count(msec),
        .o_tick(w_tick_sec),
        .shift_up(w_shift_up),
        .shift_dowm(w_shift_down),
        .time_up(w_time_up),
        .time_down(w_time_down)
    );


    tick_gen_100hz U_TICK_GEN_100HZ (
        .clk(clk),
        .reset(reset),
        .o_tick(w_tick_100hz)
    );


 endmodule


module mux_2x1_1224 (
    input sel,
    input [4:0] hour_24,
    input [4:0] hour_12,
    output [4:0] display_hour
);

    assign display_hour = (sel) ? hour_12 : hour_24;

endmodule

module hour_change (
    input [4:0] hour_24,
    output reg [4:0] hour_12
);

    always @(*) begin
        if (hour_24 == 0) hour_12 = 5'd12;
        else begin
            if (hour_24 > 5'd12) hour_12 = hour_24 - 5'd12;
            else begin
                hour_12 = hour_24;
            end
        end
    end
endmodule


module time_counter_watch #(
    parameter BIT_WIDTH = 7,
    TIMES = 100
) (
    input clk,
    input reset,
    input i_tick,
    input shift_up,
    input shift_dowm,
    input time_up,
    input time_down,
    output [BIT_WIDTH-1:0] time_count,
    output reg o_tick
);

    reg [$clog2(TIMES)-1:0] counter_reg;

    assign time_count = counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            o_tick <= 1'b0;
        end else begin
            if (i_tick) begin
                counter_reg <= counter_reg + 1;
                if (counter_reg == (TIMES - 1)) begin
                    counter_reg <= 1'b0;
                    o_tick <= 1'b1;
                end else begin
                    o_tick <= 1'b0;
                end
            end else begin
                o_tick <= 1'b0;
            end
        end
    end
endmodule


module tick_gen_100hz (
    input clk,
    input reset,
    output reg o_tick
);
    parameter F_COUNT = 1_000_000;

    reg [$clog2(F_COUNT) - 1 : 0] counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            o_tick <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == (F_COUNT - 1)) begin
                counter_reg <= 0;
                o_tick <= 1'b1;
            end else begin
                o_tick <= 1'b0;
            end
        end
    end
endmodule
