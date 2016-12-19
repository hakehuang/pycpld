`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:31:14 05/03/2016 
// Design Name: 
// Module Name:    uart_rx 
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
module my_uart_rx8to8(
	clk,
	rst_n,
	uart_ctl,
	rs_rx,
	
	data_in,
	data_sign
    );
	
	input 	clk;
	input	rst_n;
	input	[2:0]	uart_ctl;
	input	rs_rx;
	
	output [7:0]	data_in;
	output data_sign;
	
	parameter 	bps9600_2 	= 13'd2604,
				bps19200_2	= 13'd1301,
				bps38400_2	= 13'd650,
				bps57600_2	= 13'd433,
				bps115200_2 = 13'd217,  
				bps256000_2 = 13'd97; 
				
				
				
	parameter	IDLE = 2'b01,
				TRAN = 2'b10;
				
	
	reg	[1:0]	state;
	
	reg			bps_sel, sign_sel;
	
	reg	[12:0]	cnt;
	
	reg	[4:0]	tran_cnt;
	
	reg	[7:0]	data_in;
	reg			data_sign;
	
	wire		recv_comp;
	
	assign recv_comp = (tran_cnt == 19 && bps_sel);
	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			state <= IDLE;
		end
		else begin
			
			case(state)
				IDLE :  state <= ~rs_rx ? TRAN : IDLE;
				TRAN :  state <= recv_comp ? IDLE : TRAN;
				default: state <= IDLE;
			endcase
			
			
		end
	end
	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			bps_sel <= 1'b0;
			sign_sel <= 1'b0;
			cnt <= 'h0;
			tran_cnt <= 'h0;
		end
		else begin
			if(state == TRAN ) begin
				case(uart_ctl)
					3'h0: if(cnt == bps9600_2) begin 
					       cnt <=  'h0; 			
							 bps_sel <= ~sign_sel; 
							 sign_sel <= ~sign_sel; 
							 tran_cnt <=  tran_cnt + 1'b1;  
							 end
						  else begin 
							cnt <=  cnt + 1'b1; 
							bps_sel <= 1'b0; 
							end
					3'h1: if(cnt == bps19200_2) begin 
							cnt <=  'h0; 			
							bps_sel <= ~sign_sel; 
							sign_sel <= ~sign_sel; 
							tran_cnt <=  tran_cnt + 1'b1;  
							end
						  else begin 
							cnt <=  cnt + 1'b1; 
							bps_sel <= 1'b0; 
							end
					3'h2: if(cnt == bps38400_2) begin 
							cnt <=  'h0; 			
							bps_sel <= ~sign_sel; 
							sign_sel <= ~sign_sel; 
							tran_cnt <=  tran_cnt + 1'b1; 
							end
						  else begin 
						  cnt <=  cnt + 1'b1; 
						  bps_sel <= 1'b0; 
						  end
					3'h3: if(cnt == bps57600_2) begin 
							cnt <=  'h0; 			
							bps_sel <= ~sign_sel; 
							sign_sel <= ~sign_sel; 
							tran_cnt <=  tran_cnt + 1'b1; 
							end
							else 	begin 
							cnt <=  cnt + 1'b1; 
							bps_sel <= 1'b0; 
							end
					3'h4: if(cnt == bps115200_2) begin 
							cnt <=  'h0; 			
							bps_sel <= ~sign_sel; 
							sign_sel <= ~sign_sel; 
							tran_cnt <=  tran_cnt + 1'b1; 
							end
						  else begin 
							cnt <=  cnt + 1'b1; 
							bps_sel <= 1'b0; end
					3'h5: if(cnt == bps256000_2) begin 
							cnt <=  'h0; 			
							bps_sel <= ~sign_sel; 
							sign_sel <= ~sign_sel; 
							tran_cnt <=  tran_cnt + 1'b1; 
							end
						  else begin 
						  cnt <=  cnt + 1'b1; 
						  bps_sel <= 1'b0; 
						  end
					default: begin 
								cnt <= 'h0; 
								tran_cnt <=  0; 
								bps_sel <= 'h0; 
								sign_sel <= 'h0; 
								end
				endcase
			end
			else  begin 
				cnt <= 'h0; 
				sign_sel <= 'h0; 
				bps_sel <= 1'b0; 
				tran_cnt <= 'h0; 
				bps_sel <= 1'b0; 
				end
			
		end
	end
	
	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			data_in <= 'h0;
			data_sign <= 'h0;
		end
		else begin
			if(bps_sel)begin
				if(tran_cnt > 2 && tran_cnt <= 18) data_in[tran_cnt[4:1] - 1] <= rs_rx;
				 data_sign <= (tran_cnt == 19 ) ? 1'b1 : 1'b0;
			end
			else 	data_sign <= 1'b0;
			
		end
	end
	
	
	

endmodule
