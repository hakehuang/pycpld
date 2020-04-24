`timescale 1ns/1ps
/***************************************************************************
Name:
Date: 7/11/2016
Founction: Send out 'K'
Note:
****************************************************************************/
module press_done_tx( 
clk,rst_n,tx_start,press_done,tx_data
);

input clk;
input rst_n;
input press_done;

output tx_start;
output [7:0] tx_data;

reg tx_start;
reg[7:0] tx_data;

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)begin
		tx_start <= 1'b1;
      tx_data <= 'hzz;
	end
	else if(press_done)begin
		tx_start <= 1'b0;
		tx_data <= 8'h4b;
	end
	
end 

endmodule 