module	LCD_TEST (		//	Host Side
					iCLK,		//iRST_N, //count,
					color, count,start,enable,
					//	LCD Side
					LCD_DATA,LCD_RW,LCD_EN,LCD_RS	);
//	Host Side
input			iCLK;//iRST_N;
input [6:0] count;
input [2:0] color;
input start,enable;
//input [6:0] count;
//input [2:0] color;
///// 

//	LCD Side
output	[7:0]	LCD_DATA;
output			LCD_RW,LCD_EN,LCD_RS;
//	Internal Wires/Registers
wire  [8:0] count_n,count_d;
//////
wire	[8:0] char1,char2,char3,char4,char5,char6;
////////
reg	[5:0]	LUT_INDEX;
reg	[8:0]	LUT_DATA;
reg	[5:0]	mLCD_ST;
reg	[17:0]	mDLY;
reg			mLCD_Start;
reg	[7:0]	mLCD_DATA;
reg			mLCD_RS;
wire		mLCD_Done;
wire clk_out;



parameter	LCD_INTIAL	=	0;
parameter	LCD_LINE1	=	5;
parameter	LCD_CH_LINE	=	LCD_LINE1+16;
parameter	LCD_LINE2	=	LCD_LINE1+16+1;
parameter	LUT_SIZE	=	LCD_LINE1+32+1;


div_to_1 clock_out(.CLOCK_50(iCLK),.clk_out(clk_out));
count_down_1 ex1(.count(count),.enable(enable),.number1(count_n),.number2(count_d));

count_down_2 ex2(.color(color),.char1(char1),.char2(char2),.char3(char3),.char4(char4),.char5(char5),.char6(char6));
//change change_1(.count(count),.count_n(count_n),.count_d(count_d));

always@(posedge iCLK /*or negedge clk_out*/)
begin
	if(!1)
	begin
		LUT_INDEX	<=	0;
		mLCD_ST		<=	0;
		mDLY			<=	0;
		mLCD_Start	<=	0;
		mLCD_DATA	<=	0;
		mLCD_RS		<=	0;
	end
	else
	begin
		if(LUT_INDEX<LUT_SIZE)
		begin
			case(mLCD_ST)
			0:	begin
					mLCD_DATA	<=	LUT_DATA[7:0];
					mLCD_RS		<=	LUT_DATA[8];
					mLCD_Start	<=	1;
					mLCD_ST		<=	1;
				end
			1:	begin
					if(mLCD_Done)
					begin
						mLCD_Start	<=	0;
						mLCD_ST		<=	2;					
					end
				end
			2:	begin
					if(mDLY<18'h3FFFE)
					mDLY	<=	mDLY+1;
					else
					begin
						mDLY	<=	0;
						mLCD_ST	<=	3;
						
					end
				end
			3:	begin
					LUT_INDEX	<=	LUT_INDEX+1;
					mLCD_ST	<=	0;
				end
			endcase
		end
		else LUT_INDEX<=LCD_LINE1;
	end
end

always
begin
	case(LUT_INDEX)
	//	Initial
	LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
	LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
	LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
	LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
	LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
	//	Line 1
	LCD_LINE1+0:	LUT_DATA	<=	9'h120;	//	Welcome to the
	LCD_LINE1+1:	LUT_DATA	<=	9'h143;
	LCD_LINE1+2:	LUT_DATA	<=	9'h14F;
	LCD_LINE1+3:	LUT_DATA	<=	9'h14C;
	LCD_LINE1+4:	LUT_DATA	<=	9'h14F;
	LCD_LINE1+5:	LUT_DATA	<=	9'h152;
	LCD_LINE1+6:	LUT_DATA	<=	9'h120;
	LCD_LINE1+7:	LUT_DATA	<=	9'h120;
	LCD_LINE1+8:	LUT_DATA	<=	9'h120;
	LCD_LINE1+9:	LUT_DATA	<=	9'h120;
	LCD_LINE1+10:	LUT_DATA	<=	9'h120;
	LCD_LINE1+11:	LUT_DATA	<=	9'h120;
	LCD_LINE1+12:	LUT_DATA	<=	9'h154;
	LCD_LINE1+13:	LUT_DATA	<=	9'h149;
	LCD_LINE1+14:	LUT_DATA	<=	9'h14D;
	LCD_LINE1+15:	LUT_DATA	<=	9'h145;
	//	Change Line
	LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
	//	Line 2
	LCD_LINE2+0:	LUT_DATA	<=	9'h120;	//	Terasic DE2i-150 T
	LCD_LINE2+1:	LUT_DATA	<=	char1;	// e
	LCD_LINE2+2:	LUT_DATA	<=	char2;  // r
	LCD_LINE2+3:	LUT_DATA	<=	char3;  // a
	LCD_LINE2+4:	LUT_DATA	<=	char4;  // s
	LCD_LINE2+5:	LUT_DATA	<=	char5; // i
	LCD_LINE2+6:	LUT_DATA	<=	char6;  // c
	LCD_LINE2+7:	LUT_DATA	<=	9'h120;  // 
	LCD_LINE2+8:	LUT_DATA	<=	9'h120;  // D
	LCD_LINE2+9:	LUT_DATA	<=	9'h120;  // E
	LCD_LINE2+10:	LUT_DATA	<=	9'h120;  // 2
	LCD_LINE2+11:	LUT_DATA	<=	9'h120;  // i
	LCD_LINE2+12:	LUT_DATA	<=	9'h120;  // -
	LCD_LINE2+13:	LUT_DATA	<=	count_n;  // 1
	LCD_LINE2+14:	LUT_DATA	<=	count_d;  // 5
	LCD_LINE2+15:	LUT_DATA	<=	9'h120;  // 0
	default:		LUT_DATA	<=	9'h120;
	endcase
end

LCD_Controller 		u0	(	//	Host Side
							.iDATA(mLCD_DATA),
							.iRS(mLCD_RS),
							.iStart(mLCD_Start),
							.oDone(mLCD_Done),
							.iCLK(iCLK),
							.start(start),
							//.iRST_N(iRST_N),
							//	LCD Interface
							.LCD_DATA(LCD_DATA),
							.LCD_RW(LCD_RW),
							.LCD_EN(LCD_EN),
							.LCD_RS(LCD_RS)	);

endmodule