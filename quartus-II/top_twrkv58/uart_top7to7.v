`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:46:43 05/03/2016 
// Design Name: 
// Module Name:    uart_top1 
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
module uart_top7to7(
	clk,
	rst_n,
	rs232_rx,
	rs232_tx,

	data_ok,
	
   uart_ctl
    );
	
input clk;			// 50mhz
input rst_n;
input rs232_rx;	// RS232 rec
input [2:0] uart_ctl;
output rs232_tx;	//	RS232 transfer
output data_ok;


////////////////

parameter		DELAY_N = 15;


wire		[2:0]	uart_ctl;


wire		[6:0]	data_in, data_out;

wire		data_in_sign, data_out_sign;

wire		data_valid;

reg			[DELAY_N - 1: 0]		rst_cnt;


wire		rst_wire ;

assign		rst_wire = rst_cnt[DELAY_N - 1];

always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			rst_cnt <= 'h0;
		end
		else begin	
			if(~rst_cnt[DELAY_N - 1])	rst_cnt <= rst_cnt + 1'b1;
			
		end
	end

my_uart_tx7to7 tx_inst (
    .clk(clk), 
    .rst_n(rst_wire), 
    .uart_ctl(uart_ctl), 
    .data_out(data_out), 
    .data_sign(data_out_sign), 
	 .data_valid(data_valid),
    .rs_tx(rs232_tx)
    );


 my_uart_rx7to7 rx_inst(
    .clk(clk), 
    .rst_n(rst_wire), 
    .uart_ctl(uart_ctl), 
    .rs_rx(rs232_rx), 
    .data_in(data_in), 
    .data_sign(data_in_sign)
    );
	
	
data_deal data_deal (
    .clk(clk), 
    .rst_n(rst_wire), 
    .data_in(data_in), 
    .data_in_sign(data_in_sign), 
    .data_out(data_out), 
    .data_out_sign(data_out_sign), 
    .data_valid(data_valid), 
    .data_ok(data_ok)
    );
endmodule