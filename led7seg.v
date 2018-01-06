module led7seg(output [6:0] led7seg,input enable, input [3:0] BCD );
	wire [6:0] w_out;
	assign led7seg[6:0] = (enable == 1'b1)?w_out[6:0]:7'b111_1111;
	assign w_out[6:0] = (BCD == 4'd0)?7'b100_0000:
							(BCD == 4'd1)?7'b111_1001:
							(BCD == 4'd2)?7'b010_0100:
							(BCD == 4'd3)?7'b011_0000:
							(BCD == 4'd4)?7'b001_1001:
							(BCD == 4'd5)?7'b001_0010:
							(BCD == 4'd6)?7'b000_0010:
							(BCD == 4'd7)?7'b111_1000:
							(BCD == 4'd8)?7'b000_0000:
							(BCD == 4'd9)?7'b001_0000:7'b111_1111;
endmodule