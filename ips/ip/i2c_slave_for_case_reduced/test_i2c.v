`timescale	1ns/1ps

module i2c_simple(reset_n,
		clock,
		sda_in,
		scl);

input		clock;   
input		reset_n;
input		sda_in;
input		scl;


reg		start_bus_reg;
reg		stop_bus_reg;
wire sda_risingedge;
wire scl_risingedge;
wire sda_failingedge;
wire scl_fallingedge;

reg curr, last;
always@(posedge clock)
begin
	if(!reset_n) begin
		curr <= 1'b0;
		last <= 1'b0;
	end
	else begin
    curr <= scl;
    last <= curr;
	end
end
//Raising edge
assign scl_risingedge = curr & (~last);

//failing edge
assign scl_fallingedge = ~curr & (last);

reg sda_curr, sda_last;
always@(posedge clock)
begin
	if(!reset_n) begin
		sda_curr <= 1'b0;
		sda_last <= 1'b0;
	end
	else begin
    sda_curr <= sda_in;
    sda_last <= sda_curr;
	end
end

//Raising edge
assign sda_risingedge = sda_curr & (~sda_last);

//failing edge
assign sda_fallingedge = ~sda_curr & (sda_last);


// ----------------------------------------------------------------
// to test start condition: scl=1, sda_in failing
always@(posedge clock)
begin
  start_bus_reg <= sda_fallingedge & scl;
  stop_bus_reg <= sda_risingedge & scl;
end

endmodule

/* 
 * Do not change Module name 
*/
module test_i2c;

reg reset_n;
reg clock;
reg sda_in;
wire sda_out;
wire sda_en;
reg scl;

wire debug;


integer i;

/*
i2c_simple i2c_simple(.reset_n(reset_n),
		.clock(clock),
		.sda_in(sda),
		.scl(scl));
*/
		
i2c_slave_op_reduced	i2c_slave_op_reduced_inst(
			.reset_n(reset_n),
			.clock(clock),
			.sda_out(sda_out),
			.sda_in(sda_in),
			.sda_en(sda_en),
			.scl(scl),
			.led(debug)
         );

  initial 
    begin
	    clock = 0;
		 scl = 0;
		 sda_in = 0;
		//reset
		#50 reset_n = 1;
		#50 reset_n = 0;
		#50 reset_n = 1;

      //idle
      #50 scl = 1;
      #50 sda_in = 1;
      //start
      #20 sda_in = 0;
      #10 scl = 0;
		
		//abnormal testing
      #50 scl = 1;
      #50 sda_in = 1;
      //start
      #200 sda_in = 0;
      #100 scl = 0;
		//100K HZ means 10000ns one cuycle 
		//send address
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 2
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 3
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 4
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 5
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 6
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 7
			#500 sda_in = 0;
			#500 scl = 1;
			#500 scl = 0;
			//bit r/w
			#500 sda_in = 0;
			#500 scl = 1;
			#500 scl = 0;
		   //bit ack
			#500 sda_in = 0;
			#500 scl = 1;
			#500 scl = 0;
			
		for (i=0; i< 32; i=i+1) begin
			//bit 1
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 2
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 3
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 4
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 5
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 6
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 7
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 8
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit ack
			//#10 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
		end
		
		//repeat start
      #50 scl = 1;
      #50 sda_in = 1;
      //start
      #100 sda_in = 0;
      #100 scl = 0;
		
		//send address
		#500 sda_in = 1;
		#500 scl = 1;
		#500 scl = 0;
		//bit 2
		#500 sda_in = 1;
		#500 scl = 1;
		#500 scl = 0;
		//bit 3
		#500 sda_in = 1;
		#500 scl = 1;
		#500 scl = 0;
		//bit 4
		#500 sda_in = 1;
		#500 scl = 1;
		#500 scl = 0;
		//bit 5
		#500 sda_in = 1;
		#500 scl = 1;
		#500 scl = 0;
		//bit 6
		#500 sda_in = 1;
		#500 scl = 1;
		#500 scl = 0;
		//bit 7
		#500 sda_in = 0;
		#500 scl = 1;
		#500 scl = 0;
		//bit r
		#500 sda_in = 1;
		#500 scl = 1;
		#500 scl = 0;
		//bit ack
		#500 sda_in = 0;
		#500 scl = 1;
		#500 scl = 0;
	
		for (i=0; i< 32; i=i+1) begin
			//bit 1
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 2
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 3
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 4
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 5
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 6
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 7
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit 8
			#500 sda_in = 1;
			#500 scl = 1;
			#500 scl = 0;
			//bit ack
			#500 sda_in = 0;
			#500 scl = 1;
			#500 scl = 0;
		end
      
		
		//stop condition
      #100 sda_in = 0;
      #100 scl = 1;
		#100 sda_in = 1;

      
    end
always begin
	 //50M HZ about 20ns one cycle
    #10 clock = ! clock;
end
endmodule