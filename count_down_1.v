
module count_down_1(input [6:0] count,input enable, output reg [8:0] number1,number2);
	reg [6:0] count_n,count_d;
	
	always@(count) begin if(enable==0) begin number1<=9'h120;number2<=9'h120;end
		else begin
		count_n=count/10;
		count_d=count%10;
		
			number1={2'b10,(count_n+7'd48)};
			number2={2'b10,(count_d+7'd48)};
		end
	end

endmodule 