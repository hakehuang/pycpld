`timescale	1ns/1ps
//**********************************************************************
// File: i2c_slave_lpc8_polling.v
// Module:i2c_slave_lpc8_polling
// by Robin zhang 
//**********************************************************************
module i2c_slave_lpc8_polling(
	reset_n,
	sda,
	scl,
	clock,
	ip_select
	);
	
input		reset_n;	//extern signal
input		scl;
inout		sda;	
input		clock;		//intern signal
input    ip_select;
    
wire sda_en;
wire sda_in;
wire sda_out;
    
assign  sda_in = (!sda_en) ? sda  : 1'bz;
assign	sda    = sda_en ? sda_out : 1'bz;

reg [7:0] clk_count;
reg bus_clk;
always@(posedge clock)begin
	if(clk_count ==3)begin
		bus_clk <= ~bus_clk;
		clk_count <= 'h0;
	end
	else
		clk_count <= clk_count + 1'b1;
end

i2c_slave_op_lpc8_polling	i2c_slave_op_lpc8_polling_inst(
			.reset_n(reset_n),
			.clock(bus_clk),
			.sda_out(sda_out),
			.sda_in(sda_in),
			.sda_en(sda_en),
			.scl(scl),
         .ip_select(ip_select)            );
	
endmodule