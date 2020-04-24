`timescale 1ns/1ps

/***************************************************************************
Name:
Date: 7/18/2016
Founction: I2C top module
Note:
****************************************************************************/
module I2C_MASTER_reduced(clk,rst_n,sda,scl,RD_EN,WR_EN,receive_status
);

input clk;
input rst_n;
input RD_EN;
input WR_EN;
reg WR,RD;


output scl;
output receive_status;

inout sda;

wire scl_wire;
wire scl;

wire[7:0] data;

reg[7:0] data_reg;

reg read_status_reg;
reg write_status_reg;

wire receive_status;


wire [3:0]	main_state;
wire 	[4:0] i2c_state;

wire sda_en;
wire sda_in;
wire sda_out;
    
assign  sda_in = (!sda_en) ? sda : 1'bz;
assign  sda    = sda_en ? ((sda_out == 1'b1)? 1'bz:1'b0) : 1'bz;

assign scl = scl_wire ? 1'bz: 1'b0;


wire scl_fallingedge;

//----------------- i2c statemachine -------------------------------
//i2c data in big endian mode

parameter   data_7   		= 4'h0;
parameter   data_0   		= 4'h7;
parameter   data_act   		= 4'h8;

//----------------- main statemachine ------------------------------
parameter idle_status                =4'h0;
parameter start_status               =4'h1;
parameter address_status             =4'h2;
parameter read_status                =4'h3;
parameter write_status	             =4'h4;
parameter stop_status                =4'h5;

always @(posedge clk or negedge rst_n)
	begin
	if(!rst_n)begin	
		WR         <= 1'b0;
		RD         <= 1'b0;
		data_reg   <= 'h0;
		read_status_reg <= 1'b0;
		write_status_reg <= 1'b0;
	end
	else 
		begin
			if(RD_EN)
				begin
					if (main_state == read_status)
						begin
						    //try read more bits to fix the issue in i2c speed
							if (data_reg == 'h20 && i2c_state == data_7 && scl_fallingedge)
								begin
							//stop after read 32 data
									RD <= 1'b0;
									read_status_reg <= 1'b1;
								end
							else
								begin
									if (scl_fallingedge && i2c_state == data_0)
										data_reg <= data_reg + 1;
								end
						end
					else if (main_state == idle_status)
						begin
							if (~read_status_reg)
								begin
									RD	<= 1'b1;
									WR <= 1'b0;
									data_reg <= 'h0;
								end
							else
								begin
								//read all data done stop here only reset can recovery
									RD <= 1'b0;
									WR <= 1'b0;
									data_reg <= 'h0;
								end
						end
					else
						data_reg <= 'h0;
				end
			else if(WR_EN)
				begin
					if (main_state == write_status)
						begin
							if (data_reg == 'h20 && i2c_state == data_7 && scl_fallingedge)
								begin
								//stop after send 32 data
									WR <= 1'b0;
									write_status_reg <= 1'b1;
								end
							else
								begin
									if (scl_fallingedge && i2c_state == data_0)
										data_reg <= data_reg + 1;
								end
						end
					else if (main_state == idle_status)
						begin
							if (~write_status_reg)
								begin
									RD	<= 1'b0;
									WR <= 1'b1;
									data_reg <= 'h0;
								end
							else
								begin
									RD	<= 1'b0;
									WR <= 1'b0;
									data_reg <= 'h0;							
								end
						end
					else
						data_reg <= 'h0;
				end
			else
				begin
						RD	<= 1'b0;
						WR <= 1'b0;
						data_reg <= 'h0;
						write_status_reg <= 1'b0;
						read_status_reg <= 1'b0;
				end
	

	  end
end

assign data = WR_EN ? data_reg :  8'hz;

I2C_wr_reduced I2C_wr_reduced_instance(
					.sda_in(sda_in),
					.sda_out(sda_out),
					.sda_en(sda_en),
					.scl(scl_wire),
					.reset_n(rst_n),
					.clock(clk),
					.WR(WR),
					.RD(RD),
					.data(data),
					.scl_fallingedge(scl_fallingedge),
					.main_state(main_state),
					.i2c_state(i2c_state),
					.debug(receive_status)
);

endmodule
