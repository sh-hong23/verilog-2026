`timescale 1ns / 1ps

module ascii_sender(
    input [7:0] cnontrol_unit_result,
    output push,
    output tx_data
);
endmodule



module ascii_encoder(
    input [8:0] data_control_unit,
    output push,
    output [7:0] tx_data
);

always @(*) begin
    
end


endmodule

module digit_splitter(
    input [8:0] seg_data,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100
);

    assign digit_1 = seg_data % 10;
    assign digit_10 = (seg_data / 10) % 10;
    assign digit_100 = (seg_data / 100) % 10;

endmodule

