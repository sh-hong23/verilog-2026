`timescale 1ns / 1ps

module tb_uart_controller ();

    reg clk, reset, tx_start;
    reg [7:0] tx_data;
    reg rx;
    wire [7:0] rx_data;
    wire rx_done, tx_busy, tx_done;
    wire tx;
    // for simulation loop
    integer i = 0;

    uart_controller dut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .rx(rx),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .rx_done(rx_done),
        .rx_data(rx_data),
        .tx(tx)
    );

    parameter BAUD_TICK = (100_000_000 / 9600) * 10;

    always #5 clk = ~clk;

    // task : uart tx start

    task UART_TX_START_TASK(input [7:0] data);
        begin
            // uart_tx
            @(negedge clk);  // wait negedge clk;

            tx_start = 1;
            tx_data  = data;

            @(negedge clk);  // wait negedge clk;
            tx_start = 0;
            // time_control
            //#(BAUD_TICK * 10); 
            // event control
            wait (dut.U_UART_TX.tx_done);
        end
    endtask

    task SENDER_FOR_UART_RX(input [7:0]send_data);
        begin
            //START
            rx = 0;
            #(BAUD_TICK);
            //DATA
            for (i = 0; i < 8; i = i + 1) begin
                rx = send_data[i];
                #(BAUD_TICK);
            end
            rx = 1;
            #(BAUD_TICK);
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        tx_start = 0;
        tx_data = 0;
        rx = 1;
        #10;
        reset = 0;
        #10;
        //simulation for UART_TX
        UART_TX_START_TASK(8'h30);
        UART_TX_START_TASK(8'h31);
        //simulaiton for UART_RX
        SENDER_FOR_UART_RX(8'h32);
        SENDER_FOR_UART_RX(8'h33);



        #100;
        $stop;


    end
endmodule
