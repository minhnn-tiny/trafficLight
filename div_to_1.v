module div_to_1(input CLOCK_50, output reg clk_out);
	
	parameter scale = 25000000;
	reg [24:0] count;

	initial count = 1'd0;
	initial clk_out = 1'b0;

	always @(posedge CLOCK_50) begin 
		if (count == scale) begin
			count <= 25'd0;
			clk_out <= !clk_out;
		end
		else count <= count + 1;

	end


endmodule 