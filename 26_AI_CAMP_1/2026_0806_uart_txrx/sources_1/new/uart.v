`timescale 1ns / 1ps

//TOP module
module uart_controller (
    input  clk,
    input  reset,
    input  btn_R,
    output [7:0] led,
    output tx
);
    wire w_baud_tick;
    wire w_tx_start;
    wire w_baud_tick_x16;


    btn_debounce U_BD_UART_TX_START (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_R),
        .o_btn(w_tx_start)
    );

    uart_tx U_UART_TX (
        .clk(clk),
        .reset(reset),
        .tx_start(w_tx_start),
        .tx_data(8'h30),
        .i_baud_tick(w_baud_tick),
        .tx(tx)

    );
    baud_tick U_BAUD_TICK (
        .clk(clk),
        .reset(reset),
        .o_baud_tick(w_baud_tick)
    );

        baud_tick_x16 U_BAUD_TICK_x16 (
        .clk(clk),
        .reset(reset),
        .o_baud_tick(w_baud_tick_x16)
    );


     uart_rx U_UART_RX (
    .clk(clk),
    .reset(reset),
    .rx(tx),
    .i_baud_tick(w_baud_tick_x16),
     .rx_data(led),
     .rx_done()
);

endmodule


module uart_rx (
    input clk,
    input reset,
    input rx,
    input i_baud_tick,
    output [7:0] rx_data,
    output rx_done
);

    localparam [1:0] IDLE = 0, START = 1;
    localparam [1:0] DATA = 2, STOP = 3;

    reg [1:0] c_state, n_state;
    reg [3:0] tick_count_reg, tick_count_next;
    reg [2:0] bit_count_reg, bit_count_next;
    reg [7:0] data_reg, data_next;
    //for CL output
    //reg rx_done_reg;
    //for SL output
    reg rx_done_reg, rx_done_next;

    assign rx_done = rx_done_reg;
    assign rx_data = data_reg;

    // state SL
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= IDLE;
            tick_count_reg <= 0;
            bit_count_reg <= 0;
            data_reg <= 0;
            rx_done_reg <= 0;
        end else begin
            c_state <= n_state;
            tick_count_reg <= tick_count_next;
            bit_count_reg <= bit_count_next;
            data_reg <= data_next;
            rx_done_reg <= rx_done_next;
        end
    end

    //next
    always @(*) begin
        n_state = c_state;
        bit_count_next = bit_count_reg;
        tick_count_next = tick_count_reg;
        data_next = data_reg;
        //for CL output
        //rx_done_reg = 0;
        //for SL output
        rx_done_next = rx_done_reg;
        case (c_state)
            IDLE: begin
                //for SL output
                rx_done_next = 0;
                if (i_baud_tick) begin
                    if (!rx) begin
                        if (tick_count_reg == 7) begin
                            n_state = START;
                            tick_count_next = 0;
                        end else begin
                            tick_count_next = tick_count_reg + 1;
                        end
                    end else begin
                        data_next = 0;
                        tick_count_next = 0;
                        bit_count_next = 0;

                    end
                end
            end
            START: begin
                if (i_baud_tick) begin
                    if (tick_count_reg == 15) begin
                        tick_count_next = 0;
                        n_state = DATA;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            DATA: begin
                if (i_baud_tick) begin
                    if (tick_count_reg == 0) begin
                        // data_next = data_reg[bit_count_reg]; // PIPO, bit indexing
                        // SIPO
                        data_next = {rx, data_reg[7:1]};
                    end
                    if (tick_count_reg == 15) begin
                        tick_count_next = 0;
                        if (bit_count_reg == 7) begin
                            n_state = STOP;
                        end else begin
                            bit_count_next = bit_count_reg + 1;
                        end
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            STOP: begin
                if (i_baud_tick) begin
                    if (tick_count_reg == 7) begin
                        // for CL output
                        //rx_done_reg = 1;
                        //for SL output
                        rx_done_next = 1;
                        n_state = IDLE;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule


module uart_tx (
    input clk,
    input reset,
    input tx_start,
    input [7:0] tx_data,
    input i_baud_tick,
    output tx,
    output tx_busy,
    output tx_done
);
    localparam [2:0] IDLE = 3'd0, START = 3'd1;
    localparam [2:0] DATA = 3'd2, STOP = 3'd3;
    localparam [2:0] WAIT = 3'd4;


    reg [2:0] c_state, n_state;
    //3bit counter register
    reg [2:0] bit_count_reg, bit_count_next;
    reg tx_reg, tx_next;
    reg [7:0] data_reg, data_next;

    reg tx_busy_reg, tx_busy_next;
    reg tx_done_reg, tx_done_next;

    assign tx = tx_reg;
    assign tx_busy = tx_busy_reg;
    assign tx_done = tx_done_reg;



    //state register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state       <= IDLE;
            bit_count_reg <= 3'd0;
            tx_reg        <= 1'b1;
            data_reg      <= 8'h00;
            tx_busy_reg   <= 1'b0;
            tx_done_reg   <= 1'b0;
        end else begin
            c_state <= n_state;
            bit_count_reg <= bit_count_next;
            tx_reg <= tx_next;
            data_reg <= data_next;
            tx_busy_reg <= tx_busy_next;
            tx_done_reg <= tx_done_next;
        end
    end

    //next ,output CL
    always @(*) begin
        n_state = c_state;
        bit_count_next = bit_count_reg;
        tx_next = tx_reg;
        data_next    = data_reg;
        tx_busy_next = tx_busy_reg;
        tx_done_next = tx_done_reg;
        case (c_state)
            IDLE: begin
                //output
                tx_next = 1'b1;
                tx_busy_next = 1'b0;
                tx_done_next = 1'b0;
                //condition of next transition : moore output
                if (tx_start) begin
                    data_next = tx_data;
                    tx_busy_next = 1'b1;
                    n_state = WAIT;
                end
            end
            WAIT: begin
                if (i_baud_tick) n_state = START;
            end
            START: begin
                tx_next = 1'b0;
                bit_count_next = 3'd0;
                if (i_baud_tick) begin
                    n_state = DATA;
                end
            end
            DATA: begin
                tx_next = data_reg[bit_count_reg];
                if (i_baud_tick) begin
                    if (bit_count_reg == 7) n_state = STOP;
                    else begin
                        n_state = DATA;
                        bit_count_next = bit_count_reg + 1;
                    end
                end
            end
            STOP: begin
                tx_next = 1'b1;
                if (i_baud_tick) begin
                    tx_busy_next = 1'b0;
                    tx_done_next = 1'b1;  // tx_done tick
                    n_state = IDLE;
                end
            end
        endcase
    end
endmodule


module baud_tick_x16 (
    input  clk,
    input  reset,
    output o_baud_tick
);
    //9600bps baud tick gen
    //tick count = input freq / baud_tick_freq
    parameter F_COUNT = 100_000_000 / (9600 * 16);


    reg [$clog2(F_COUNT)-1:0] count_reg, count_next;

    //assign
    // reg  [$clog2(F_COUNT)-1:0] count_reg;
    // wire [$clog2(F_COUNT)-1:0] count_next;

    //count_reg SL
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
        end else begin
            count_reg <= count_next;
        end
    end

    //count_next CL
    // assign count_next  = (count_reg == F_COUNT - 1) ? 0 : count_reg + 1;

    always @(*) begin
        //count_next = count_reg;
        if (count_reg == F_COUNT - 1) count_next = 0;
        else count_next = count_reg + 1;
    end

    //output CL
    assign o_baud_tick = (count_reg == (F_COUNT - 1)) ? 1 : 0;

endmodule




module baud_tick (
    input  clk,
    input  reset,
    output o_baud_tick
);
    //9600bps baud tick gen
    //tick count = input freq / baud_tick_freq
    parameter F_COUNT = 100_000_000 / 9600;


    reg [$clog2(F_COUNT)-1:0] count_reg, count_next;

    //assign
    // reg  [$clog2(F_COUNT)-1:0] count_reg;
    // wire [$clog2(F_COUNT)-1:0] count_next;

    //count_reg SL
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
        end else begin
            count_reg <= count_next;
        end
    end

    //count_next CL
    // assign count_next  = (count_reg == F_COUNT - 1) ? 0 : count_reg + 1;

    always @(*) begin
        //count_next = count_reg;
        if (count_reg == F_COUNT - 1) count_next = 0;
        else count_next = count_reg + 1;
    end

    //output CL
    assign o_baud_tick = (count_reg == (F_COUNT - 1)) ? 1 : 0;

endmodule

module baud_tick_2 (
    input  clk,
    input  reset,
    output o_baud_tick
);
    //9600bps baud tick gen
    //tick count = input freq / baud_tick_freq
    parameter F_COUNT = 100_000_000 / 9600;
    reg [$clog2(F_COUNT)-1:0] count_reg;

    //output CL
    assign o_baud_tick = (count_reg == (F_COUNT - 1)) ? 1'b1 : 1'b0;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
        end else begin
            count_reg <= count_reg + 1;
            if (count_reg == (F_COUNT - 1)) begin
                count_reg <= 0;
            end
        end
    end

endmodule
