`timescale	1ns/1ps

/* 
 * Do not change Module name 
*/
module test_i2c_master;

reg rst_n;
reg clock;

wire sda_m_en;
wire sda_s_en;
wire scl;

wire sda_m;
wire sda_s;

wire sda_in;
wire sda_out;

wire[7:0] data;

reg[7:0] data_reg;

wire ack;


reg RD_EN;
reg WR_EN;
reg WR,RD;

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

assign	sda_m    = sda_m_en ? sda_out : 1'b1;
assign	sda_s    = sda_s_en ? sda_in : 1'b1;

wire  [3:0]	main_state;
wire 	[4:0] i2c_state;
wire  scl_fallingedge;

reg read_status_reg;
reg write_status_reg;

always @(posedge clock or negedge rst_n)
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
					.sda_en(sda_m_en),
					.scl(scl),
					.ack_status(ack),
					.reset_n(rst_n),
					.clock(clock),
					.WR(WR),
					.RD(RD),
					.data(data),
					.scl_fallingedge(scl_fallingedge),
					.main_state(main_state),
					.i2c_state(i2c_state)
);
	
 i2c_slave_op_reduced	i2c_slave_op_reduced_inst(
			.reset_n(rst_n),
			.clock(clock),
			.sda_out(sda_in),
			.sda_in(sda_out),
			.sda_en(sda_s_en),
			.scl(scl)
       );


  initial 
    begin
	   clock = 0;
		WR_EN = 0;
		RD_EN = 0;
		rst_n = 0;
		#50 rst_n = 1;

		#100 WR_EN = 1;	
		//send 32 bytes taks @100k 32*8*10 = 2560kns
		#3200000 rst_n = 0; WR_EN = 0;
		#50 rst_n = 1;
		#100 RD_EN = 1;
		#3200000 rst_n = 0; RD_EN = 0;
		$stop;
      
    end
always begin
    #10 clock = ! clock;
end
endmodule
