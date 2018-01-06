module IR_controller(input enableIR,     	// tao ra dieu kien khi moi loai den sang truyen vao bien enable cho tung module IR
//							input [2:0] light_state_IR_controll,  //den hien tai ma ir dieu khien
							input start,				//start = 0 nhan tranfer light
							input CLOCK_50,
							input IRDA_RXD,			//input IR
							inout reg [2:0] light_state_real, //trang thai that cua den
							input resetIR,				//reset IR SW[4]
							input [6:0] max_second,
							output reg [6:0] countIR_out);
							

					

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
					.iCLK(CLOCK_50), 
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
					
//=======================================================
reg count_enough;  // = 0 khi chua co so nao nhap truoc do
//===============================================================================================

always@(negedge data_ready)begin 
	if(enableIR) begin
			case(hex_data[23:16])
			8'h00: if(count_enough == 0) begin 
							countIR_out <= 7'd0;
							count_enough <= 1'b1;
					 end
					 else begin
						countIR_out <= countIR_out * 10;
						count_enough <= 1'b0;
					 end

			8'h01: if(count_enough == 0) begin 
							countIR_out <= 7'd1;
							count_enough <= 1'b1;
					 end
					 else begin
						countIR_out <= countIR_out * 10 + 1;
						count_enough <= 1'b0;
					 end

			8'h02: if(count_enough == 0) begin 
							countIR_out <= 7'd2;
							count_enough <= 1'b1;
					 end
					 else begin
						countIR_out <= countIR_out * 10 + 2;
						count_enough <= 1'b0;
					 end

			8'h03: if(count_enough == 0) begin 
							countIR_out <= 7'd3;
							count_enough <= 1'b1;
					 end
					 else begin
						countIR_out <= countIR_out * 10 + 3;
						count_enough <= 1'b0;
					 end

			8'h04: if(count_enough == 0) begin 
							countIR_out <= 7'd4;
							count_enough <= 1'b1;
					 end
					 else begin
						countIR_out <= countIR_out * 10 + 4;
						count_enough <= 1'b0;
					 end

			8'h05: if(count_enough == 0) begin 
							countIR_out <= 7'd5;
							count_enough <= 1'b1;
					 end
					 else begin
						countIR_out <= countIR_out * 10 + 5;
						count_enough <= 1'b0;
					 end

			8'h06: if(count_enough == 0) begin 
							countIR_out <= 7'd6;
							count_enough <= 1'b1;
					 end
					 else begin
						countIR_out <= countIR_out * 10 + 6;
						count_enough <= 1'b0;
					 end

			8'h07: if(count_enough == 0) begin 
							countIR_out <= 7'd7;
							count_enough <= 1'b1;
					 end
					 else begin
						countIR_out <= countIR_out * 10 + 7;
						count_enough <= 1'b0;
					 end

			8'h08: if(count_enough == 0) begin 
							countIR_out <= 7'd8;
							count_enough <= 1'b1;
					 end
					 else begin
						countIR_out <= countIR_out * 10 + 8;
						count_enough <= 1'b0;
					 end

			8'h09: if(count_enough == 0) begin 
							countIR_out <= 7'd9;
							count_enough <= 1'b1;
					 end
					 else begin
						countIR_out <= countIR_out * 10 + 9;
						count_enough <= 1'b0;
					 end

			8'h1B: if (countIR_out < max_second) countIR_out <= countIR_out + 1;
					 else 								 countIR_out <= 7'b0;
//					 if (countIR_out > 7'd9)       count_enough <= 1'b0;
//					 else 								 count_enough <= count_enough;
			8'h1F: if (countIR_out > 0) 			 countIR_out <= countIR_out - 1;
					 else 								 countIR_out <= max_second;
//					 if (countIR_out > 7'd9)       count_enough <= 1'b0;
//					 else 								 count_enough <= count_enough;
					
			8'h1A: if(start == 0) light_state_real <= light_state_real << 1;
					 else light_state_real <= light_state_real;

			8'h1E: if(start == 0) light_state_real <= light_state_real >> 1;
					 else light_state_real <= light_state_real;
			default:begin
						countIR_out <= countIR_out;
						count_enough <= count_enough;
						light_state_real <= light_state_real;
					  end
			endcase
		
	end
	else begin 
		countIR_out <= countIR_out;
	end
end				
							
endmodule 