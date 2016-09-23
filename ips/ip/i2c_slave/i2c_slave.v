`timescale	1ns/1ps
//**********************************************************************
// File: i2c_slave.v
// Module:i2c_slave
// by Robin zhang 
//**********************************************************************
module i2c_slave(
	reset_n,
	sda,
	scl,
	clock
	);
	
input		reset_n;	//extern signal
input		scl;
inout		sda;	
input		clock;		//intern signal

    
wire sda_en;
wire sda_in;
wire sda_out;
    
assign  sda_in = (!sda_en) ? sda  : 1'bz;
assign	sda    = sda_en ? sda_out : 1'bz;

i2c_slave_op	i2c_slave_op_inst(
			.reset_n(reset_n),
			.clock(clock),
			.sda_out(sda_out),
			.sda_in(sda_in),
			.sda_en(sda_en),
			.scl(scl)
                            );
	
endmodule