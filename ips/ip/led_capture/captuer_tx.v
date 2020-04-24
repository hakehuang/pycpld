`timescale 1ns/1ps
/***************************************************************************
Name:
Date: 7/11/2016
Founction: Send out capture value
Note:
****************************************************************************/
module captuer_tx( 
clk,rst_n,tx_start,capture_ready,periodcounter,tx_data,counter,led_input
);

input clk;
input rst_n;
input capture_ready;
input [31:0] counter;
input led_input;

input[31:0] periodcounter;

output tx_start;

output [7:0] tx_data;

reg tx_start;
reg[7:0] tx_data;


always @ (posedge clk or negedge rst_n) begin

	if (!rst_n)begin
		tx_start <= 1'b1;
      tx_data <= 'hzz;
	end
	else if(capture_ready)begin
		tx_start <= 1'b0;
		tx_data <= (periodcounter >= 'd100000000) ? "S"
						:((periodcounter < 'd100000000) && (periodcounter >= 'd10000000)) ? "F"
						:((periodcounter < 'd10000000) && (periodcounter >= 'd5000000)) ? "H"
						:(periodcounter < 'd5000000) ? "E" : 'hzz;
	end
	else if(counter > 'd300000000)begin
		tx_start <= 1'b0;
		tx_data <= led_input ? "M" : "L";
	end

end 
endmodule 