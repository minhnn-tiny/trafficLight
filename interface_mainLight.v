module interface_mainLight(output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
									output [6:0] LEDR,	
								   input [3:0] KEY,					
								   input [5:0] SW,
									input CLOCK_50,
									output [7:0] LCD_DATA,
									output LCD_RW, LCD_RS, LCD_EN,
									input IRDA_RXD
								  );
								  
main_trafficLight m0(.hex0(HEX6),      .hex1(HEX7),      .led(LEDR[2:0]),
							.hex_xanh1(HEX5), .hex_xanh0(HEX4),			
							.hex_do1(HEX1),   .hex_do0(HEX0),
							.hex_vang1(HEX3), .hex_vang0(HEX2),
							.setSecond(KEY[3:1]),
							.up_down(SW[3]),
							.tranferLight(KEY[0]),
							.start(SW[1]),
							.load(SW[2]),
							.reset(SW[0]),
							//input LCD
							.LCD_DATA(LCD_DATA),
							.LCD_RW(LCD_RW),
							.LCD_RS(LCD_RS),
							.LCD_EN(LCD_EN),
							//=========
							.CLOCK_50(CLOCK_50),
							//IR block
							.resetIR(SW[4]),
							.IRDA_RXD(IRDA_RXD),
							.IRled(LEDR[5:3]),
							//=========
							.mode(SW[5]),
							.data_ready(LEDR[6])
							);	  
						
endmodule 