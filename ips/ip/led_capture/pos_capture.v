`timescale 1ns/1ps
/***************************************************************************
Name:
Date: 7/11/2016
Founction: pwm rising edge capture
Note:
****************************************************************************/
module pos_capture(
led_input,clk,rst_n,pos_btn
);

input led_input;
input clk;
input rst_n;
output pos_btn;

reg btn1;
reg btn2;


/*******************************************************************************
*capture led_input rising edge
*********************************************************************************/
always @(posedge clk or negedge rst_n) begin 
  if(!rst_n) begin
    btn1 <= 1'b1;
    btn2 <= 1'b1;
   end
  else begin
	 btn1 <=led_input;
	 btn2 <= btn1;    
	end
end

assign pos_btn = btn1& ~btn2;

endmodule 