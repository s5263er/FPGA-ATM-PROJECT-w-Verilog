`timescale 1ns / 1ps

module top_module                  (clk, rst, 
                                    
									SW,
									LED, BTN3, BTN2, BTN1, digit1, digit2, digit3, digit4, a, b, c, d, e ,f ,g,an0,an1,an2,an3
							        );
	
	input clk, rst;	
	input BTN1, BTN2, BTN3;
	input [3:0] SW;
	
	
	
	
	output a,b,c,d,e,f,g,an0,an1,an2,an3;
	output [6:0] digit4, digit3, digit2, digit1;
	output [7:0] LED;
	
	wire divClk;
	
	wire BTN3_in;
	wire BTN2_in;
	wire BTN1_in;
	
	clk_divider clock_scaler (.clk_in(clk), .rst(rst), .divided_clk(divClk));
	
	debouncer 	input_filter (.clk(divClk), .rst(rst), .noisy_in(BTN3), .clean_out(BTN3_in));
	debouncer	input_filter1 (.clk(divClk), .rst(rst), .noisy_in(BTN2), .clean_out(BTN2_in));
	debouncer 	input_filter2 (.clk(divClk), .rst(rst), .noisy_in(BTN1), .clean_out(BTN1_in));
	
	
	
	ssd display        (.clk(clk), .reset(rst), 
	                    .a0(digit1[6]), .a1(digit2[6]), .a2(digit3[6]), .a3(digit4[6]),
							  .b0(digit1[5]), .b1(digit2[5]), .b2(digit3[5]), .b3(digit4[5]),
							  .c0(digit1[4]), .c1(digit2[4]), .c2(digit3[4]), .c3(digit4[4]),
							  .d0(digit1[3]), .d1(digit2[3]), .d2(digit3[3]), .d3(digit4[3]),
							  .e0(digit1[2]), .e1(digit2[2]), .e2(digit3[2]), .e3(digit4[2]),
							  .f0(digit1[1]), .f1(digit2[1]), .f2(digit3[1]), .f3(digit4[1]),
							  .g0(digit1[0]), .g1(digit2[0]), .g2(digit3[0]), .g3(digit4[0]),
							  .a(a),.b(b),.c(c),.d(d),.e(e),.f(f),.g(g),.an0(an0),.an1(an1),.an2(an2),.an3(an3)
							  
							  );
							  
	atm machine (.clk(divClk), .rst(rst), 			 
							         .LED(LED), .BTN3(BTN3_in),
										 .BTN2(BTN2_in), .BTN1(BTN1_in) ,.SW(SW), 
										 .digit1(digit1), .digit2(digit2), .digit3(digit3), .digit4(digit4)
							         );
endmodule
