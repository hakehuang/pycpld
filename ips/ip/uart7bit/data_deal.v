`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:55:21 05/03/2016 
// Design Name: 
// Module Name:    data_deal 
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
module data_deal(
	clk,
	rst_n,
	data_in,
	data_in_sign,
	
	data_out,
	data_out_sign,
	data_valid,
	data_ok
    );
	
	
	
	input 	clk;
	input 	rst_n;
	input 	[6:0]	data_in;
	input 	data_in_sign;
	
	output	[6:0]	data_out;
	output	data_out_sign;
	input 	data_valid;
	output	data_ok;
	
	
	
	reg		[6:0]	data_reg;
	reg				data_ok;
	
	reg		[6:0]	data_out;
	reg				data_out_sign;
	reg				data_in_sign_reg;
	
	
	always @(posedge  clk or negedge rst_n)begin
		if(!rst_n)begin
			data_reg <= 7'h0;
			data_ok <= 1'h0;
			data_in_sign_reg <= 1'b0;
		end
		else begin	
			data_in_sign_reg <= data_in_sign;
			data_reg <= data_in_sign ? data_reg + 1'b1 : data_reg;
			data_ok <= data_in_sign_reg ? &(data_reg ~^ data_in) : data_ok;
		end
	end
	
	
	always @(posedge  clk or negedge rst_n)begin
		if(!rst_n)begin
			data_out_sign <= 1'b0;
			data_out <= 'h0;
		end
		else begin	
			if(~data_out_sign & data_valid)		data_out_sign <= 1'b1;
			else 								data_out_sign <= 1'b0;
			data_out <= ~data_out_sign & data_valid ? data_out + 1'b1 : data_out;
		end
	end
	


endmodule
