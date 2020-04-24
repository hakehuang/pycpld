`timescale	1ns/1ps
//**********************************************************************
// File: i2c_slave.v
// Module:i2c_slave
// by Robin zhang 
//**********************************************************************
module i2c_slave_reduced(
	reset_n,
	sda,
	scl,
	clock,
	led
	);
	
input		reset_n;	//extern signal
input		scl;
inout		sda;	
input		clock;		//intern signal

output led;

wire sda_en;
wire sda_in;
wire sda_out;


assign  sda_in = (!sda_en) ? sda  : 1'bz;
assign	sda    = sda_en ? ((sda_out == 1'b1)? 1'bz:1'b0) : 1'bz;

//reduce the 50M HZ clk to 5M HZ
reg [3:0] clk_count;
reg clk;
always @(posedge clock or negedge reset_n) begin
	if(!reset_n) begin
		clk_count <= 8'h0;
		clk <= 1'b0;
		end
	else begin 
		if(clk_count < 8'd10)
			clk_count <= clk_count + 1'b1;
		else begin
			clk_count <= 8'h0;
			clk <= ~clk;
		end
	end
end


i2c_slave_op_reduced	i2c_slave_op_reduced_inst(
			.reset_n(reset_n),
			.clock(clk),
			.sda_out(sda_out),
			.sda_in(sda_in),
			.sda_en(sda_en),
			.scl(scl),
			.led(led)
        );

endmodule