`timescale 1ns / 1ps
//**********************************************************************
// File: button_isp.v
// Module:button_isp
// by Robin zhang 
//**********************************************************************
module button_isp(
 rst,clk,outpin_isp,outpin_rst
);

input rst;
input clk;

output outpin_isp;
output outpin_rst;

reg outpin_isp;
reg outpin_rst;
reg [31:0] counter;

//timer 
always@(posedge clk or negedge rst)begin
	if(!rst)
		counter <= 'h0;
	else
		counter <= (counter < 32'hFFFFFFFF) ? (counter + 1'b1) : 'h0;
end

//press down ips first
always@(posedge clk or negedge rst)begin
	if(!rst)
		outpin_isp <= 1'bz;
	else
		outpin_isp <= (counter < 'd3500000) ? 1'b0 : 1'b1;
end

//press rst button
always@(posedge clk or negedge rst)begin
	if(!rst)
		outpin_rst <= 1'bz;
	else
		outpin_rst <= ((counter > 'd1500000) && (counter < 'd3000000)) ? 1'b0 : 1'b1;
end
endmodule 