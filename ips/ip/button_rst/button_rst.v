`timescale 1ns / 1ps
//**********************************************************************
// File: button_rst.v
// Module:button_rst
// by Robin zhang 
//**********************************************************************
module button_rst(
 rst,clk,pull_done,out_status
);

input rst;
input clk;
input pull_done;

output out_status;
reg out_status;

always@(posedge clk or negedge rst)begin
	if(!rst)
		out_status <= 1'b1;
	else begin
		out_status <= pull_done ? 1'b0 : 1'b1;
	end
end


endmodule 