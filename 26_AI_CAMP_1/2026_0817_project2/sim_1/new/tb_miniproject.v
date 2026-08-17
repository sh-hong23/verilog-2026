`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// tb_top.v
// top ëª¨ë“ˆ ?†µ?•© ?…Œ?Š¤?Š¸ë²¤ì¹˜
//
// êµ¬ì„±:
//   1) UART TX BFM  : ?˜¸?Š¤?Š¸ -> DUT rx (9600bps, start-8data-stop)
//   2) UART RX ëª¨ë‹ˆ?„°: DUT tx -> ?˜¸?Š¤?Š¸ (ë°±ê·¸?¼?š´?“œ?—?„œ ê³„ì† ?ˆ˜?‹ , ì¶œë ¥)
//   3) SR04 echo BFM : trigger ê°ì? -> ê±°ë¦¬(cm)?— ë¹„ë??•˜?Š” echo ?„?Š¤ ?ƒ?„±
//   4) DHT11 slave BFM: start ?‹ ?˜¸(?¼?¸ ë¡œìš°) ê°ì? -> DHT11 ?”„ë¡œí† ì½œë?ë¡? 40bit ?‘?‹µ
//   5) ë¬¼ë¦¬ ë²„íŠ¼(btnl/r/u/d, sw) ì§ì ‘ êµ¬ë™ ?‹œ?‚˜ë¦¬ì˜¤ (smartwatch ê²½ë¡œ)
//
// ì£¼ì˜: ascii_decoder ?‚´ë¶??— ?˜ì¹?(uninitialized latch) ?´?Šˆê°? ?ˆ?–´
//       ?‹œë®¬ë ˆ?´?…˜ 0ns ?‹œ? ?— forceë¡? 0 ì´ˆê¸°?™”?•¨. (?›?¸?? ?‘?‹µ ì½”ë“œ ì°¸ê³ )
//////////////////////////////////////////////////////////////////////////////////

module tb_miniproject;

    // ============================================================
    // clock / reset
    // ============================================================
    reg clk = 1'b0;
    reg rst;
    localparam CLK_PERIOD = 10; // 100MHz
    always #(CLK_PERIOD/2) clk = ~clk;

    // ============================================================
    // DUT ports
    // ============================================================
    reg         rx;
    wire        tx;
    reg         echo;
    wire        trig;
    wire        dht11_line;
    reg  [3:0]  sw;
    reg         btnl, btnr, btnu, btnd;
    wire [3:0]  fnd_com;
    wire [7:0]  fnd_data;

    // dht11 inout : ?…Œ?Š¤?Š¸ë²¤ì¹˜ê°? ?Š¬? ˆ?´ë¸? ?—­?• ?„ ?•  ?•Œë§? ?¼?¸?„ êµ¬ë™
    reg  dht11_drive_en;
    reg  dht11_drive_val;
    assign dht11_line = dht11_drive_en ? dht11_drive_val : 1'bz;
    pullup(dht11_line);   // ?‹¤? œ ë³´ë“œ?˜ ???—… ???•­ ?—­?• 

    top DUT (
        .clk    (clk),
        .rst    (rst),
        .rx     (rx),
        .tx     (tx),
        .echo   (echo),
        .trig   (trig),
        .dht11  (dht11_line),
        .sw     (sw),
        .btnl   (btnl),
        .btnr   (btnr),
        .btnu   (btnu),
        .btnd   (btnd),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    // ============================================================
    // ascii_decoder ?˜ì¹? ?´?Šˆ ?š°?šŒ?š© ì´ˆê¸°?™” (0ns ?‹œ?  1?šŒ)
    // ============================================================
    initial begin
        force DUT.u_ascii_decoder.rs_stopwatch_reg    = 1'b0;
        force DUT.u_ascii_decoder.clear_stopwatch_reg = 1'b0;
        force DUT.u_ascii_decoder.down_stopwatch_reg  = 1'b0;
        force DUT.u_ascii_decoder.lap_stopwatch_reg   = 1'b0;
        force DUT.u_ascii_decoder.edit_watch_reg      = 1'b0;
        force DUT.u_ascii_decoder.left_watch_reg      = 1'b0;
        force DUT.u_ascii_decoder.right_watch_reg     = 1'b0;
        force DUT.u_ascii_decoder.up_watch_reg        = 1'b0;
        force DUT.u_ascii_decoder.down_watch_reg      = 1'b0;
        #1;
        release DUT.u_ascii_decoder.rs_stopwatch_reg;
        release DUT.u_ascii_decoder.clear_stopwatch_reg;
        release DUT.u_ascii_decoder.down_stopwatch_reg;
        release DUT.u_ascii_decoder.lap_stopwatch_reg;
        release DUT.u_ascii_decoder.edit_watch_reg;
        release DUT.u_ascii_decoder.left_watch_reg;
        release DUT.u_ascii_decoder.right_watch_reg;
        release DUT.u_ascii_decoder.up_watch_reg;
        release DUT.u_ascii_decoder.down_watch_reg;
    end

    // ============================================================
    // UART ?ŒŒ?¼ë¯¸í„°
    //   baud_tick_gen(BAUD_RATE=153_600, 16x oversample)
    //   -> ?‹¤? œ ?†µ?‹  ?†?„ = 153600/16 = 9600 bps
    // ============================================================
    localparam real BIT_TIME = 1_000_000_000.0 / 9600.0; // ns (~104166ns)

    // ---------- UART TX (host -> DUT rx) ----------
    task uart_send_byte(input [7:0] data);
        integer i;
        begin
            rx = 1'b0;                 // start bit
            #(BIT_TIME);
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];           // LSB first
                #(BIT_TIME);
            end
            rx = 1'b1;                 // stop bit
            #(BIT_TIME);
        end
    endtask

    // ë°”ì´?Š¸ ?•©?´ target?´ ?˜?„ë¡? ?‚˜?ˆ  ë³´ë‚¸ ?’¤ '.'(0x2E)ë¡? ë§ˆë¬´ë¦?
    task send_command(input integer target);
        integer remaining;
        integer chunk;
        begin
            remaining = target;
            while (remaining > 0) begin
                chunk = (remaining > 255) ? 255 : remaining;
                uart_send_byte(chunk[7:0]);
                remaining = remaining - chunk;
            end
            uart_send_byte(8'h2E); // '.'
            $display("[%0t] TX(host->DUT) command sum=%0d Àü¼Û ¿Ï·á", $time, target);
        end
    endtask

    // ---------- UART RX ëª¨ë‹ˆ?„° (DUT tx -> host) ----------
    reg [7:0] rx_byte;
    task uart_receive_byte(output [7:0] data);
        integer i;
        begin
            @(negedge tx);              // start bit edge
            #(BIT_TIME * 1.5);          // start bit ì¤‘ì•™ê¹Œì? ?´?™ ?›„ ?°?´?„° ë¹„íŠ¸ë¡?
            for (i = 0; i < 8; i = i + 1) begin
                data[i] = tx;
                #(BIT_TIME);
            end
        end
    endtask

    initial begin
        forever begin
            uart_receive_byte(rx_byte);
            $display("[%0t] RX(DUT->host) byte = 0x%02h ('%c')", $time, rx_byte,
                      (rx_byte >= 8'h20 && rx_byte <= 8'h7E) ? rx_byte : "?");
        end
    end

    // ============================================================
    // SR04 echo BFM
    //   trigger ?„?Š¤ ê°ì? -> WAIT ?›„ echo High
    //   echo High ?œ ì§??‹œê°?(us) = distance_cm * 58  (ì»¨íŠ¸ë¡¤ëŸ¬?˜ /58 ê³„ì‚°ê³? ë§¤ì¹­)
    // ============================================================
    task sr04_respond(input integer distance_cm);
        integer echo_high_ns;
        begin
            echo = 1'b0;
            @(posedge trig);
            @(negedge trig);            // ?Š¸ë¦¬ê±° ?„?Š¤(?•½ 11us) ì¢…ë£Œ ??ê¸?
            #(5_000);                   // WAIT ?ƒ?ƒœ ?„?˜ ì§??—°
            echo = 1'b1;
            echo_high_ns = distance_cm * 58 * 1000; // us -> ns
            #(echo_high_ns);
            echo = 1'b0;
            $display("[%0t] SR04 BFM: distance=%0dcm, echo_high=%0dus ÀÀ´ä ¿Ï·á",
                       $time, distance_cm, distance_cm*58);
        end
    endtask

    // ============================================================
    // DHT11 slave BFM
    //   MCU(FPGA)ê°? ?¼?¸?„ ë¡œìš°ë¡? ?Œ?–´?‚´ë¦¬ëŠ” START êµ¬ê°„?„ ê°ì??•œ ?’¤
    //   ACK(80us low + 80us high) -> 40bit ?°?´?„° ?ˆœì°? ? „?†¡
    // ============================================================
    task dht11_respond(input [7:0] hum_int, input [7:0] hum_dec,
                        input [7:0] temp_int, input [7:0] temp_dec);
        reg [7:0] checksum;
        reg [39:0] frame;
        integer i;
        begin
            checksum = hum_int + hum_dec + temp_int + temp_dec;
            frame = {hum_int, hum_dec, temp_int, temp_dec, checksum};

            @(negedge dht11_line);      // MCU START (line low)
            @(posedge dht11_line);      // MCU WAIT ì¢…ë£Œ (line released high)

            dht11_drive_en  = 1'b1;
            dht11_drive_val = 1'b0;     // ACK low 80us
            #(80_000);
            dht11_drive_val = 1'b1;     // ACK high 80us
            #(80_000);

            for (i = 39; i >= 0; i = i - 1) begin
                dht11_drive_val = 1'b0; // ê°? ë¹„íŠ¸ ?‹œ?‘: 50us low
                #(50_000);
                dht11_drive_val = 1'b1;
                if (frame[i]) #(70_000); // '1' : 70us high
                else           #(27_000); // '0' : 26~28us high
            end

            dht11_drive_val = 1'b0;     // ì¢…ë£Œ 50us low
            #(50_000);
            dht11_drive_en = 1'b0;      // ë²„ìŠ¤ ë¦´ë¦¬ì¦? (???—…?´ 1 ?œ ì§?)

            $display("[%0t] DHT11 BFM: H=%0d.%0d%%  T=%0d.%0dC ÀÀ´ä ¿Ï·á",
                      $time, hum_int, hum_dec, temp_int, temp_dec);
        end
    endtask

    // ============================================================
    // ë©”ì¸ ?‹œ?‚˜ë¦¬ì˜¤
    // ============================================================
    initial begin
        // ì´ˆê¸°?™”
        rst   = 1'b1;
        rx    = 1'b1;   // UART idle = high
        echo  = 1'b0;
        sw    = 4'b0000;
        btnl  = 1'b0; btnr = 1'b0; btnu = 1'b0; btnd = 1'b0;
        dht11_drive_en  = 1'b0;
        dht11_drive_val = 1'b1;

        repeat (10) @(posedge clk);
        rst = 1'b0;
        repeat (10) @(posedge clk);

        // ---------------------------------------------------------
        // ?‹œ?‚˜ë¦¬ì˜¤ 1: SR04 ëª¨ë“œ ?„ ?ƒ + ì¸¡ì • ?Š¸ë¦¬ê±° (acc==681)
        //   acc==681 ?? state_reg(SR04 ?„ ?ƒ)?? sr04_start ?„?Š¤ë¥?
        //   ?™?‹œ?— ?œ ë°œí•¨ -> controllerê°? SR04 ?ƒ?ƒœë¡? ì§„ì…,
        //   BFM?´ ?Š¸ë¦¬ê±°ë¥? ê°ì??•´ 15cm ?ƒ?‹¹?˜ echo ?‘?‹µ
        // ---------------------------------------------------------
        $display("\n===== [SCENARIO 1] SR04 °Å¸® ÃøÁ¤ (15cm) =====");
        fork
            send_command(681);
            sr04_respond(15);
        join
        // done -> BUSY(10ms) -> controllerê°? ê°’ì„ ?½?–´ UARTë¡? 3ë°”ì´?Š¸ ? „?†¡?•  ?•Œê¹Œì? ??ê¸?
        #(15_000_000); // 15ms ?—¬?œ 

        // ---------------------------------------------------------
        // ?‹œ?‚˜ë¦¬ì˜¤ 2: DHT11 ëª¨ë“œ ?„ ?ƒ + ì¸¡ì • ?Š¸ë¦¬ê±° (acc==770)
        // ---------------------------------------------------------
        $display("\n===== [SCENARIO 2] DHT11 ¿Â½Àµµ ÃøÁ¤ (½Àµµ 55.2%%, ¿Âµµ 24.7C) =====");
        fork
            send_command(770);
            dht11_respond(8'd55, 8'd2, 8'd24, 8'd7);
        join
        #(5_000_000); // 5ms ?—¬?œ  (STOP ?ƒ?ƒœ + ?°?´?„° ?½ê¸?/? „?†¡)

        // ---------------------------------------------------------
        // ?‹œ?‚˜ë¦¬ì˜¤ 3: WATCH ëª¨ë“œ ?„ ?ƒ + ì¡°íšŒ (acc==887)
        //   ë¬¼ë¦¬ ë²„íŠ¼?œ¼ë¡? ?›Œì¹˜ë?? ëª? ì´? ?Œ? ¤ë³? ?’¤ ì¡°íšŒ
        // ---------------------------------------------------------
        $display("\n===== [SCENARIO 3] WATCH Á¶È¸ =====");
        sw[1] = 1'b0; // controller.sw=0 -> btnl/r/u/dê°? watchë¡? ?—°ê²?
        btnl = 1'b1; repeat (5) @(posedge clk); btnl = 1'b0; // run
        #(2_000_000); // ?‹œê³? ? ê¹? ?˜? ¤ë³´ê¸°
        send_command(887);
        #(500_000);

        // ---------------------------------------------------------
        // ?‹œ?‚˜ë¦¬ì˜¤ 4: STOPWATCH ëª¨ë“œ ?„ ?ƒ + ì¡°íšŒ (acc==669)
        // ---------------------------------------------------------
        $display("\n===== [SCENARIO 4] STOPWATCH Á¶È¸ =====");
        sw[1] = 1'b1; // controller.sw=1 -> btnl/r/u/dê°? stopwatchë¡? ?—°ê²?
        btnl = 1'b1; repeat (5) @(posedge clk); btnl = 1'b0; // run_stop
        #(2_000_000);
        send_command(669);
        #(500_000);

        $display("\n===== ¸ğµç ½Ã³ª¸®¿À Á¾·á =====");
        $finish;
    end

    // ============================================================
    // ???„?•„?›ƒ ?•ˆ? „?¥ì¹? (?‹œë®¬ë ˆ?´?…˜?´ ë©ˆì¶”?Š” ê²½ìš° ??ë¹?)
    // ============================================================
    initial begin
        #(60_000_000); // 60ms
        $display("[%0t] TIMEOUT: ½Ã¹Ä·¹ÀÌ¼Ç °­Á¦ Á¾·á", $time);
        $finish;
    end


endmodule