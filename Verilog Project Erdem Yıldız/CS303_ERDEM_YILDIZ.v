`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:42:01 12/17/2019 
// Design Name: 
// Module Name:    CS303_ERDEM_YILDIZ 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module atm (input clk,
                     input rst,
                     input BTN3, BTN2, BTN1,
                     input [3:0] SW,
                     output reg [7:0] LED,                                     // LED[7] is the left most-LED
                     output reg [6:0] digit4, digit3, digit2, digit1  // digit4 is the left-most SSD
                    );
  
	 reg [3:0] password;
    reg [15:0] balance; 
	 reg [7:0] current_state;
	 reg [7:0] next_state;	
	 reg [6:0] counter;
		
	 parameter IDLE = 4'b0000, PASS_ENT_3 = 4'b0001, PASS_ENT_2 = 4'b0010, PASS_ENT_1 = 4'b0011, LOCK = 4'b0100, ATM_MENU = 4'b0101, 
	 PASS_CHG_3 = 4'b1000, PASS_CHG_2 = 4'b1001, PASS_CHG_1 = 4'b1010, PASS_NEW = 4'b1011, MONEY = 4'b0110, WARNING = 4'b0111;
	 

	

	// combinational part - next state definitions
	always @ (*)
	begin
		case (current_state)
			IDLE:
				if(BTN3) 
					next_state = PASS_ENT_3;
				else 
					next_state = current_state;
			PASS_ENT_3: 
				if(BTN3  && SW == password)
					next_state = ATM_MENU;
				else if(BTN3 && SW != password)
					next_state = PASS_ENT_2;
				else if(BTN1)
					next_state = IDLE;	
				else 
					next_state = current_state;
			PASS_ENT_2: 
				if(BTN3 && SW == password)
					next_state = ATM_MENU;
				else if(BTN3 && SW != password)
					next_state = PASS_ENT_1;
				else if (BTN1)
					next_state = IDLE;
				else 
					next_state = current_state;
			PASS_ENT_1: 
				if (BTN3 && SW == password)
					next_state = ATM_MENU;
				else if (BTN3 && SW != password)
					next_state = LOCK;
				else if (BTN1)
					next_state = IDLE;
				else 
					next_state = current_state;
			LOCK:
				if(counter == 100)
					next_state = IDLE;
				else if(counter< 100)
					next_state = LOCK;
				else
					next_state = LOCK;
			ATM_MENU:
				if (BTN3)
					next_state = MONEY;
				else if (BTN2)
					next_state = PASS_CHG_3; 
				else if (BTN1)
					next_state = IDLE;
				else 
					next_state = current_state;
			PASS_CHG_3:
				if (BTN3 && SW == password)
					next_state = PASS_NEW;
				else if (BTN3 && SW != password)
					next_state = PASS_CHG_2;
				else if (BTN1)
					next_state = ATM_MENU;
				else
					next_state = current_state;
			PASS_CHG_2:
				if (BTN3 && SW == password)
					next_state = PASS_NEW;
				else if (BTN3 && SW != password)
					next_state = PASS_CHG_1;
				else if (BTN1)
					next_state = ATM_MENU;
				else
					next_state = current_state;
			PASS_CHG_1:
				if (BTN3 && SW == password)
					next_state = PASS_NEW;
				else if (BTN1)
					next_state = ATM_MENU;
				else if (BTN3 && SW != password)
					next_state = LOCK;
				else 
					next_state = current_state;
				
			PASS_NEW:
				if (BTN3)
				 begin 
					next_state = ATM_MENU;
				 end
				else 
					next_state = PASS_NEW;
			MONEY:
				if (BTN3)
				begin
					next_state = MONEY;
				end
				else if (BTN2)
					if (balance < SW)
						next_state = WARNING;
					else
						next_state = MONEY;
				else if (BTN1)
					next_state = ATM_MENU;
				else
					next_state = current_state;
			WARNING:
				if(counter ==50)
					next_state = MONEY;
				else if(counter< 50)
					next_state = WARNING;
				else 
					next_state = WARNING;
		endcase
	end
	
	always @(posedge clk or posedge rst)
		begin
		if(rst)
			current_state <= IDLE;
		else
			current_state <= next_state;
		end
		
		always @ (posedge clk or posedge rst)
		begin 	                                 //sequential part
			if(rst)
			begin 
				password <= 4'b0000;
				balance <= 0;
			end
			else
			begin
			case(current_state)
			
			IDLE:
				if(BTN3) 
					begin
					counter<=0;
					password<= password;
					end
				else
					begin
					counter <= 0;
					password<=password;
					end
			
			
			MONEY:
			
				if(BTN2==1'b1)
					begin
						counter <= 0;
						if (balance < SW)
							balance <= balance;
						else
							balance <= balance - SW;
					end
				else if(BTN3 == 1'b1)	
					begin
						balance <= balance + SW;
						counter<= 0;
					end
			
			
			PASS_NEW:
			if(BTN3 == 1'b1)
					password <= SW;
					
			LOCK:
				if(counter< 100)			
				counter <= counter+1;
				else
				counter <= 0;

			WARNING:
				if(counter < 50)
				counter <= counter+1;
				else
				counter <= 0;
							
		endcase
		end
	end

always @(posedge clk or posedge rst)
    begin
	 if(rst)
	 begin
		LED <= 0;
		digit4 <=0;
		digit3 <=0;
		digit2 <=0;
		digit1 <=0;
	end
	else
        case(current_state)
         IDLE:
			begin
             LED <= 8'b0000001;
             digit4 <= 7'b0110001;
             digit3 <= 7'b0001000;
             digit2 <= 7'b1111010;
             digit1 <= 7'b1000010;
         end
         PASS_ENT_3:
         begin
             LED <= 8'b10000000;
             digit4 <= 7'b0011000;
             digit3 <= 7'b0110000;
             digit2 <= 7'b1111110;
             digit1 <= 7'b0000110;
         end
         PASS_ENT_2:
         begin
             LED <= 8'b11000000;
             digit4 <= 7'b0011000;
             digit3 <= 7'b0110000;
             digit2 <= 7'b1111110;
             digit1 <= 7'b0010010;
         end
         PASS_ENT_1:
         begin
             LED <= 8'b11100000;
             digit4 <= 7'b0011000;
             digit3 <= 7'b0110000;
             digit2 <= 7'b1111110;
             digit1 <= 7'b1001111;
         end
         LOCK:
         begin
             LED <= 8'b11111111;
             digit4 <= 7'b0111000;
             digit3 <= 7'b0001000;
             digit2 <= 7'b1001111;
             digit1 <= 7'b1110001;
         end
         ATM_MENU:
         begin
             LED <= 8'b00010000;
             digit4 <= 7'b0000001;
             digit3 <= 7'b0011000;
             digit2 <= 7'b0110000;
             digit1 <= 7'b1101010;
         end
         PASS_CHG_3:
         begin
             LED <= 8'b00000100;
             digit4 <= 7'b0011000;
             digit3 <= 7'b0110001;
             digit2 <= 7'b1111110;
             digit1 <= 7'b0000110;
         end
         PASS_CHG_2:
         begin
             LED <= 8'b00000110;
             digit4 <= 7'b0011000;
             digit3 <= 7'b0110001;
             digit2 <= 7'b1111110;
             digit1 <= 7'b0010010;
         end
         PASS_CHG_1:
         begin
             LED <= 8'b00000111;
             digit4 <= 7'b0011000;
             digit3 <= 7'b0110001;
             digit2 <= 7'b1111110;
             digit1 <= 7'b1001111;
         end
         PASS_NEW:
         begin
             LED <= 8'b00000010;
             digit4 <= 7'b0011000;
             digit3 <= 7'b0001000;
             digit2 <= 7'b0100100;
             digit1 <= 7'b0100100;
         end
         MONEY:
         begin
             LED <= 8'b00001000;
               if(balance[3:0] == 4'b1111)
                  digit1 <= 7'b0111000; //F
               else if(balance[3:0] == 4'b1110)
                  digit1 <= 7'b0110000; //E
               else if(balance[3:0] == 4'b1101)
                  digit1 <= 7'b0000001; //D //0
               else if(balance[3:0] == 4'b1100)
                  digit1 <= 7'b0110001; //C
               else if(balance[3:0] == 4'b1011)
                  digit1 <= 7'b0000000;  //B //8
               else if(balance[3:0] == 4'b1010)
                  digit1 <= 7'b0001000;    //A
               else if(balance[3:0] == 4'b1001)
                  digit1 <= 7'b0000100;    //9
               else if(balance[3:0] == 4'b1000)
                  digit1 <= 7'b0000000;   //8
               else if(balance[3:0] == 4'b0111)
                  digit1 <= 7'b0001101;   //7
               else if(balance[3:0] == 4'b0110)
                  digit1 <= 7'b0100000;    //6
               else if(balance[3:0] == 4'b0101)
                  digit1 <= 7'b0100100;   //5
               else if(balance[3:0] == 4'b0100)
                  digit1 <= 7'b1001100;   //4
               else if(balance[3:0] == 4'b0011)
                  digit1 <= 7'b0000110;   //3
               else if(balance[3:0] == 4'b0010)
                  digit1 <= 7'b0010010;   //2
               else if(balance[3:0] == 4'b0001)
                  digit1 <= 7'b1001111;  //1
               else 
                  digit1 <= 7'b0000001;  //0
						
               if(balance[7:4] == 4'b1111)
                  digit2 <= 7'b0111000; //F
               else if(balance[7:4] == 4'b1110)
                  digit2 <= 7'b0110000; //E
               else if(balance[7:4] == 4'b1101)
                  digit2 <= 7'b0000001; //D //0
               else if(balance[7:4] == 4'b1100)
                  digit2 <= 7'b0110001; //C
               else if(balance[7:4] == 4'b1011)
                  digit2 <= 7'b0000000;  //B //8
               else if(balance[7:4] == 4'b1010)
                  digit2 <= 7'b0001000;    //A
               else if(balance[7:4] == 4'b1001)
                  digit2 <= 7'b0000100;    //9
               else if(balance[7:4] == 4'b1000)
                  digit2 <= 7'b0000000;   //8
               else if(balance[7:4] == 4'b0111)
                  digit2 <= 7'b0001101;   //7
               else if(balance[7:4] == 4'b0110)
                  digit2 <= 7'b0100000;    //6
               else if(balance[7:4] == 4'b0101)
                  digit2 <= 7'b0100100;   //5
               else if(balance[7:4] == 4'b0100)
                  digit2 <= 7'b1001100;   //4
               else if(balance[7:4] == 4'b0011)
                  digit2 <= 7'b0000110;   //3
               else if(balance[7:4] == 4'b0010)
                  digit2 <= 7'b0010010;   //2
               else if(balance[7:4] == 4'b0001)
                  digit2 <= 7'b1001111;  //1
               else 
                  digit2 <= 7'b0000001;  //0
 
               if(balance[11:8] == 4'b1111)
                  digit3 <= 7'b0111000; //F
               else if(balance[11:8] == 4'b1110)
                  digit3 <= 7'b0110000; //E
               else if(balance[11:8] == 4'b1101)
                  digit3 <= 7'b0000001; //D //0
               else if(balance[11:8] == 4'b1100)
                  digit3 <= 7'b0110001; //C
               else if(balance[11:8] == 4'b1011)
                  digit3 <= 7'b0000000;  //B //8
               else if(balance[11:8] == 4'b1010)
                  digit3 <= 7'b0001000;    //A
               else if(balance[11:8] == 4'b1001)
                  digit3 <= 7'b0000100;    //9
               else if(balance[11:8] == 4'b1000)
                  digit3 <= 7'b0000000;   //8
               else if(balance[11:8] == 4'b0111)
                  digit3 <= 7'b0001101;   //7
               else if(balance[11:8] == 4'b0110)
                  digit3 <= 7'b0100000;    //6
               else if(balance[11:8] == 4'b0101)
                  digit3 <= 7'b0100100;   //5
               else if(balance[11:8] == 4'b0100)
                  digit3 <= 7'b1001100;   //4
               else if(balance[11:8] == 4'b0011)
                  digit3 <= 7'b0000110;   //3
               else if(balance[11:8] == 4'b0010)
                  digit3 <= 7'b0010010;   //2
               else if(balance[11:8] == 4'b0001)
                  digit3 <= 7'b1001111;  //1
               else 
                  digit3 <= 7'b0000001;  //0
                                   
               if(balance[15:12] == 4'b1111)
                  digit4 <= 7'b0111000; //F
               else if(balance[15:12] == 4'b1110)
                  digit4 <= 7'b0110000; //E
               else if(balance[15:12] == 4'b1101)
                  digit4 <= 7'b0000001; //D //0
               else if(balance[15:12] == 4'b1100)
                  digit4 <= 7'b0110001; //C
               else if(balance[15:12] == 4'b1011)
                  digit4 <= 7'b0000000;  //B //8
               else if(balance[15:12] == 4'b1010)
                  digit4 <= 7'b0001000;    //A
               else if(balance[15:12] == 4'b1001)
                  digit4 <= 7'b0000100;    //9
               else if(balance[15:12] == 4'b1000)
                  digit4 <= 7'b0000000;   //8
               else if(balance[15:12] == 4'b0111)
                  digit4 <= 7'b0001101;   //7
               else if(balance[15:12] == 4'b0110)
                  digit4 <= 7'b0100000;    //6
               else if(balance[15:12] == 4'b0101)
                  digit4 <= 7'b0100100;   //5
               else if(balance[15:12] == 4'b0100)
                  digit4 <= 7'b1001100;   //4
               else if(balance[15:12] == 4'b0011)
                  digit4 <= 7'b0000110;   //3
               else if(balance[15:12] == 4'b0010)
                  digit4 <= 7'b0010010;   //2
               else if(balance[15:12] == 4'b0001)
                  digit4 <= 7'b1001111;  //1
               else 
                  digit4 <= 7'b0000001;  //0                                 
          end
          WARNING:
             begin
             LED <= 8'b11111111;
             digit4 <= 7'b1111110;
             digit3 <= 7'b1101010;
             digit2 <= 7'b0001000;
             digit1 <= 7'b1111110;
             end
    endcase
end

	

endmodule


