module main_trafficLight (output [6:0] hex0, hex1, output reg [2:0] led,	//so giay dem xuong 00, den tung mau sang
								  output [6:0] hex_xanh1, hex_xanh0,			
											hex_do1  , hex_do0,				//hien so giay cai dat cua moi mau den
											hex_vang1, hex_vang0,
								  output [7:0] LCD_DATA,
								  output LCD_RW, LCD_RS, LCD_EN,
								  input [2:0] setSecond,					//tang giam so giay cho tung mau den
								  input up_down, 								//de gan vao reg truyen vao dieu khien den khi co tin hieu load
								  input tranferLight,						//nhan key chuyen mau den khi start == 0
								  input start, load, reset,				//start == 0 dong ho dung tu doi mau bang tranferLight
																					//load == 1 nhan thong tin so giay cua cac mau
																					//reset == 1 den chuyen ve mau vang
								  input CLOCK_50,								//xung clock 50Mhz		
								  input resetIR,								//sw[4] reset ir
								  input IRDA_RXD,								//tin hieu remote
								  output reg [2:0] IRled,					//trang thai cua khoi ir
								  input mode, 									//= 0 dung key va sw, = 1 dung remote
								  output data_ready
								  );
								  
parameter max_xanh = 99,
		    max_do = 99,
			 max_vang = 4;
wire clk_out;
wire clk_scale;
wire [6:0] count_xanh, count_do, count_vang;							//xanh:0, vang:1, do:2


//hien giay tren cot den=========================================================================
reg [6:0] count;	
reg enable;
display_to_2Led7seg mainLight(.enable(enable), .count(count), .hex0(hex0), .hex1(hex1));
//===============================================================================================

div_to_1 #(.scale(5000000))c0(.CLOCK_50(CLOCK_50), .clk_out(clk_scale)); //tao xung clk 0.2s de chinh giay cho cac den		
div_to_1 clock_out(.CLOCK_50(CLOCK_50),.clk_out(clk_out));		//tao xung clk 1s	

//display to LCD=================================================================================

LCD_TEST lcd1(.enable(enable),.iCLK(CLOCK_50),.color(led),.start(start),.count(count),.LCD_DATA(LCD_DATA),.LCD_EN(LCD_EN),.LCD_RW(LCD_RW),.LCD_RS(LCD_RS));
//set thoi gian cac den hien ra led7seg==========================================================
wire [2:0] IRled_out_xanh, 
			  IRled_out_do, 
			  IRled_out_vang; 
wire enableIR_xanh,
	  enableIR_vang,
	  enableIR_do;
assign enableIR_xanh = IRled[2];
assign enableIR_vang = IRled[1];
assign enableIR_do   = IRled[0];

display_setSecond gr(.enable(1'b1),
							.key(setSecond[2]), .clk(clk_scale), .up_down(up_down), 
							.max_second(max_xanh), 
							.hex0(hex_xanh0), .hex1(hex_xanh1), 
							.count(count_xanh),
							//IR=============
							.enableIR(enableIR_xanh),
							.clkIR(CLOCK_50),
							.resetIR(resetIR),
							.IRDA_RXD(IRDA_RXD),
							.IRled(IRled),
							.IRled_out(IRled_out_xanh),
							.mode(mode)
							);
						
display_setSecond yel(.enable(1'b1),
							.key(setSecond[1]), .clk(clk_scale), .up_down(up_down), 
							.max_second(max_vang), 
							.hex0(hex_vang0), .hex1(hex_vang1), 
							.count(count_vang),
							//IR=============
							.enableIR(enableIR_vang),
							.clkIR(CLOCK_50),
							.resetIR(resetIR),
							.IRDA_RXD(IRDA_RXD),
							.IRled(IRled),
							.IRled_out(IRled_out_vang),
							.mode(mode)
							);
							
display_setSecond red(.enable(1'b1),
							.key(setSecond[0]), .clk(clk_scale), .up_down(up_down), 
							.max_second(max_do), 
							.hex0(hex_do0), .hex1(hex_do1), 
							.count(count_do),
							//IR=============
							.enableIR(enableIR_do),
							.clkIR(CLOCK_50),
							.resetIR(resetIR),
							.IRDA_RXD(IRDA_RXD),
							.IRled(IRled),
							.IRled_out(IRled_out_do),
							.mode(mode)
							);

//KHOI DIEU IR=======================================================================================


//=======================================================
//  REG/WIRE declarations
//=======================================================
//wire  data_ready;        //IR data_ready flag
//reg   data_read;         //read 
wire  [31:0] hex_data;   //seg data input
wire  clk50;             //pll 50M output for irda

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
//===================================================================================================

//khoi dieu khien chinh (count)
reg [2:0] led_tmp;
reg [2:0] IRled_tmp;
always@(negedge data_ready) begin
	if(start ==0) begin
		case(hex_data[23:16])
		8'h1A: 	if		 (led == 3'b100) led_tmp <= 3'b001;
					else if(led == 3'b010) led_tmp <= 3'b100;
					else if(led == 3'b001) led_tmp <= 3'b010;
					else    					  led_tmp <= 3'b010;
		8'h1E: 	if		 (led == 3'b100) led_tmp <= 3'b010;
					else if(led == 3'b010) led_tmp <= 3'b001;
					else if(led == 3'b001) led_tmp <= 3'b100;
					else    					  led_tmp <= 3'b010;
		default: led_tmp <= led;
		endcase
	end
	else begin
			case(hex_data[23:16])
		8'h1A: 	if		 (IRled == 3'b100) IRled_tmp <= 3'b001;
					else if(IRled == 3'b010) IRled_tmp <= 3'b100;
					else if(IRled == 3'b001) IRled_tmp <= 3'b010;
					else 							 IRled_tmp <= 3'b010;
		8'h1E: 	if		 (IRled == 3'b100) IRled_tmp <= 3'b010;
					else if(IRled == 3'b010) IRled_tmp <= 3'b001;
					else if(IRled == 3'b001) IRled_tmp <= 3'b100;
					else 							 IRled_tmp <= 3'b010;
		default: IRled_tmp <= IRled;
		endcase
	end
end

always @(posedge clk_out) begin 	//xanh:vang:do ~ led[2:0] 2 1 0
		if (mode == 1) begin
			if (start == 1) IRled <= IRled_tmp;
			else IRled <= IRled;
		end
		else IRled <= IRled;
		
		if(reset == 1) begin							//reset == 1 2 leg7 tat, bat den vang 
			enable <= 1'b0;
			count <= count_vang;
			led <= {1'b0,!led[1],1'b0};
		end
		
		else begin 										//reset == 0
			if(start == 0) begin 					//start == 0
				enable <= 1'b0;
				if(mode == 0) begin
					if(led == 3'b000) led <= 3'b010;
					else led <= led;
					if(!tranferLight) begin			//nhan tranferLight
						case(led)
							3'b100: led <= 3'b010;
							3'b010: led <= 3'b001;
							3'b001: led <= 3'b100;
							default: led <= 3'b010;
						endcase
					end
					else led <= led;					//tranferLight == 1
				end
				else begin
					led <= led_tmp;
				end
			end
			else begin									//reset = 0, start == 1
				enable <= 1'b1;
				
				if(load == 1) begin  				//reset = 0, start == 1, load == 1
					if(led == 3'b100) 	  count <= count_xanh;		//den dang xanh thi set lai den xanh
					else if(led == 3'b010) begin
							if(count_vang <= max_vang) count <= count_vang;
							else count <= max_vang;
					end
					else if(led == 3'b001) count <= count_do;
					else count <= count_vang;
				end
				else begin								// reset = 0, start = 1, load = 0
					if(count > 0) begin
						if(|led == 0) led <= 3'b010;
						else led <= led;
						if		 ((led == 3'b100) && (count > count_xanh)) 	count <= count_xanh;
						else if((led == 3'b010) && (count > count_vang)) 	count <= count_vang;
						else if((led == 3'b001) && (count > count_do))		count <= count_do;
						else count <= count - 1;
					end
					else begin 
						case(led)
							3'b100: begin 
											led   <= 3'b010;
											count <= count_vang;
									  end
									  
							3'b010: begin
											led   <= 3'b001;
											count <= count_do;
									  end
									  
							3'b001:  begin
											led   <= 3'b100;
											count <= count_xanh;
									  end
									  
							default: begin
											count <= count;
											led   <= 3'b010;
										end
						endcase
					end
				end
			end
		end
end

endmodule 




