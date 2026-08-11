`timescale 1ns / 1ps

module uart_fifo_loopback (
    input  clk,
    input  reset,
    input  rx,
    output tx
);

    wire w_baud_tick_x16;
    wire w_rx_done;
    wire [7:0] w_rx_data;
    wire w_fifo_tx_full, w_fifo_tx_empty, w_fifo_rx_empty, w_tx_busy;
    wire [7:0] w_fifo_rx_rdata;
    wire [7:0] w_fifo_tx_rdata;


    baud_tick_x16 U_BAUD_TICK_X16 (
        .clk(clk),
        .reset(reset),
        .o_baud_tick(w_baud_tick_x16)
    );

    uart_tx U_UART_TX (
        .clk(clk),
        .reset(reset),
        .tx_start(~w_fifo_tx_empty),
        .tx_data(w_fifo_tx_rdata),
        .i_baud_tick(w_baud_tick_x16),
        .tx(tx),
        .tx_busy(w_tx_busy),
        .tx_done()
    );


    uart_rx U_UART_RX (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .i_baud_tick(w_baud_tick_x16),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

    //RX
    fifo U_FIFO_RX (
        .clk  (clk),
        .reset(reset),
        .push (w_rx_done),
        .pop  (~w_fifo_tx_full),
        .wdata(w_rx_data),
        .rdata(w_fifo_rx_rdata),
        .full (),
        .empty(w_fifo_rx_empty)
    );

    //TX
    fifo U_FIFO_TX (
        .clk  (clk),
        .reset(reset),
        .push (~w_fifo_rx_empty),
        .pop  (~w_tx_busy),
        .wdata(w_fifo_rx_rdata),
        .rdata(w_fifo_tx_rdata),
        .full (w_fifo_tx_full),
        .empty(w_fifo_tx_empty)
    );

endmodule

