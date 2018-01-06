module display_setSecond (input key, clk, up_down, enable, input [6:0] max_second,
								  output [6:0] hex0 , hex1,
								  output reg [6:0] count,
								  
								  input enableIR,					//enableIR lay ra tu IRled
								  input clkIR,						//clock cho ir receive
								  input resetIR,					//reset cho ir receive
								  input IRDA_RXD,					//input IR
								  input [2:0] IRled,				//trang thai den hien tai cua khoi dieu khien IR
								  output reg [2:0] IRled_out,	//trang thai den sau khi nhan nut tranferlight tren remote
								  input start,						//=0 dung de su dung tranferlight
								  input mode						// = 0 dung key va sw, = 1 dung remote
								  );	


initial count = 7'd30;
//in ra led 7seg================================================================
display_to_2Led7seg x(.enable(enable), .count(count), .hex0(hex0), .hex1(hex1));
//==============================================================================

//KHOI DIEU IR=======================================================================================

//=======================================================
//  REG/WIRE declarations
//=======================================================
wire  data_ready;        //IR data_ready flag
//reg   data_read;         //read 
wire  [31:0] hex_data;   //seg data input
//wire  clk50;             //pll 50M output for irda

//=======================================================
//  Structural coding
//=======================================================
IR_RECEIVE u1(
					///clk 50MHz////
					.iCLK(clkIR), 
					//reset          
					.iRST_n(resetIR),        
					//IRDA code input
					.iIRDA(IRDA_RXD), 
					//read command      
					//.iREAD(data_read),
					//data ready      					
					.oDATA_READY(data_ready),
					//decoded data 32bit
					.oDATA(hex_data)        
					);
					

//===================================================================================================
reg count_enough;  // = 0 khi chua co so nao nhap truoc do
//===================================================
reg [6:0] count_tmp;
always@(negedge data_ready)begin
	if(enableIR == 1) begin
		case(hex_data[23:16])
				8'h00: if(count_enough == 0) begin 
								count_tmp <= 7'd0;
								count_enough <= 1'b1;
						 end
						 else if(count_enough == 1) begin
							count_tmp <= count_tmp * 10;
							count_enough <= 1'b0; 	
						 end
				8'h01: if(count_enough == 0) begin 
								count_tmp <= 7'd1;
								count_enough <= 1'b1;
						 end
						 else begin
							count_tmp <= count_tmp * 10 + 1;
							count_enough <= 1'b0;
						 end

				8'h02: if(count_enough == 0) begin 
								count_tmp <= 7'd2;
								count_enough <= 1'b1;
						 end
						 else begin
							count_tmp <= count_tmp * 10 + 2;
							count_enough <= 1'b0;
						 end

				8'h03: if(count_enough == 0) begin 
								count_tmp <= 7'd3;
								count_enough <= 1'b1;
						 end
						 else begin
							count_tmp <= count_tmp * 10 + 3;
							count_enough <= 1'b0;
						 end

				8'h04: if(count_enough == 0) begin 
								count_tmp <= 7'd4;
								count_enough <= 1'b1;
						 end
						 else begin
							count_tmp <= count_tmp * 10 + 4;
							count_enough <= 1'b0;
						 end

				8'h05: if(count_enough == 0) begin 
								count_tmp <= 7'd5;
								count_enough <= 1'b1;
						 end
						 else begin
							count_tmp <= count_tmp * 10 + 5;
							count_enough <= 1'b0;
						 end

				8'h06: if(count_enough == 0) begin 
								count_tmp <= 7'd6;
								count_enough <= 1'b1;
						 end
						 else begin
							count_tmp <= count_tmp * 10 + 6;
							count_enough <= 1'b0;
						 end

				8'h07: if(count_enough == 0) begin 
								count_tmp <= 7'd7;
								count_enough <= 1'b1;
						 end
						 else begin
							count_tmp <= count_tmp * 10 + 7;
							count_enough <= 1'b0;
						 end

				8'h08: if(count_enough == 0) begin 
								count_tmp <= 7'd8;
								count_enough <= 1'b1;
						 end
						 else begin
							count_tmp <= count_tmp * 10 + 8;
							count_enough <= 1'b0;
						 end

				8'h09: if(count_enough == 0) begin 
								count_tmp <= 7'd9;
								count_enough <= 1'b1;
						 end
						 else begin
							count_tmp <= count_tmp * 10 + 9;
							count_enough <= 1'b0;
						 end

				8'h1B: begin 
							if (count_tmp < max_second) 	count_tmp <= count_tmp + 1;
							else 						 			count_tmp <= 7'b0;
							if (count_tmp > 7'd9)         count_enough <= 1'b0;
							else 					    		   count_enough <= count_enough;
						 end
				8'h1F: begin 
							if (count_tmp > 0) 				count_tmp <= count_tmp - 1;
							else 						 			count_tmp <= max_second;
							if (count_tmp > 7'd9)       	count_enough <= 1'b0;
							else 					   	 		count_enough <= count_enough;
						 end
				default:begin
							count_tmp <= count_tmp;
							count_enough <= count_enough;
							IRled_out <= IRled_out;
						  end
				endcase
	end
	else count_tmp <= count_tmp;
end

//===================================================

always @(posedge clk) begin		// chinh dong ho dung kich canh dung key dong bo

	if(mode == 1'b1) begin
		if (enableIR == 1) begin
			count <= count_tmp;
		end
		else count <= count;
	end
	else begin
		if(up_down) begin 											//up_down = 1: dem len, 0: dem xuong
			if((key == 0) && (count < max_second)) 		  count <= count + 1;
			else if((key == 0) && (count == max_second))   count <= 7'd0;
			else if(count > max_second)						  count <= max_second;
			else 												  		  count <= count;
		end
		else begin
			if((key == 0) && (count > 7'd0)) 		 		  count <= count - 1;
			else if((key == 0) && (count == 7'd0))   	  	  count <= max_second;
			else if(count > max_second)						  count <= max_second;
			else														  count <= count;
		end
	end // end else (!data_ready)
end 





/*always @(key) begin					//chinh key dong ho dung key kich muc: fail
	if(!key) begin
		if((up_down == 1) && (count < max_second))     		count = count + 1;
		else if((up_down == 1) && (count == max_second))	count = 7'd0;
		else if((up_down == 0) && (count > 7'd0))				count = count - 1;
		else if((up_down == 0) && (count == 7'd0))			count = max_second;
		else																count = max_second;
	end
	else begin
		if(count > max_second)										count = max_second;
		else 																count = count;
	end													  				count = count;
end
*/

/*
always @(posedge clk, negedge key ) begin			// chinh dong ho kich canh dung key bat dong bo: fail
if(!key) begin    
		if((up_down == 1) && (count < max_second))     		count <= count + 1;
		else if((up_down == 1) && (count == max_second))	count <= 7'd0;
		else if((up_down == 0) && (count > 7'd0))				count <= count - 1;
		else if((up_down == 0) && (count == 7'd0))			count <= max_second;
		else																count <= max_second;
	end
	else begin
		if(count > max_second)										count <= max_second;
		else 																count = count;
	end

end
*/			
endmodule 