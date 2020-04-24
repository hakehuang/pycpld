`timescale	1ns/1ps
//**********************************************************************
// File: i2c_slave.v
// Module:i2c_slave
// by Robin zhang 
//**********************************************************************
module	i2c_slave_op_reduced(
		reset_n,
		clock,
		sda_out,
		sda_in,
		sda_en,
		scl,
		led		
		);
		
input		clock;   
input		reset_n;
input		sda_in;
input		scl;

output led;
wire led;


output 	sda_en;
reg		sda_en_r;


output 	sda_out;
reg		sda_out_r;

wire sda_risingedge;
wire scl_risingedge;

wire scl_fallingedge;
wire sda_fallingedge;
reg   ack_status;
reg   read_write_reg;
reg  [7:0] data_reg;

reg	[3:0]	main_state;
reg 	[4:0] i2c_state;

reg   addressed;


/*******************************************************************************
*detect the rising edge and falling edge of scl & sda
*******************************************************************************/
reg [1:0] scl_reg;
always@(posedge clock)
begin
	if(!reset_n) begin
		scl_reg <= 2'b11;
	end
	else begin
		scl_reg[0]<= scl;
		scl_reg[1]<= scl_reg[0];
	end
end
//Raising edge
assign scl_risingedge = (scl_reg == 1'b01) ? 1'b1 : 1'b0;

//failing edge
assign scl_fallingedge = (scl_reg == 8'b10) ? 1'b1 : 1'b0;

assign sda_out = sda_out_r;
assign sda_en = sda_en_r;


reg sda_last_r;
always@(posedge clock)
begin
	if(!reset_n)
		sda_last_r <= 1'b1;
	else
		sda_last_r <= sda_in;
end

//Raising edge
assign sda_risingedge = (~sda_last_r) & sda_in;

//failing edge
assign sda_fallingedge = sda_last_r & (~sda_in);


wire start_bus_wire;
wire stop_bus_wire;
assign start_bus_wire = sda_en ? start_bus_wire : (sda_fallingedge & scl);
assign stop_bus_wire = sda_en ? stop_bus_wire  : (sda_risingedge & scl);  


assign led = scl;

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
parameter address_status				 =4'h1;
parameter read_status                =4'h2;
parameter write_status	             =4'h3;



//------------------------------------------------------------------	
//main state machine
// this state machine assume below transactions
// i2c maser  start|send address;  w | 	 | send data |     | ... |     | stop |
// i2c slave       |        	       | ack |           | ack |     | ack |      | idle |
// i2c maser  start|send address;  r | 	 |				 | ack |  	 | ack | stop |
// i2c slave       |        	       | ack | send data |  	 | ... |     |      | idle |
wire [3:0]	main_state_wire;
assign main_state_wire = (main_state==idle_status) ?  (start_bus_wire ? address_status : idle_status) : 
								 (main_state==address_status) ? ((addressed && read_write_reg) ? write_status : ((addressed && ~read_write_reg)? read_status : address_status)):
								 (main_state==read_status) ? (stop_bus_wire ? idle_status : start_bus_wire ?  address_status : (data_reg == 'h20) ? idle_status : read_status) :
								 (main_state==write_status) ? (start_bus_wire ? address_status : stop_bus_wire ? idle_status : write_status) :idle_status;
								 
always @(posedge clock or negedge reset_n)begin
	if(!reset_n)
		begin
			main_state <= idle_status;
		end
	else
		begin
			main_state <= ((start_bus_wire || stop_bus_wire) && (main_state!=idle_status)) ? idle_status : main_state;
			main_state <= main_state_wire;					 
		end 
end
//------------------------------------------------------------------			
//i2c state machine
always @(posedge clock or negedge reset_n) //addr ack output
begin
	if(!reset_n)
	begin
		//not acked
		ack_status 		<= 1'b0;
		sda_en_r    		<= 1'b0;
		read_write_reg	<= 1'b1;
		i2c_state <= data_7;
		data_reg <= 8'b0;
		addressed <= 1'b0;
		sda_out_r <= 1'b1;
	end
	else
	begin
		//not acked
		ack_status 		<= (start_bus_wire || stop_bus_wire) ? 1'b0 : ack_status;
		// read mode
		sda_en_r    	<= (start_bus_wire || stop_bus_wire) ? 1'b0 : sda_en_r;
		read_write_reg	<= (start_bus_wire || stop_bus_wire) ? 1'b0 : read_write_reg;
		i2c_state <= (start_bus_wire || stop_bus_wire) ? data_7 : i2c_state;
		data_reg <=  (start_bus_wire || stop_bus_wire) ? 5'b0 : data_reg;
		addressed <= (start_bus_wire || stop_bus_wire) ? 1'b0 : addressed;
		if (main_state == read_status || main_state == write_status || main_state == address_status)
		begin
				case(i2c_state)
				data_7:
					begin
						i2c_state <= (((main_state== write_status)||(main_state==address_status)) && scl_fallingedge) ? data_7 : scl_risingedge ? data_6 : i2c_state;
						sda_en_r  <= (((main_state== write_status)||(main_state==address_status)) && scl_fallingedge) ? 1'b0 : (main_state==read_status && scl_fallingedge) ? 1'b1 : sda_en_r;
						addressed <= (((main_state== write_status)||(main_state==read_status)) && scl_fallingedge)? 1'b0 : addressed;
						sda_out_r <= (main_state==read_status && scl_fallingedge) ? data_reg[7] : sda_out_r;
					end
				data_6:
					begin
						sda_en_r  <= (main_state==read_status  && scl_fallingedge) ? 1'b1 : sda_en_r;
						sda_out_r <= (main_state==read_status  && scl_fallingedge) ? data_reg[6] : sda_out_r;
						if((main_state==write_status || main_state==address_status)  && scl_fallingedge) //to ack chip address  
							begin
								//for slaver, nothing to do
								i2c_state <= data_6;
							end
						else if(scl_risingedge)
							begin
								i2c_state      <= data_5;
							end
					end
				data_5:
					begin
						i2c_state <= (((main_state== write_status)||(main_state==address_status)) && scl_fallingedge) ? data_5 : scl_risingedge ? data_4 : i2c_state;
						sda_en_r  <= (main_state==read_status  && scl_fallingedge) ? 1'b1 : sda_en_r;
						sda_out_r <= (main_state==read_status  && scl_fallingedge) ? data_reg[5] : sda_out_r;
					end
				data_4:
					begin
						i2c_state <= (((main_state== write_status)||(main_state==address_status)) && scl_fallingedge) ? data_4 : scl_risingedge ? data_3 : i2c_state;
						sda_en_r  <= (main_state==read_status  && scl_fallingedge) ? 1'b1 : sda_en_r;
						sda_out_r <= (main_state==read_status  && scl_fallingedge) ? data_reg[4] : sda_out_r;
					end
				data_3:
					begin
						i2c_state <= (((main_state== write_status)||(main_state==address_status)) && scl_fallingedge) ? data_3 : scl_risingedge ? data_2 : i2c_state;
						sda_en_r  <= (main_state==read_status  && scl_fallingedge) ? 1'b1 : sda_en_r;
						sda_out_r <= (main_state==read_status  && scl_fallingedge) ? data_reg[3] : sda_out_r;
					end
				data_2:
					begin
						i2c_state <= (((main_state== write_status)||(main_state==address_status)) && scl_fallingedge) ? data_2 : scl_risingedge ? data_1 : i2c_state;
						sda_en_r  <= (main_state==read_status  && scl_fallingedge) ? 1'b1 : sda_en_r;
						sda_out_r <= (main_state==read_status  && scl_fallingedge) ? data_reg[2] : sda_out_r;
					end
				data_1:
					begin
						i2c_state <= (((main_state== write_status)||(main_state==address_status)) && scl_fallingedge) ? data_1 : scl_risingedge ? data_0 : i2c_state;
						sda_en_r  <= (main_state==read_status  && scl_fallingedge) ? 1'b1 : sda_en_r;
						sda_out_r <= (main_state==read_status  && scl_fallingedge) ? data_reg[1] : sda_out_r;
					end
				data_0:
					begin
						i2c_state <= (((main_state== write_status)||(main_state==address_status)) && scl_fallingedge) ? data_0 : scl_risingedge ? data_act : i2c_state;
						sda_en_r  <= (main_state==read_status  && scl_fallingedge) ? 1'b1 : sda_en_r;
						sda_out_r <= (main_state==read_status  && scl_fallingedge) ? data_reg[0] : sda_out_r;
						read_write_reg <= (scl_risingedge && (main_state==address_status)) ? (~sda_in) : read_write_reg;
					end
				data_act:
					begin
						sda_en_r <= (((main_state== write_status)||(main_state==address_status)) && scl_fallingedge) ? 1'b1 : (main_state== read_status && scl_fallingedge) ? 1'b0 : sda_en_r;
						sda_out_r <= (((main_state== write_status)||(main_state==address_status)) && scl_fallingedge) ? 1'b0 : sda_out_r;
						ack_status <= (((main_state== write_status)||(main_state==address_status)) && scl_fallingedge) ? 1'b1 : (scl_risingedge && main_state == read_status) ? (~sda_in) : ack_status;
						addressed <= (main_state==address_status && scl_fallingedge) ? 1'b1 : addressed;
						data_reg <= (main_state== read_status && scl_fallingedge) ? data_reg + 1 : data_reg;
						i2c_state      <= scl_risingedge ? data_7 : i2c_state;
					end
				default:	i2c_state <= i2c_state;   
				endcase
		end
		else
			begin
				//not acked
				ack_status 		<= 1'b0;
				// read mode
				sda_en_r    		<= 1'b0;
				read_write_reg	<= 1'b1;
				i2c_state <= data_7;
				data_reg <= 8'b0;
				addressed <= 1'b0;
			end
	end
 end

endmodule

