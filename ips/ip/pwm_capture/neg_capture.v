`timescale 1ns/1ps
/***************************************************************************
Name:
Date: 7/11/2016
Founction: pwm falling edge capture
Note:
****************************************************************************/
module neg_capture(
pwm_input,clk,rst_n,enable,neg_btn
);

input pwm_input;
input clk;
input rst_n;
input enable;
output neg_btn;

reg btn1;
reg btn2;


/*******************************************************************************
*capture pwm_input falling edge
*********************************************************************************/
always @(posedge clk or negedge rst_n)begin
  if(!rst_n) begin
    btn1 <= 1'b0;
    btn2 <= 1'b0;
   end
  else if(enable) begin
	btn1 <=pwm_input;
	btn2 <= btn1;    
	end
end

assign neg_btn = ~btn1& btn2;

endmodule 