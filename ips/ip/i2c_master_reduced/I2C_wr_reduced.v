`timescale 1ns/1ps

/***************************************************************************
Name:
Date: 7/18/2016
Founction: I2C Write and read clock strench is not supported
Note:
****************************************************************************/
module I2C_wr_reduced(
sda_in, sda_out, sda_en, scl,ack_status,reset_n,clock,WR,RD,data, scl_fallingedge,main_state, i2c_state, debug
);

input			clock;
input [7:0] data;
input 		WR, RD;
input			sda_in;

input 		reset_n;

output 		sda_out;
output 		scl_fallingedge;
output      main_state;
output 		i2c_state;
output 		debug;
wire        debug;

output		scl;
reg 			scl;

output 		sda_en;
reg			sda_en;

output ack_status;
reg   ack_status;

reg	[3:0]	main_state;
reg 	[4:0] i2c_state;

reg 	[7:0] data_reg;

//----------------- i2c statemachine -------------------------------
//i2c data in big endian mode

parameter   data_7   		= 4'h0;
parameter   data_6   		= 4'h1;
parameter   data_5   		= 4'h2;
parameter   data_4   		= 4'h3;
parameter   data_3   		= 4'h4;
parameter   data_2   		= 4'h5;
parameter   data_1   		= 4'h6;
parameter   data_0   		= 4'h7;
parameter   data_act   		= 4'h8;

//----------------- main statemachine ------------------------------
parameter idle_status                =4'h0;
parameter start_status               =4'h1;
parameter address_status             =4'h2;
parameter read_status                =4'h3;
parameter write_status	             =4'h4;
parameter stop_status                =4'h5;
parameter delay_status               =4'h6;

`define clock_100K 'd250
`define clock_100K_delay (`clock_100K - 150)
`define clock_100K_delay_1 (`clock_100K - 10)
`define clock_100K_delay_2 (`clock_100K - 20)
`define delay_scls 'd14 

reg start_reg;
reg stop_reg;
reg control_phase;

wire scl_risingedge;
wire scl_fallingedge;

reg sda_w;
reg sda_c;

reg [6:0] addr_reg;
reg [7:0] delay_reg;
reg addressed;

reg control_flag;


assign sda_out = control_phase? sda_c : sda_w;

reg[7:0] clk_div;
always @(posedge clock or negedge reset_n)begin
	if(!reset_n)begin
		scl <= 1'bz;
		clk_div <= 'h0;
		end
	else 
		begin
			if (main_state != idle_status && main_state != stop_status)
				begin
					if ( main_state == delay_status)
						begin
							scl <= 1'b0;
							clk_div <= 'h0;
						end
					else if(clk_div > `clock_100K )
					begin
							scl <= ~scl;
							clk_div <= 'h0;
					end
					else
						clk_div <= clk_div + 1'b1;
				end
			else if (main_state == idle_status)
				scl <= 1'b1;
			else if (main_state == stop_status)
				if (delay_reg < `clock_100K && ~control_flag)
					scl <= 1'b0;
				else
					scl <= 1'b1;
				
		end
	
end


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

assign debug = sda_out;


//start/stop condition

always @(posedge clock or negedge reset_n)
begin
 	if(!reset_n)
		begin
			start_reg		<= 1'b0;
			control_flag	<= 1'b0;
			stop_reg			<= 1'b0;
			sda_c 			<= 1'b1;
		end
	else
		begin
			if (main_state == start_status)
				begin
					if(scl && (~control_flag) && (~scl_risingedge) && (~start_reg))
						begin

							if (delay_reg > `clock_100K_delay)
								begin
									control_flag <= 1'b1;
									//start condtions
									sda_c <= 1'b0;
								end
						end
					if ( ~scl && control_flag )
						begin
							start_reg 		<= 1'b1;
							control_flag 	<= 1'b0;
							sda_c 			<= 1'b1;
						end
				end
			else if (main_state == stop_status)
				begin
					if (~scl && ~control_flag && ~stop_reg)
						begin
							if (delay_reg > `clock_100K_delay_1)
								begin
									control_flag <= 1'b1;
									sda_c <= 1'b0;
								end
						end
					if (scl && control_flag && delay_reg == `clock_100K_delay_2)
						begin
							stop_reg <= 1'b1;
							//hold the control flag
							control_flag 	<= 1'b1;
							sda_c 			<= 1'b1;
						end
				end
			else if (main_state == address_status)
				begin
					start_reg <= 1'b0;
					sda_c 			<= 1'b0;
				end
			else if (main_state == idle_status)
				begin
					stop_reg <= 1'b0;
					sda_c 			<= 1'b1;
				end
			else
				begin
					start_reg		<= 1'b0;
					control_flag	<= 1'b0;
					stop_reg			<= 1'b0;
					sda_c 			<= 1'b0;
				end
		end
end

//------------------------------------------------------------------	
//main state machine
// this state machine assume below transactions
// i2c maser  start|send address;  w | 	 | send data |     | ... |     | stop |
// i2c slave       |        	       | ack |           | ack |     | ack |      | idle |
// i2c maser  start|send address;  r | 	 |				 | ack |  	 | ack | stop |
// i2c slave       |        	       | ack | send data |  	 | ... |     |      | idle |
always @(posedge clock or negedge reset_n)begin
	if(!reset_n)
		begin
			main_state <= idle_status;
			control_phase <= 1'b1;
			delay_reg <= 'h0;
			addr_reg <= 7'b1111110;
		end
	else
		begin
			case (main_state)
				idle_status:
					begin
						if(RD || WR)	//start read process
							begin
								main_state	<= start_status;
								control_phase <= 1'b1;
								addr_reg <= 7'b1111110;
							end
						else
							begin
								main_state	<= idle_status;
								control_phase <= 1'b0;
							end
					end
				start_status:
					begin
						if((RD || WR) && start_reg)	//start read process
							begin
								main_state	<= address_status;
								control_phase <= 1'b0;
								delay_reg <= 'h0;
							end
						else
							begin
								main_state	<= start_status;
								control_phase <= 1'b1;
								delay_reg <= delay_reg + 1'b1;
							end
					end
				address_status:
					begin
						if(ack_status && addressed && ~scl)	//start read process
							begin
								main_state	<= delay_status;
								addr_reg <= `delay_scls;//delay 7 cycle
							end
						else if (!ack_status)
							begin
								main_state	<= stop_status;
								control_phase <= 1'b1;
								delay_reg <= 'h0;
							end
					end
				delay_status:
					begin
						delay_reg <= delay_reg + 1;
						if (delay_reg > `clock_100K )
							begin
								addr_reg <= addr_reg - 1;
								delay_reg <= 0;
							end
						if(RD && addr_reg == 'd0)	//start read process
							begin
								main_state	<= read_status;
								delay_reg <= 'd0;
							end
						else if (WR && addr_reg == 'd0)
							begin
								main_state	<= write_status;
								delay_reg <= 'd0;
							end
					end
				read_status:	// read data from the master
				//in read mode, slave must ack to master
				begin
						if(RD)
							main_state	<= read_status;
						else if (WR)
							//repeat start
							main_state	<= start_status;
						else
							begin
								main_state	<= stop_status;
								control_phase <= 1'b1;
								delay_reg <= 'h0;
							end
				end
				write_status:	// read data from master
				//in write mode, master must ack to slaver
					begin
						if(WR && !ack_status)
							main_state	<= stop_status;
						else if (WR)
							main_state	<= write_status;
						else if (RD)
							//repeat start
							main_state	<= start_status;
						else
							begin
								main_state	<= stop_status;
								control_phase <= 1'b1;
								delay_reg <= 'h0;
							end
					end
				stop_status:
					begin
						if(stop_reg)
							begin
								main_state	<= idle_status;
								delay_reg <= 'h0;
							end
						else
							delay_reg <= delay_reg + 1'b1;
					end					
				default:	main_state <= idle_status;
			endcase					 
		end 
end


//------------------------------------------------------------------			
//i2c state machine
reg op_flag;
always @(posedge clock or negedge reset_n)
begin
	if(!reset_n)
	begin
		ack_status 		<= 1'b1;
		i2c_state <= data_7;
		sda_en <= 1'b0;
		sda_w <= 1'b1;
		addressed <= 1'b0;
		op_flag <= 1'b0;
	end
	else
	begin
		if (main_state == idle_status)
			begin
				data_reg <= data;
				sda_en 	<= 1'b1;
				sda_w <= 1'b1;
				ack_status 		<= 1'b1;
				i2c_state <= data_7;
				addressed <= 1'b0;
				op_flag <= 1'b0;
			end
		else if (main_state == address_status || main_state == read_status || 
		        main_state == write_status  || main_state == start_status || main_state == delay_status )
				begin
				case(i2c_state)
				data_7:
					begin
						if(scl_fallingedge)
							begin
							    op_flag <= 1'b1;
								if (main_state == start_status)
									begin
										//for master, set the data in read mode
										sda_w <= addr_reg[6];
										//addr_reg <= {addr_reg[5:0],addr_reg[6]};
										sda_en 		<= 1'b1;
										addressed <= 1'b0;
									end
								else if (main_state == read_status)
									begin
										sda_en <= 1'b0;
										//ack_status <= 1'b0;
									end
								else if (main_state == write_status)
									begin
										sda_en <= 1'b1;
										sda_w <= data_reg[7];
										//data_reg <= {data_reg[6:0], data_reg[7]};
										//ack_status <= 1'b0;
									end
								else if (main_state == delay_status )
									begin
										sda_en <= WR? 1'b1: 1'b0;
										sda_w <= WR?data_reg[7]: 1'b1;
									end
							end
						else if(scl_risingedge && op_flag)
							begin
									i2c_state   <= data_6;
									op_flag		<= 1'b0;
							end
					end
				data_6:
					begin
						if(scl_fallingedge)
							begin
								op_flag <= 1'b1;
								if (main_state == address_status)
									begin
										//for master, set the data in read mode
										sda_w <= addr_reg[5];
										//addr_reg <= {addr_reg[5:0],addr_reg[6]};
									end
								else if(main_state == read_status)
									begin
										//for read, do nothing
										i2c_state <= data_6;
									end
								else if (main_state == write_status)
									begin
										//for master, set the data in read mode
										sda_w <= data_reg[6];
										//data_reg <= {data_reg[6:0],data_reg[7]};
									end									
								
							end
						else if(scl_risingedge && op_flag)
							begin
									i2c_state      <= data_5;
									op_flag		<= 1'b0;
							end
					end
				data_5:
					begin
						if(scl_fallingedge)
							begin
								op_flag <= 1'b1;
								if (main_state == address_status)
									begin
										//for master, set the data in read mode
										i2c_state <= data_5;
										sda_w <= addr_reg[4];
										//addr_reg <= {addr_reg[5:0],addr_reg[6]};
									end
								else if(main_state == read_status)
									begin
										//for read, do nothing
										i2c_state <= data_5;
									end
								else if (main_state == write_status)
									begin
										//for master, set the data in read mode
										i2c_state <= data_5;
										sda_w <= data_reg[5];
										//data_reg <= {data_reg[6:0],data_reg[7]};
									end									
								
							end
						else if(scl_risingedge && op_flag)
							begin
									i2c_state      <= data_4;
									op_flag		<= 1'b0;
							end
					end
				data_4:
					begin
						if(scl_fallingedge)
							begin
								op_flag		<= 1'b1;
								if (main_state == address_status)
									begin
										//for master, set the data in read mode
										i2c_state <= data_4;
										sda_w <= addr_reg[3];
										//addr_reg <= {addr_reg[5:0],addr_reg[6]};
									end
								else if(main_state == read_status)
									begin
										//for read, do nothing
										i2c_state <= data_4;
									end
								else if (main_state == write_status)
									begin
										//for master, set the data in read mode
										i2c_state <= data_4;
										sda_w <= data_reg[4];
										//data_reg <= {data_reg[6:0],data_reg[7]};
									end									
								
							end
						else if(scl_risingedge && op_flag )
							begin
									i2c_state      <= data_3;
									op_flag		<= 1'b0;
							end
					end
				data_3:
					begin
						if(scl_fallingedge)
							begin
								op_flag		<= 1'b1;
								if (main_state == address_status)
									begin
										//for master, set the data in read mode
										i2c_state <= data_3;
										sda_w <= addr_reg[2];
										//addr_reg <= {addr_reg[5:0],addr_reg[6]};
									end
								else if(main_state == read_status)
									begin
										//for read, do nothing
										i2c_state <= data_3;
									end
								else if (main_state == write_status)
									begin
										//for master, set the data in read mode
										i2c_state <= data_3;
										sda_w <= data_reg[3];
										//data_reg <= {data_reg[6:0],data_reg[7]};
									end									
								
							end
						else if(scl_risingedge && op_flag)
							begin
									i2c_state      <= data_2;
									op_flag		<= 1'b0;
							end
					end
				data_2:
					begin
						if(scl_fallingedge)
							begin
								op_flag		<= 1'b1;
								if (main_state == address_status)
									begin
										//for master, set the data in read mode
										i2c_state <= data_2;
										sda_w <= addr_reg[1];
										//addr_reg <= {addr_reg[5:0],addr_reg[6]};
									end
								else if(main_state == read_status)
									begin
										//for read, do nothing
										i2c_state <= data_2;
									end
								else if (main_state == write_status)
									begin
										//for master, set the data in read mode
										i2c_state <= data_2;
										sda_w <= data_reg[2];
										//data_reg <= {data_reg[6:0],data_reg[7]};
									end									
								
							end
						else if(scl_risingedge && op_flag)
							begin
									i2c_state      <= data_1;
									op_flag		<= 1'b0;
							end
					end
				data_1:
					begin
						if(scl_fallingedge)
							begin
								op_flag		<= 1'b1;
								if (main_state == address_status)
									begin
										//for master, set the data in read mode
										i2c_state <= data_1;
										sda_w <= addr_reg[0];
										//addr_reg <= {addr_reg[5:0],addr_reg[6]};
									end
								else if(main_state == read_status)
									begin
										//for read, do nothing
										i2c_state <= data_1;
									end
								else if (main_state == write_status)
									begin
										//for master, set the data in read mode
										i2c_state <= data_1;
										sda_w <= data_reg[1];
										//data_reg <= {data_reg[6:0],data_reg[7]};
									end									
								
							end
						else if(scl_risingedge && op_flag)
							begin
									i2c_state      <= data_0;
									op_flag		<= 1'b0;
							end
					end
				data_0:
					begin
						if(scl_fallingedge)
							begin
								op_flag		<= 1'b1;
								if (main_state == address_status)
									begin
										//for master, set the data in read mode
										i2c_state <= data_0;
										sda_w <= ~WR;
									end
								else if(main_state == read_status)
									begin
										//for read
										i2c_state <= data_0;

									end
								else if (main_state == write_status)
									begin
										//for master, set the data in read mode
										i2c_state <= data_0;
										sda_w <= data_reg[0];
										//data_reg <= {data_reg[6:0],data_reg[7]};
									end									
								
							end
						else if(scl_risingedge && op_flag)
							begin
									i2c_state   <= data_act;
									op_flag		<= 1'b0;
							end
					end
				data_act:
					begin
						if(scl_risingedge && op_flag)
							begin
								op_flag		<= 1'b0;
								if (main_state == address_status)
									begin
										//for master, get ack
										ack_status 	<= 1'b1;//~sda_in;
										i2c_state   <= data_7;
										addressed   <= 1'b1;//~sda_in;
									end
								else if(main_state == read_status)
									begin
										//for read, send ack
										i2c_state   <= data_7;
										ack_status 	<= 1'b1;
									end
								else if (main_state == write_status)
									begin
										//for master, get ack
										i2c_state   <= data_7;
										//assume the act is ok
										ack_status 	<= ~sda_in;
									end									
								
							end
						else if(scl_fallingedge)
							begin
								op_flag <= 1'b1;
								data_reg <= data;
								if(main_state == read_status)
									begin
										//for read, send ack
										sda_w		<= 1'b0;
										sda_en 	<= 1'b1;
									end
								else 
									begin
										sda_en 		<= 1'b0;
									end
							end
					end
				default:	i2c_state <= i2c_state;
				endcase
		end
		else if (main_state == stop_status )
			begin
				sda_en 	<= 1'b1;
				sda_w		<= 1'b1;
			end
		else
			begin
				//not acked
				ack_status 		<= 1'b0;
				addressed		<= 1'b0;
				// read mode
				i2c_state <= data_7;
			end
	end
 end
 


endmodule


