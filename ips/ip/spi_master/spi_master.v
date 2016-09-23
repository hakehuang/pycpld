`timescale 1ns / 1ps
//**********************************************************************
// File: spi_master.v
// Module:spi_master
// by Robin zhang 
//**********************************************************************
module spi_master(

clk,rst_n,

spi_miso,spi_mosi,spi_clk,

spi_tx_en,spi_rx_en,spi_over,mode_select,receive_status

);

input clk;

input rst_n;

input spi_miso;

output spi_mosi;

output spi_clk;

input spi_tx_en;

output spi_over;

output receive_status;

input spi_rx_en;

input mode_select;



reg[7:0] data_count;

reg[7:0] recv_detect;

reg[7:0] spi_tx_db;

reg[4:0] cnt8;

reg spi_clkr;

reg spi_mosir;

reg spi_mosir1;

reg receive_status;

reg[7:0] spi_rx_dbr;

reg[7:0] spi_rx_dbr1;

wire[7:0] spi_rx_db;

wire[4:0] mode_reg;

wire[4:0] start_reg;
/***********************************************************************
*detect spi mode
***********************************************************************/
assign mode_reg = mode_select ? 5'd18 : 5'd17;

assign start_reg = mode_select ? 5'd1 : 5'd0;

/***********************************************************************
*control the spi timimg
***********************************************************************/
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cnt8 <= 5'd0;
		data_count <= 8'h0;
		spi_tx_db  <= 8'h0;
		recv_detect <= 8'h0;
		end
	else if((spi_tx_en || spi_rx_en) && ((data_count < 8'd64) )) begin
				if(cnt8 < mode_reg)
					cnt8 <= cnt8+1'b1;
				else begin
					if(spi_tx_en && spi_rx_en) begin
					cnt8 <= 5'd0;
					data_count <= data_count + 1'b1;
					spi_tx_db <= spi_tx_db + 1'b1;
					recv_detect <= (spi_rx_db == data_count) ? (recv_detect+1'b1) : recv_detect;
					end
					else begin
					if(spi_tx_en) begin
					cnt8 <= 5'd0;
					data_count <= data_count + 1'b1;
					spi_tx_db <= spi_tx_db + 1'b1;
					end
					else begin
					cnt8 <= 5'd0;
					data_count <= data_count + 1'b1;
					recv_detect <= (spi_rx_db == data_count) ? (recv_detect+1'b1) : recv_detect;
					end
					end
				end
			end
	else begin 
	 cnt8 <= 5'd0;
	 data_count <= data_count;
	end
end

/***********************************************************************
*generate spi clk
***********************************************************************/
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		spi_clkr <= mode_select ? 1'b1 : 1'b0 ;
	else if(cnt8 > start_reg && cnt8 < mode_reg) 
				spi_clkr <= ~spi_clkr;
			else
				spi_clkr <= spi_clkr;
end

assign spi_clk = spi_clkr;

/***********************************************************************
*spi master output data
***********************************************************************/
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		spi_mosir <= 1'b1;
	else if(spi_tx_en) begin
				case(cnt8[4:1])
				   4'd0: spi_mosir <= spi_tx_db[7];
					
					4'd1: spi_mosir <= spi_tx_db[6];

					4'd2: spi_mosir <= spi_tx_db[5];

					4'd3: spi_mosir <= spi_tx_db[4];

					4'd4: spi_mosir <= spi_tx_db[3];

					4'd5: spi_mosir <= spi_tx_db[2];

					4'd6: spi_mosir <= spi_tx_db[1];

					4'd7: spi_mosir <= spi_tx_db[0];

					default: spi_mosir <= 1'b1;
				endcase
			end
	else 
		spi_mosir <= 1'b1;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		spi_mosir1 <= 1'b1;
	else if(spi_tx_en) begin
				case(cnt8[4:1])
				   4'd1: spi_mosir1 <= spi_tx_db[7];
					
					4'd2: spi_mosir1 <= spi_tx_db[6];

					4'd3: spi_mosir1 <= spi_tx_db[5];

					4'd4: spi_mosir1 <= spi_tx_db[4];

					4'd5: spi_mosir1 <= spi_tx_db[3];

					4'd6: spi_mosir1 <= spi_tx_db[2];

					4'd7: spi_mosir1 <= spi_tx_db[1];

					4'd8: spi_mosir1 <= spi_tx_db[0];

					default: spi_mosir1 <= 1'b1;
				endcase
			end
	else 
		spi_mosir1 <= 1'b1;
end

assign spi_mosi = mode_select ? spi_mosir1 : spi_mosir;

/***********************************************************************
*spi master input data
***********************************************************************/
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		spi_rx_dbr <= 8'hff;
	else if(spi_rx_en) begin
				case(cnt8)
					5'd1: spi_rx_dbr[7] <= spi_miso;	

					5'd3: spi_rx_dbr[6] <= spi_miso;	

					5'd5: spi_rx_dbr[5] <= spi_miso;	

					5'd7: spi_rx_dbr[4] <= spi_miso;	

					5'd9: spi_rx_dbr[3] <= spi_miso;	

					5'd11: spi_rx_dbr[2] <= spi_miso;	

					5'd13: spi_rx_dbr[1] <= spi_miso;	

					5'd15: spi_rx_dbr[0] <= spi_miso;	
					
					default: spi_rx_dbr <= spi_rx_dbr;
				endcase
			end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		spi_rx_dbr1 <= 8'hff;
	else if(spi_rx_en) begin
				case(cnt8)
					5'd3: spi_rx_dbr1[7] <= spi_miso;	

					5'd5: spi_rx_dbr1[6] <= spi_miso;	

					5'd7: spi_rx_dbr1[5] <= spi_miso;	

					5'd9: spi_rx_dbr1[4] <= spi_miso;	

					5'd11: spi_rx_dbr1[3] <= spi_miso;	

					5'd13: spi_rx_dbr1[2] <= spi_miso;	

					5'd15: spi_rx_dbr1[1] <= spi_miso;	

					5'd17: spi_rx_dbr1[0] <= spi_miso;	
					
					default: spi_rx_dbr1 <= spi_rx_dbr1;
				endcase
			end
end

assign spi_rx_db = mode_select ? spi_rx_dbr1 : spi_rx_dbr;

assign spi_over = (data_count == 8'd64) ? 1'b1 :1'b0;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		receive_status <= 1'b0;
	else
		receive_status <= (recv_detect == 8'd64) ? 1'b1 : 1'b0;
end

endmodule