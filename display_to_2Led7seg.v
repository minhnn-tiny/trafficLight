module display_to_2Led7seg (input enable, input [6:0] count, output [6:0] hex0, hex1);

wire [3:0] count_n, count_d;

assign count_n = count / 10;
assign count_d = count % 10;

led7seg A(.enable(enable), .BCD(count_n), .led7seg(hex1));
led7seg B(.enable(enable), .BCD(count_d), .led7seg(hex0));


endmodule 