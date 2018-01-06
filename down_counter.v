module down_counter(input CLOCK_50,input load,input reset,input [6:0] count,output [6:0] HEXA,HEXB);
	wire clk_out;
	reg [6:0] dataout;
	wire [3:0] chuc,donvi;
	div_to_1 clock_out(.CLOCK_50(CLOCK_50),.clk_out(clk_out));
	assign chuc=dataout/10;
	assign donvi=dataout%10;
	led7seg A(.enable(1'b1),.BCD(chuc),.led7seg(HEXA));
	led7seg B(.enable(1'b1),.BCD(donvi),.led7seg(HEXB));
	always@(posedge clk_out,negedge reset,negedge load)begin
		if(reset==1'b0)begin //reset gia tri ve 0
			dataout<=7'd0;
		end
		else if(load==1'b0)begin //load gia tri count vao thanh ghi
			dataout<=count;
		end
		else begin 
				if(dataout==1'b0)begin //Neu count dem ve 0 thi set lai gia tri ban dau
					dataout<=count;
				end
				else
				dataout<=dataout-1; //Count dem xuong
			end

	end
	

endmodule
