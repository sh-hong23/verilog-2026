`timescale 1ns / 1ps

module smartwatch(
    input clk,
    input reset,
    input btn_L,
    input btn_R,
    input btn_U,
    input btn_D,
    input [3:0] sw,
    output [4:0] hour,
    output [5:0] min,
    output [5:0] sec,
    output [6:0] msec
    );

    wire w_btn_L, w_btn_R, w_btn_U, w_btn_D;
    wire [4:0] w_hour, w1_hour, disp_hour;
    wire [5:0] w_min, w1_min, disp_min;
    wire [5:0] w_sec, w1_sec, disp_sec;
    wire [6:0] w_msec, w1_msec, disp_msec;

    assign disp_hour = sw[1] ? w_hour : w1_hour;
    assign disp_min = sw[1] ? w_min : w1_min;
    assign disp_sec = sw[1] ? w_sec : w1_sec;
    assign disp_msec = sw[1] ? w_msec : w1_msec;


top_watch U_WATCH (
    .clk(clk),
    .reset(reset),
    .btn_L(w_btn_L),
    .btn_R(w_btn_R),
    .btn_U(w_btn_U),
    .btn_D(w_btn_D),
    .sw(sw),
    .led(led15),
    .hour(w_hour),
    .min(w_min),
    .sec(w_sec),
    .msec(w_msec)
);

top_stopwatch U_STOPWATCH (
    .clk(clk),
    .reset(reset),
    .btn_L(w1_btn_L),    
    .btn_R(w1_btn_R),   
    .btn_U(w1_btn_U), 
    .btn_D(w1_btn_D),     
    .lap_sw(sw1),
    .led(led2),
    .hour(w1_hour),
    .min(w1_min),
    .sec(w1_sec),
    .msec(w1_msec)
);


fnd_controller U_FND_CNRL(
    .clk(clk),
    .reset(reset),
    .msec(msec),
    .sec(sec),
    .min(min),
    .hour(hour),
    .display_mode(sw[0]),
    .fnd_com(fnd_com),
    .fnd_data(fnd_data)
);
endmodule