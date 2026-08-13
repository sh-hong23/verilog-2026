`timescale 1ns / 1ps

module tb_SR04_controller ();

    reg clk, reset, start, echo;
    wire trigger, done;
    wire [8:0] distance;

    SR04_controller dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .echo(echo),
        .trigger(trigger),
        .done(done),
        .distance(distance)
    );

    always #5 clk = ~clk;

    // 원하는 거리(cm)만큼 echo를 유지해주는 task
    task send_echo(input integer cm);
        begin
            #10;                  // 센서 반응 지연 (선택)
            echo = 1;
            #(cm * 58 * 1000);     // us -> ns 변환 (58us/cm)
            echo = 0;
        end
    endtask

    initial begin
        clk   = 0;
        reset = 1;
        start = 0;
        echo  = 0;
        #10;
        reset = 0;
        @(negedge clk);
        start = 1;
        #10;
        start = 0;
        #1000;
        // trigger 펄스 끝날 때까지 대기
        // @(posedge trigger);
        // @(negedge trigger);

        // 50cm 테스트
        send_echo(50);

        // done 뜰 때까지 대기 후 결과 확인
        @(posedge done);
        #1;
        $display("distance = %0d (expected ~50)", distance);

        #(1000);
        $stop;
    end
endmodule