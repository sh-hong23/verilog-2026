`timescale 1ns / 1ps

module unit_loop_back(
    input clk,
    input reset,
    input rx,
    output tx

    );

     wire w_baud_tick_x16;
     wire w_rx_done;
     wire [7:0] w_rx_data;

    uart_tx U_UART_TX (
        .clk(clk),
        .reset(reset),
        .tx_start(w_rx_done),  // btn_debounce
        .tx_data(w_rx_data),
        .i_baud_tick(w_baud_tick_x16),  //baud_tick
        .tx(tx),
        .tx_busy(),
        .tx_done()
    );


    baud_tick_x16 U_BAUD_TICK_x16 (
        .clk(clk),
        .reset(reset),
        .o_baud_tick(w_baud_tick_x16)
    );


    uart_rx U_UART_RX (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .i_baud_tick(w_baud_tick_x16),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );
endmodule
